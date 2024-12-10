// ignore_for_file: prefer_const_declarations, unused_element, unnecessary_null_comparison, unnecessary_type_check

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';

class BiciklSacuvaniServis {
  final logger = Logger();
  final KorisnikServis _korisnikService = KorisnikServis();
  final Dio _dio;

  BiciklSacuvaniServis() : _dio = Dio() {
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

  Future<List<dynamic>?> getSacuvani({required int korisnikId}) async {
    await _addAuthorizationHeader();
    final Map<String, dynamic> queryParams = {
      'korisnikId': korisnikId.toString(),
    };

    Uri uri = Uri.parse('${HelperService.baseUrl}/SpaseniBicikli');
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
        if (data['count'] != null && data['count'] > 0) {
          return data['resultsList'];
        } else {
          return null;
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

  Future<Map<String, dynamic>?> isBiciklSacuvan(
      {required int korisnikId, required int biciklId}) async {
    await _addAuthorizationHeader();
    final Map<String, dynamic> queryParams = {
      'korisnikId': korisnikId.toString(),
      'biciklId': biciklId.toString(),
    };

    Uri uri = Uri.parse('${HelperService.baseUrl}/SpaseniBicikli');
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
        if (data['count'] != null && data['count'] > 0) {
          return data['resultsList'][0];
        } else {
          return null;
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

  Future<String?> promjeniSacuvani(
      int sacuvaniId, int korisnikId, int biciklId, bool obrisi) async {
    final String baseUrl =
        '${HelperService.baseUrl}/SpaseniBicikli/$sacuvaniId';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      // Dodavanje Authorization header-a
      await _addAuthorizationHeader();

      if (obrisi) {
        uri = Uri.parse(baseUrl);

        final request = await httpClient.deleteUrl(uri);
        request.headers.set('accept', 'application/json');
        request.headers.set('Content-Type', 'application/json');
        request.headers
            .set('Authorization', _dio.options.headers['Authorization']);

        final response = await request.close();

        if (response.statusCode == 200) {
          return "Proizvod izmjenjen";
        } else {
          final responseBody = await response.transform(utf8.decoder).join();
          final decodedResponse = jsonDecode(responseBody);
          final errors = decodedResponse['errors'];
          if (errors != null && errors['userError'] != null) {
            return errors['userError'].join(', ');
          } else {
            return 'Greška prilikom izmjene zapisa';
          }
        }
      } else {
        uri = Uri.parse(baseUrl);

        final request = await httpClient.putUrl(uri);
        request.headers.set('accept', 'application/json');
        request.headers.set('Content-Type', 'application/json');
        request.headers
            .set('Authorization', _dio.options.headers['Authorization']);

        final body = {
          'biciklId': biciklId.toString(),
          'datumSpasavanja': DateTime.now().toIso8601String(),
          'korisnikId': korisnikId.toString(),
        };

        request.write(jsonEncode(body));

        final response = await request.close();

        if (response.statusCode == 200) {
          return "Proizvod uspjesno sacuvan";
        } else {
          final responseBody = await response.transform(utf8.decoder).join();
          final decodedResponse = jsonDecode(responseBody);
          final errors = decodedResponse['errors'];
          if (errors != null && errors['userError'] != null) {
            return errors['userError'].join(', ');
          } else {
            return 'Greška';
          }
        }
      }
    } on HttpException catch (httpError) {
      if (httpError is HttpException && httpError.message != null) {
        return 'Greška prilikom izmjene zapisa: ${httpError.message}';
      }
      return 'Greška prilikom izmjene zapisa: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom izmjene zapisa: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }

  Future<String?> dodajNoviSacuvani(int biciklId, int korisnikId) async {
    if (biciklId == 0 && korisnikId == 0) {
      return 'Greška prilikom dodavanja zapisa';
    }
    final String baseUrl = '${HelperService.baseUrl}/SpaseniBicikli';
    Uri uri = Uri.parse(baseUrl);

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      // Dodavanje Authorization header-a
      await _addAuthorizationHeader();

      // Priprema body za slanje
      final body = {
        'biciklId': biciklId.toString(),
        'datumSpasavanja': DateTime.now().toIso8601String(),
        'korisnikId': korisnikId.toString(),
      };

      final request = await httpClient.postUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Proizvod uspješno sacuvan";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška ';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError is HttpException && httpError.message != null) {
        return 'Greška prilikom dodavanja zapisa: ${httpError.message}';
      }
      return 'Greška prilikom dodavanja zapisa: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom dodavanja zapisa: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
