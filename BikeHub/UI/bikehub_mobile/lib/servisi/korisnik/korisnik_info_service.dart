// ignore_for_file: unnecessary_null_comparison, unnecessary_type_check, prefer_const_declarations

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';

class KorisnikInfoServis {
  final logger = Logger();
  final KorisnikServis _korisnikService = KorisnikServis();
  final Dio _dio;

  KorisnikInfoServis() : _dio = Dio() {
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

  Future<String?> promjeniKorisnikInfo(
      String? imePrezime, String? telefon, int korisnikInfoId) async {
    final String baseUrl = '${HelperService.baseUrl}/KorisnikInfo';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      if (korisnikInfoId == 0) {
        return "Korisnik Info ID je obavezna";
      }

      if ((imePrezime == null || imePrezime.isEmpty) &&
          (telefon == null || telefon.isEmpty)) {
        return "Potrebno je izmjenuti barem jedan zapis";
      }

      await _addAuthorizationHeader();

      final body = <String, String>{};
      if (imePrezime != null && imePrezime.isNotEmpty) {
        body['imePrezime'] = imePrezime;
      }
      if (telefon != null && telefon.isNotEmpty) {
        body['telefon'] = telefon;
      }

      uri = Uri.parse('$baseUrl/$korisnikInfoId');

      final request = await httpClient.putUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Korisnik Info uspješno izmjenjena";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom izmjene korisnik info';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError is HttpException && httpError.message != null) {
        return 'Greška prilikom izmjene korisnik info: ${httpError.message}';
      }
      return 'Greška prilikom izmjene korisnik info: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom izmjene korisnik info: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
