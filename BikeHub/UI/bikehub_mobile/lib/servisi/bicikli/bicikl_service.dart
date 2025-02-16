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

class BiciklService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();
//
  BiciklService() : _dio = Dio() {
    configureDio(_dio);
  }

  void configureDio(Dio dio) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
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

  List<dynamic> listaBicikala = [];
  int countBicikala = 0;

  Future<Map<String, dynamic>> getBiciklById(int biciklId) async {
    final String url = '${HelperService.baseUrl}/Bicikli/$biciklId';

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final http.Response response = await ioClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load user: Server is not available');
    } catch (e) {
      throw Exception('Failed to load user: $e');
    } finally {
      ioClient.close();
    }
  }

  Future<void> getBiciklis({
    String? status,
    String? naziv,
    int? page,
    int? pageSize,
    int? brojBrzina,
    int? korisnikId,
    int? kategorijaId,
    bool? isSlikaIncluded,
    String? sortOrder,
    String? velicinaRama,
    String? velicinaTocka,
    double? pocetnaCijena,
    double? krajnjaCijena,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (pocetnaCijena != null) {
      queryParams['PocetnaCijena'] = pocetnaCijena.toString();
    }
    if (krajnjaCijena != null) {
      queryParams['KrajnjaCijena'] = krajnjaCijena.toString();
    }

    if (naziv != null && naziv.isNotEmpty) {
      queryParams['naziv'] = naziv;
    }

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (velicinaRama != null && velicinaRama.isNotEmpty) {
      queryParams['velicinaRama'] = velicinaRama;
    }
    if (velicinaTocka != null && velicinaTocka.isNotEmpty) {
      queryParams['velicinaTocka'] = velicinaTocka;
    }
    if (sortOrder != null) queryParams['SortOrder'] = sortOrder;
    if (isSlikaIncluded != null) {
      queryParams['isSlikaIncluded'] = isSlikaIncluded.toString();
    }
    if (kategorijaId != null) {
      queryParams['kategorijaId'] = kategorijaId.toString();
    }
    if (korisnikId != null) {
      queryParams['korisnikId'] = korisnikId.toString();
    }
    if (brojBrzina != null && brojBrzina != 0) {
      queryParams['brojBrzina'] = brojBrzina.toString();
    }
    if (page != null) {
      queryParams['Page'] = page.toString();
    }
    if (pageSize != null) {
      queryParams['PageSize'] = pageSize.toString();
    }

    Uri uri = Uri.parse('${HelperService.baseUrl}/Bicikli');
    uri = uri.replace(queryParameters: queryParams);

    final String url = uri.toString();

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final http.Response response = await ioClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        listaBicikala = data['resultsList'] ?? [];
        countBicikala = data['count'] ?? 0;

        logger.i("Uspješno preuzeti bicikli:");
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri preuzimanju bicikala: $e");
    } finally {
      ioClient.close();
    }
  }

  Future<List<dynamic>> getPromotedItems() async {
    final Map<String, dynamic> queryParams = {};

    Uri uri = Uri.parse('${HelperService.baseUrl}/Bicikli/promoted-items');
    uri = uri.replace(queryParameters: queryParams);

    final String url = uri.toString();

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final http.Response response = await ioClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        logger.i("Uspješno preuzeti bicikli:");
        return data;
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
        return [];
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri preuzimanju bicikala: $e");
      return [];
    } finally {
      ioClient.close();
    }
  }

  Future<void> upravljanjeBiciklom(String status, int odabraniId) async {
    final String baseUrl = '${HelperService.baseUrl}/Bicikli';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader(); // Dodavanje authorization header-a

      if (status == "aktivan") {
        uri = Uri.parse('$baseUrl/aktivacija/$odabraniId')
            .replace(queryParameters: {'aktivacija': 'true'});
      } else if (status == "vracen") {
        uri = Uri.parse('$baseUrl/aktivacija/$odabraniId')
            .replace(queryParameters: {'aktivacija': 'false'});
      } else if (status == "obrisan") {
        uri = Uri.parse('$baseUrl/$odabraniId');
      } else {
        throw Exception('Nevažeći status');
      }

      final request = await httpClient.openUrl(
        status == "obrisan"
            ? 'DELETE'
            : 'PUT', // Odabir metode temeljem statusa
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

  Future<Map<String, dynamic>> postBicikl({
    required String naziv,
    required int cijena,
    required int kolicina,
    required String velicinaRama,
    required String velicinaTocka,
    required int brojBrzina,
    required int kategorijaId,
    required int korisnikId,
  }) async {
    // Provjera podataka
    if (naziv.isEmpty ||
        cijena <= 0 ||
        kolicina <= 0 ||
        velicinaRama.isEmpty ||
        velicinaTocka.isEmpty ||
        brojBrzina <= 0 ||
        kategorijaId <= 0 ||
        korisnikId <= 0) {
      return {'poruka': "Pogresni podatci", 'biciklId': null};
    }

    final String baseUrl = '${HelperService.baseUrl}/Bicikli';
    final Uri uri = Uri.parse(baseUrl);

    final Map<String, dynamic> requestBody = {
      'naziv': naziv,
      'cijena': cijena.toString(),
      'kolicina': kolicina.toString(),
      'velicinaRama': velicinaRama,
      'velicinaTocka': velicinaTocka,
      'brojBrzina': brojBrzina.toString(),
      'kategorijaId': kategorijaId.toString(),
      'korisnikId': korisnikId.toString(),
    };

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

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
        return {
          'poruka': "Uspjesno dodat bicikl",
          'biciklId': data['biciklId']
        };
      } else {
        return {'poruka': "Greska prilikom dodavanja", 'biciklId': null};
      }
    } on TimeoutException catch (_) {
      return {
        'poruka': "Greska prilikom dodavanja: Server nije dostupan",
        'biciklId': null
      };
    } catch (e) {
      logger.e("Greška pri dodavanju bicikla: $e");
      return {'poruka': "Greska prilikom dodavanja", 'biciklId': null};
    } finally {
      httpClient.close();
    }
  }

  Future<String?> putBicikl(
    int biciklId,
    String? naziv,
    int? cijena,
    String? velicinaRama,
    String? velicinaTocka,
    int? brojBrzina,
    int? kategorijaId,
    int? kolicina,
    int korisnikId,
  ) async {
    final String baseUrl = '${HelperService.baseUrl}/Bicikli';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      if (biciklId == 0) {
        return "Bicikl ID je obavezan";
      }
      if (korisnikId == 0) {
        return "Korisnik ID je obavezan";
      }
      if ((naziv == null || naziv.isEmpty) &&
          cijena == null &&
          (velicinaRama == null || velicinaRama.isEmpty) &&
          (velicinaTocka == null || velicinaTocka.isEmpty) &&
          brojBrzina == null &&
          kategorijaId == null &&
          kolicina == null) {
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
      if (velicinaRama != null && velicinaRama.isNotEmpty) {
        body['velicinaRama'] = velicinaRama;
      }
      if (velicinaTocka != null && velicinaTocka.isNotEmpty) {
        body['velicinaTocka'] = velicinaTocka;
      }
      if (brojBrzina != null && brojBrzina != 0) {
        body['brojBrzina'] = brojBrzina.toString();
      }
      if (kategorijaId != null && kategorijaId != 0) {
        body['kategorijaId'] = kategorijaId.toString();
      }
      if (kolicina != null) {
        body['kolicina'] = kolicina.toString();
      }
      body['korisnikId'] = korisnikId.toString();

      uri = Uri.parse('$baseUrl/$biciklId');

      final request = await httpClient.putUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Bicikli uspješno izmijenjeni";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom izmjene bicikla';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError.message != null) {
        return 'Greška prilikom izmjene bicikla: ${httpError.message}';
      }
      return 'Greška prilikom izmjene bicikla: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom izmjene bicikla: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
