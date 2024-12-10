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

class KategorijaServis {
  final logger = Logger();
  final KorisnikServis _korisnikService = KorisnikServis();
  final Dio _dio;

  KategorijaServis() : _dio = Dio() {
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

  List<dynamic> listaKategorija = [];

  Future<List<Map<String, dynamic>>?> getKategorije(
      {String? ulica,
      String? status,
      bool? isBikeKategorija,
      int? page,
      int? pageSize}) async {
    final Map<String, dynamic> queryParams = {};
    if (ulica != null) queryParams['ulica'] = ulica;
    if (status != null) queryParams['status'] = status;
    if (isBikeKategorija != null) {
      queryParams['isBikeKategorija'] = isBikeKategorija.toString();
    }
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['pageSize'] = pageSize.toString();

    // Ručno sastavljanje URL-a
    Uri uri = Uri.parse('${HelperService.baseUrl}/Kategorija');
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
          return List<Map<String, dynamic>>.from(data['resultsList']);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load categories: Server is not available');
    } catch (e) {
      logger.e('Greška: $e');
      throw Exception('Failed to load categories: $e');
    } finally {
      ioClient.close();
    }
  }

  Future<Map<String, dynamic>> getKategorijaById(int kategorijaId) async {
    final String url = '${HelperService.baseUrl}/Kategorija/$kategorijaId';

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
