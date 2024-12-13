// ignore_for_file: unused_field, prefer_const_declarations, use_rethrow_when_possible

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:dio/io.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiciklSlikeService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();
//
  BiciklSlikeService() : _dio = Dio() {
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

  Future<String> postSlikeBicikl({
    required List<String> slike,
    required String biciklId,
  }) async {
    // Provjera podataka
    if (slike.isEmpty || biciklId.isEmpty) {
      return "Pogresni podatci";
    }

    final String baseUrl = '${HelperService.baseUrl}/SlikeBicikli';
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

      for (String slika in slike) {
        final Uri uri = Uri.parse(baseUrl);

        final Map<String, dynamic> requestBody = {
          'biciklId': biciklId,
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
      return "Greska prilikom dodavanja";
    } finally {
      httpClient.close();
    }
  }
}
