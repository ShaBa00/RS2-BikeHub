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

class NarudbaDijeloviService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();
//
  NarudbaDijeloviService() : _dio = Dio() {
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

  Future<Map<String, dynamic>> postNarudbaDijelovi({
    required int narudzbaId,
    required int dijeloviId,
    required int kolicina,
  }) async {
    if (narudzbaId <= 0 || kolicina <= 0 || dijeloviId <= 0) {
      return {'poruka': "Pogresni podatci"};
    }

    final String baseUrl = '${HelperService.baseUrl}/NarudzbaDijelovi';
    final Uri uri = Uri.parse(baseUrl);

    final Map<String, dynamic> requestBody = {
      'narudzbaId': narudzbaId.toString(),
      'dijeloviId': dijeloviId.toString(),
      'kolicina': kolicina.toString(),
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
        return {'poruka': "Uspjesno dodata narudba"};
      } else if (response.statusCode == 400) {
        // Rukovanje greškama validacije sa servera
        final errorData = jsonDecode(responseBody);
        return {
          'poruka': errorData['message'] ?? "Greska prilikom dodavanja",
        };
      } else {
        return {'poruka': "Greska prilikom dodavanja"};
      }
    } on TimeoutException catch (_) {
      return {'poruka': "Greska prilikom dodavanja: Server nije dostupan"};
    } catch (e) {
      logger.e("Greška pri dodavanju bicikla: $e");
      return {'poruka': e.toString()};
    } finally {
      httpClient.close();
    }
  }

  Future<Map<String, dynamic>> getNarudbaDijeloviById(
      int narudzbaDijeloviId) async {
    final String url =
        '${HelperService.baseUrl}/NarudzbaDijelovi/$narudzbaDijeloviId';

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
}
