// ignore_for_file: unused_field, prefer_const_declarations, use_rethrow_when_possible, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DijeloviService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();

  DijeloviService() : _dio = Dio() {
    configureDio(_dio);
  }

  void configureDio(Dio dio) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  Future<void> _addAuthorizationHeader() async {
    final loggedInStatus = await _korisnikService.isLoggedIn();
    if (!loggedInStatus) {
      throw Exception("User not logged in");
    }

    // Dohvati korisničke podatke iz secure storage-a
    final korisnikInfo = await _korisnikService.getUserInfo();
    final username = korisnikInfo['username'];
    final password = korisnikInfo['password'];

    if (username == null || password == null) {
      throw Exception("Missing credentials");
    }
    // Generiraj Authorization header
    final authHeader = _korisnikService.encodeBasicAuth(username, password);
    _dio.options.headers['Authorization'] = authHeader;
  }

  List<dynamic> listaDijelova = [];
  int countDijelova = 0;

  Future<Map<String, dynamic>> getDijeloviById(int dijeloviId) async {
    final String url = '${HelperService.baseUrl}/Dijelovi/$dijeloviId';

    final HttpClient httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final http.Response response = await ioClient.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user');
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load user: Server is not available');
    } catch (e) {
      throw Exception('Failed to load user: $e');
    } finally {
      ioClient.close();
    }
  }

  Future<void> getDijelovis({
    String? status,
    String? naziv,
    int? page,
    int? pageSize,
    bool? isSlikaIncluded,
    String? sortOrder,
    double? pocetnaCijena,
    double? krajnjaCijena,
    int? kategorijaId,
    int? korisnikId,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (pocetnaCijena != null) {
      queryParams['PocetnaCijena'] = pocetnaCijena.toString();
    }

    if (korisnikId != null) {
      queryParams['korisnikId'] = korisnikId.toString();
    }
    if (naziv != null && naziv.isNotEmpty) {
      queryParams['naziv'] = naziv;
    }
    if (krajnjaCijena != null) {
      queryParams['KrajnjaCijena'] = krajnjaCijena.toString();
    }

    if (kategorijaId != null) {
      queryParams['kategorijaId'] = kategorijaId.toString();
    }
    if (status != null && status.isNotEmpty) {
      if (status != "sve") {
        queryParams['status'] = status;
      }
    } else {
      queryParams['status'] = "aktivan";
    }
    if (isSlikaIncluded != null) {
      queryParams['isSlikaIncluded'] = isSlikaIncluded.toString();
    }
    if (page != null) {
      queryParams['Page'] = page.toString();
    }
    if (pageSize != null) {
      queryParams['PageSize'] = pageSize.toString();
    }

    if (sortOrder != null) queryParams['SortOrder'] = sortOrder;
    Uri uri = Uri.parse('${HelperService.baseUrl}/Dijelovi');
    uri = uri.replace(queryParameters: queryParams);

    final String url = uri.toString();

    final HttpClient httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final http.Response response = await ioClient.get(Uri.parse(url)).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        listaDijelova = data['resultsList'] ?? [];
        countDijelova = data['count'] ?? 0;

        logger.i("Uspješno preuzeti dijelovi");
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri preuzimanju dijelova: $e");
    } finally {
      ioClient.close();
    }
  }

  Future<void> upravljanjeDijelom(String status, int odabraniId) async {
    final String baseUrl = '${HelperService.baseUrl}/Dijelovi';
    Uri uri;

    HttpClient httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader(); // Dodavanje authorization header-a

      if (status == "aktivan") {
        uri = Uri.parse('$baseUrl/aktivacija/$odabraniId').replace(queryParameters: {'aktivacija': 'true'});
      } else if (status == "vracen") {
        uri = Uri.parse('$baseUrl/aktivacija/$odabraniId').replace(queryParameters: {'aktivacija': 'false'});
      } else if (status == "obrisan") {
        uri = Uri.parse('$baseUrl/$odabraniId');
      } else {
        throw Exception('Nevažeći status');
      }

      final request = await httpClient.openUrl(
        status == "obrisan" ? 'DELETE' : 'PUT', // Odabir metode temeljem statusa
        uri,
      );

      final String authHeader = _dio.options.headers['Authorization'];
      request.headers.set('Authorization', authHeader);
      request.headers.set('accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        logger.i("Status uspješno ažuriran");
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri ažuriranju statusa: $e");
      throw e;
    } finally {
      httpClient.close();
    }
  }

  Future<Map<String, dynamic>> postDijelovi({
    required String naziv,
    required int cijena,
    required String opis,
    required int kategorijaId,
    required int kolicina,
    required int korisnikId,
  }) async {
    // Provjera podataka
    if (naziv.isEmpty || cijena <= 0 || kolicina <= 0 || kategorijaId <= 0 || korisnikId <= 0) {
      return {'poruka': "Pogresni podatci", 'dijeloviId': null};
    }

    final String baseUrl = '${HelperService.baseUrl}/Dijelovi';
    final Uri uri = Uri.parse(baseUrl);

    final Map<String, dynamic> requestBody = {
      'naziv': naziv,
      'cijena': cijena.toString(),
      'opis': opis,
      'kategorijaId': kategorijaId.toString(),
      'kolicina': kolicina.toString(),
      'korisnikId': korisnikId.toString(),
    };

    final HttpClient httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader(); // Dodavanje authorization header-a

      final request = await httpClient.openUrl('POST', uri);

      final String authHeader = _dio.options.headers['Authorization'];
      request.headers.set('Authorization', authHeader);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('accept', 'application/json');

      request.add(utf8.encode(jsonEncode(requestBody)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return {'poruka': "Uspjesno dodat dio", 'dijeloviId': data['dijeloviId']};
      } else {
        return {'poruka': "Greska prilikom dodavanja", 'dijeloviId': null};
      }
    } on TimeoutException catch (_) {
      return {'poruka': "Greska prilikom dodavanja: Server nije dostupan", 'biciklId': null};
    } catch (e) {
      logger.e("Greška pri dodavanju bicikla: $e");
      return {'poruka': "Greska prilikom dodavanja", 'dijeloviId': null};
    } finally {
      httpClient.close();
    }
  }

  Future<String?> putDijelovi(int dijeloviId, String? naziv, double? cijena, String? opis, int? kategorijaId, int? kolicina, int korisnikId) async {
    final String baseUrl = '${HelperService.baseUrl}/Dijelovi';
    Uri uri;

    HttpClient httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    try {
      if (dijeloviId == 0) {
        return "Dijelovi ID je obavezan";
      }
      if (korisnikId == 0) {
        return "Korisnik ID je obavezan";
      }
      if ((naziv == null || naziv.isEmpty) && cijena == null && (opis == null || opis.isEmpty) && kategorijaId == null && kolicina == null) {
        return "Potrebno je izmijeniti barem jedan zapis";
      }
      await _addAuthorizationHeader();
      final body = <String, dynamic>{};
      if (naziv != null && naziv.isNotEmpty) {
        body['naziv'] = naziv;
      }
      if (cijena != null && cijena != 0) {
        body['cijena'] = cijena.toString();
      }
      if (opis != null && opis.isNotEmpty) {
        body['opis'] = opis;
      }
      if (kategorijaId != null && kategorijaId != 0) {
        body['kategorijaId'] = kategorijaId.toString();
      }
      if (kolicina != null) {
        body['kolicina'] = kolicina.toString();
      }
      body['korisnikId'] = korisnikId.toString();

      uri = Uri.parse('$baseUrl/$dijeloviId');

      final request = await httpClient.putUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Dijelovi uspješno izmijenjeni";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom izmjene dijelova';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError.message != null) {
        return 'Greška prilikom izmjene dijelova: ${httpError.message}';
      }
      return 'Greška prilikom izmjene dijelova: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom izmjene dijelova: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
