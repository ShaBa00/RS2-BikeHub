// ignore_for_file: unused_field, prefer_const_declarations, use_rethrow_when_possible, unnecessary_null_comparison, unused_element

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

class KategorijaRecommendedService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();
//
  KategorijaRecommendedService() : _dio = Dio() {
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

  List<dynamic> listaRecomendedBicikala = [];
  int countRecomendedBicikala = 0;

  Future<void> getRecommendedBiciklis({
    int? dijeloviId,
  }) async {
    String baseUrl =
        '${HelperService.baseUrl}/RecommendedKategorija/GetRecommendedBiciklList';
    String url =
        dijeloviId != null ? '$baseUrl?DijeloviID=$dijeloviId' : baseUrl;

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

        // Ažuriraj obradu podataka prema novom formatu odgovora
        listaRecomendedBicikala =
            data.map((item) => item as Map<String, dynamic>).toList();
        countRecomendedBicikala = listaRecomendedBicikala.length;

        logger.i("Uspješno preuzeti dijelovi:");
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

  List<dynamic> listaRecomendedDijelova = [];
  int countRecomendedDijelova = 0;

  Future<void> getRecommendedDijelovis({
    int? biciklID,
  }) async {
    String baseUrl =
        '${HelperService.baseUrl}/RecommendedKategorija/GetRecommendedDijeloviList';
    String url = biciklID != null ? '$baseUrl?BiciklID=$biciklID' : baseUrl;

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
        listaRecomendedDijelova =
            data.map((item) => item as Map<String, dynamic>).toList();
        countRecomendedDijelova = listaRecomendedDijelova.length;

        logger.i("Uspješno preuzeti dijelovi:");
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
}
