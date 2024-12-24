// ignore_for_file: unused_field, prefer_const_declarations, use_rethrow_when_possible, unnecessary_null_comparison, unused_element, unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NarudbaService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();
//
  NarudbaService() : _dio = Dio() {
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

  Future<Map<String, dynamic>> postNarudba({
    required int korisnikId,
    required int prodavaocId,
  }) async {
    // Provjera podataka
    if (korisnikId <= 0) {
      return {'poruka': "Pogresni podatci", 'narudzbaId': null};
    }
    if (prodavaocId <= 0) {
      return {'poruka': "Pogresni podatci", 'narudzbaId': null};
    }

    final String baseUrl = '${HelperService.baseUrl}/Narudzba';
    final Uri uri = Uri.parse(baseUrl);

    final Map<String, dynamic> requestBody = {
      'korisnikId': korisnikId.toString(),
      'prodavaocId': prodavaocId.toString(),
    };

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

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
          'poruka': "Uspjesno dodata narudba",
          'narudzbaId': data['narudzbaId']
        };
      } else {
        return {'poruka': "Greska prilikom dodavanja", 'narudzbaId': null};
      }
    } on TimeoutException catch (_) {
      return {
        'poruka': "Greska prilikom dodavanja: Server nije dostupan",
        'narudzbaId': null
      };
    } catch (e) {
      logger.e("Greška pri dodavanju bicikla: $e");
      return {'poruka': "Greska prilikom dodavanja", 'narudzbaId': null};
    } finally {
      httpClient.close();
    }
  }

  List<Map<String, dynamic>> listaNarudbaBicikli = [];
  List<Map<String, dynamic>> listaNarudbaDijelovi = [];

  Future<void> getNarudbe({
    int? korisnikId,
    int? prodavaocId,
    bool narudzbaBicikliIncluded = true,
    bool narudzbaDijeloviIncluded = true,
  }) async {
    await _addAuthorizationHeader();
    final Map<String, dynamic> queryParams = {
      'narudzbaBicikliIncluded': narudzbaBicikliIncluded.toString(),
      'narudzbaDijeloviIncluded': narudzbaDijeloviIncluded.toString()
    };
    if (korisnikId != null) queryParams['korisnikId'] = korisnikId.toString();
    if (prodavaocId != null) {
      queryParams['prodavaocId'] = prodavaocId.toString();
    }
    Uri uri = Uri.parse('${HelperService.baseUrl}/Narudzba');
    uri = uri.replace(queryParameters: queryParams);

    logger.d('Request URL: ${uri.toString()}');
    logger.d('Query params: $queryParams');

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': _dio.options.headers['Authorization'] ?? '',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['resultsList'] != null && data['resultsList'].isNotEmpty) {
          final results = List<Map<String, dynamic>>.from(data['resultsList']);

          for (var narudzba in results) {
            if (narudzbaBicikliIncluded &&
                narudzba['narudzbaBiciklis'] != null) {
              for (var bicikl in narudzba['narudzbaBiciklis']) {
                listaNarudbaBicikli.add(bicikl);
              }
            }
            if (narudzbaDijeloviIncluded &&
                narudzba['narudzbaDijelovis'] != null) {
              for (var dio in narudzba['narudzbaDijelovis']) {
                listaNarudbaDijelovi.add(dio);
              }
            }
          }
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load data: Server is not available');
    } catch (e) {
      logger.e('Greška: $e');
      throw Exception('Failed to load data: $e');
    } finally {
      ioClient.close();
    }
  }

  Future<String> upravljanjeNarudbom(int odabraniId) async {
    final String baseUrl = '${HelperService.baseUrl}/Narudzba/zavrsi';
    Uri uri = Uri.parse('$baseUrl/$odabraniId');

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

      final request = await httpClient.openUrl(
        'PUT',
        uri,
      );

      final String? authHeader = _dio.options.headers['Authorization'];
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }
      request.headers.set('accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Uspjesno potvrdeno";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> errorData = jsonDecode(responseBody);
        return errorData['message'] ??
            "Neuspješan zahtjev: ${response.statusCode}";
      }
    } on TimeoutException catch (_) {
      return 'Failed to update status: Server is not available';
    } catch (e) {
      logger.e("Greška pri ažuriranju statusa: $e");
      return e.toString();
    } finally {
      httpClient.close();
    }
  }

  Future<String> aktivacijaNarudbe(int odabraniId, bool aktivacija) async {
    final String baseUrl = '${HelperService.baseUrl}/Narudzba/aktivacija';
    Uri uri = Uri.parse('$baseUrl/$odabraniId')
        .replace(queryParameters: {'aktivacija': aktivacija.toString()});

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

      final request = await httpClient.openUrl(
        'PUT',
        uri,
      );

      final String? authHeader = _dio.options.headers['Authorization'];
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }
      request.headers.set('accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Uspjesno izvrsena radnja";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> errorData = jsonDecode(responseBody);
        return errorData['message'] ??
            "Neuspješan zahtjev: ${response.statusCode}";
      }
    } on TimeoutException catch (_) {
      return 'Failed to update status: Server is not available';
    } catch (e) {
      logger.e("Greška pri ažuriranju statusa: $e");
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
