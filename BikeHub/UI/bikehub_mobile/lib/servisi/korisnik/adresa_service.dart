// ignore_for_file: prefer_const_declarations, unused_element, unnecessary_null_comparison, unnecessary_type_check

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';

class AdresaServis {
  final logger = Logger();
  final KorisnikServis _korisnikService = KorisnikServis();
  final Dio _dio;

  AdresaServis() : _dio = Dio() {
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

  Future<Map<String, dynamic>?> getAdresa(
      {int? korisnikId,
      String? grad,
      String? postanskiBroj,
      String? ulica,
      String? status,
      int? page,
      int? pageSize}) async {
    final Map<String, dynamic> queryParams = {};

    if (korisnikId != null) queryParams['korisnikId'] = korisnikId.toString();
    if (grad != null) queryParams['grad'] = grad;
    if (postanskiBroj != null) queryParams['postanskiBroj'] = postanskiBroj;
    if (ulica != null) queryParams['ulica'] = ulica;
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['pageSize'] = pageSize.toString();

    // Ručno sastavljanje URL-a
    Uri uri = Uri.parse('${HelperService.baseUrl}/Adresa');
    uri = uri.replace(queryParameters: queryParams);

    final String url = uri.toString();

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final http.Response response = await ioClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['resultsList'] != null && data['resultsList'].isNotEmpty) {
          return data['resultsList'][0];
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load address: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load address: Server is not available');
    } catch (e) {
      logger.e('Greška: $e');
      throw Exception('Failed to load address: $e');
    } finally {
      ioClient.close();
    }
  }

  Future<String?> promjeniAdresu(
      String? grad, String? postanskiBroj, String? ulica, int adresaId) async {
    final String baseUrl = '${HelperService.baseUrl}/Adresa';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      // Provjeri da li je poslan adresaId
      if (adresaId == 0) {
        return "Adresa ID je obavezna";
      }

      // Provjeri da li je poslan barem jedan zapis za izmjenu
      if ((grad == null || grad.isEmpty) &&
          (postanskiBroj == null || postanskiBroj.isEmpty) &&
          (ulica == null || ulica.isEmpty)) {
        return "Potrebno je izmjenuti barem jedan zapis";
      }

      // Dodavanje Authorization header-a
      await _addAuthorizationHeader();

      // Priprema body za slanje
      final body = <String, String>{};
      if (grad != null && grad.isNotEmpty) {
        body['grad'] = grad;
      }
      if (ulica != null && ulica.isNotEmpty) {
        body['ulica'] = ulica;
      }
      if (postanskiBroj != null && postanskiBroj.isNotEmpty) {
        body['postanskiBroj'] = postanskiBroj;
      }

      uri = Uri.parse('$baseUrl/$adresaId');

      final request = await httpClient.putUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Adresa uspješno izmjenjena";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom izmjene adrese';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError is HttpException && httpError.message != null) {
        return 'Greška prilikom izmjene adrese: ${httpError.message}';
      }
      return 'Greška prilikom izmjene adrese: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom izmjene adrese: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
