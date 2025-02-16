// ignore_for_file: unused_field, prefer_const_declarations, use_rethrow_when_possible, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DijeloviPromocijaService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();
//
  DijeloviPromocijaService() : _dio = Dio() {
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

  Future<String> postPromocijaDijelovi({
    required int brojDana,
    required int? dijeloviId,
  }) async {
    DateTime datumPocetka = DateTime.now();
    DateTime datumZavrsetka = datumPocetka.add(Duration(days: brojDana));

    final String baseUrl = '${HelperService.baseUrl}/PromocijaDijelovi';
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

      final Uri uri = Uri.parse(baseUrl);

      final Map<String, dynamic> requestBody = {
        'dijeloviId': dijeloviId.toString(),
        'datumPocetka': datumPocetka.toIso8601String(),
        'datumZavrsetka': datumZavrsetka.toIso8601String(),
      };

      final request = await httpClient.openUrl('POST', uri);

      final String authHeader = _dio.options.headers['Authorization'];
      request.headers.set('Authorization', authHeader);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('accept', 'application/json');

      request.add(utf8.encode(jsonEncode(requestBody)));

      final response = await request.close();

      if (response.statusCode != 200) {
        return "Greska prilikom dodavanja promocije";
      }

      return "Uspjesno dodana promocija bicikla";
    } on TimeoutException catch (_) {
      return "Greska prilikom dodavanja promocije: Server nije dostupan";
    } catch (e) {
      logger.e("Greška pri dodavanju promocije bicikla: $e");
      return "Greska prilikom dodavanja promocije";
    } finally {
      httpClient.close();
    }
  }

  Future<bool> isPromovisan({required int dijeloviId}) async {
    final Map<String, dynamic> queryParams = {
      'dijeloviId': dijeloviId.toString(),
    };

    Uri uri = Uri.parse('${HelperService.baseUrl}/PromocijaDijelovi');
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
        final List<dynamic> promotions = data['resultsList'] ?? [];
        for (var item in promotions) {
          if (item['status'] != 'vracen' &&
              item['status'] != 'obrisan' &&
              item['status'] != 'zavrseno') {
            return true;
          }
        }
        return false;
      } else {
        throw Exception(
            'Failed to check promotion status: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception(
          'Failed to check promotion status: Server is not available');
    } catch (e) {
      logger.e('Greška: $e');
      throw Exception('Failed to check promotion status: $e');
    } finally {
      ioClient.close();
    }
  }
}
