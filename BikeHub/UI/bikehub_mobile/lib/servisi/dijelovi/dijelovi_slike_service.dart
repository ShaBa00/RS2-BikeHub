// ignore_for_file: unused_field, prefer_const_declarations, use_rethrow_when_possible, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:dio/io.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DijeloviSlikeService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();
//
  DijeloviSlikeService() : _dio = Dio() {
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

  Future<String> postSlikeDijelovi({
    required List<String> slike,
    required String biciklId,
  }) async {
    // Provjera podataka
    if (slike.isEmpty || biciklId.isEmpty) {
      return "Pogresni podatci";
    }

    final String baseUrl = '${HelperService.baseUrl}/SlikeDijelovi';
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

      for (String slika in slike) {
        final Uri uri = Uri.parse(baseUrl);

        final Map<String, dynamic> requestBody = {
          'dijeloviId': biciklId,
          'slika': slika,
        };

        final request = await httpClient.openUrl('POST', uri);

        final String authHeader = _dio.options.headers['Authorization'];
        request.headers.set('Authorization', authHeader);
        request.headers.set('Content-Type', 'application/json');
        request.headers.set('accept', 'application/json');

        request.add(utf8.encode(jsonEncode(requestBody)));

        final response = await request.close();

        if (response.statusCode != 200) {
          return "Greska prilikom dodavanja";
        }
      }
      return "Uspjesno dodate slike";
    } on TimeoutException catch (_) {
      return "Greska prilikom dodavanja: Server nije dostupan";
    } catch (e) {
      logger.e("Greška pri dodavanju slika: $e");
      return "Greska prilikom dodavanjaa";
    } finally {
      httpClient.close();
    }
  }

  Future<String?> putSlike(String slika, int dijeloviId, int slikaId) async {
    final String baseUrl = '${HelperService.baseUrl}/SlikeDijelovi';
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      if (slika.isEmpty) {
        return "Slika je prazna";
      }
      await _addAuthorizationHeader();

      final uri = Uri.parse('$baseUrl/$slikaId');

      final body = {
        'dijeloviId': dijeloviId.toString(),
        'slika': slika,
      };

      final request = await httpClient.putUrl(uri); // Promjena POST u PUT
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Slika je uspješno dodana";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom dodavanja slike';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError.message != null) {
        return 'Greška prilikom dodavanja slike: ${httpError.message}';
      }
      return 'Greška prilikom dodavanja slike: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom dodavanja slike: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }

  Future<String?> postSlike(List<String> slike, int dijeloviId) async {
    final String baseUrl = '${HelperService.baseUrl}/SlikeDijelovi';
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      if (slike.isEmpty) {
        return "Lista slika je prazna";
      }
      await _addAuthorizationHeader();

      for (String slika in slike) {
        final uri = Uri.parse(baseUrl);

        final body = {
          'dijeloviId': dijeloviId.toString(),
          'slika': slika,
        };

        final request = await httpClient.postUrl(uri);
        request.headers.set('accept', 'application/json');
        request.headers.set('Content-Type', 'application/json');
        request.headers
            .set('Authorization', _dio.options.headers['Authorization']);

        request.write(jsonEncode(body));

        final response = await request.close();

        if (response.statusCode != 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          final decodedResponse = jsonDecode(responseBody);
          final errors = decodedResponse['errors'];
          if (errors != null && errors['userError'] != null) {
            return errors['userError'].join(', ');
          } else {
            return 'Greška prilikom dodavanja slike';
          }
        }
      }
      return "Sve slike su uspješno dodane";
    } on HttpException catch (httpError) {
      if (httpError.message != null) {
        return 'Greška prilikom dodavanja slike: ${httpError.message}';
      }
      return 'Greška prilikom dodavanja slike: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom dodavanja slike: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }

  Future<String?> obrisiSliku(int slikaId) async {
    final String baseUrl = '${HelperService.baseUrl}/SlikeDijelovi';
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final uri = Uri.parse('$baseUrl/$slikaId');

      await _addAuthorizationHeader();

      final request = await httpClient.deleteUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Slika je uspješno obrisana";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom brisanja slike';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError.message != null) {
        return 'Greška prilikom brisanja slike: ${httpError.message}';
      }
      return 'Greška prilikom brisanja slike: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom brisanja slike: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
