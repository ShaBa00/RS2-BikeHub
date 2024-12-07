// ignore_for_file: unused_field, prefer_const_declarations, use_rethrow_when_possible, unnecessary_null_comparison, unnecessary_type_check

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiserService {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();
  final KorisnikServis _korisnikService = KorisnikServis();

  ServiserService() : _dio = Dio() {
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

  List<dynamic> listaServisera = [];
  int countServisera = 0;
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

  Future<Map<String, dynamic>?> getServiseriDTOById({
    int? serviserId,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (serviserId != null) queryParams['serviserId'] = serviserId.toString();

    Uri uri = Uri.parse('${HelperService.baseUrl}/Serviser/GetServiserDTOList');
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
        final data = jsonDecode(response.body);

        var serviseri = data['resultsList'] ?? [];

        logger.i("Uspješno preuzeti serviseri: $listaServisera");

        // Vrati prvi zapis iz liste
        if (serviseri.isNotEmpty) {
          return serviseri.first;
        } else {
          return null;
        }
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
        return null;
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri preuzimanju servisera: $e");
      return null;
    } finally {
      ioClient.close();
    }
  }

  Future<Map<String, dynamic>?> getServiseriDTOByKorisnikId({
    int? korisnikId,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (korisnikId != null) queryParams['korisnikId'] = korisnikId.toString();

    Uri uri = Uri.parse('${HelperService.baseUrl}/Serviser/GetServiserDTOList');
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
        final data = jsonDecode(response.body);

        var serviseri = data['resultsList'] ?? [];

        logger.i("Uspješno preuzeti serviseri: $serviseri");

        // Vrati prvi zapis iz liste
        if (serviseri.isNotEmpty) {
          return serviseri.first;
        } else {
          return null;
        }
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
        return null;
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri preuzimanju servisera: $e");
      return null;
    } finally {
      ioClient.close();
    }
  }

  Future<void> getServiseriDTO({
    String? username,
    String? status, //="aktivan",
    double? pocetnaCijena,
    double? krajnjaCijena,
    double? pocetnaOcjena,
    double? krajnjaOcjena,
    int? pocetniBrojServisa,
    int? korisnikId,
    int? serviserId,
    int? krajnjiBrojServisa,
    int? page = 1,
    int? pageSize = 5,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (username != null) queryParams['Username'] = username;
    if (status != null) queryParams['Status'] = status;
    if (pocetnaCijena != null) {
      queryParams['PocetnaCijena'] = pocetnaCijena.toString();
    }
    if (krajnjaCijena != null) {
      queryParams['KrajnjaCijena'] = krajnjaCijena.toString();
    }

    if (pocetniBrojServisa != null) {
      queryParams['PocetniBrojServisa'] = pocetniBrojServisa.toString();
    }
    if (krajnjiBrojServisa != null) {
      queryParams['KrajnjiBrojServisa'] = krajnjiBrojServisa.toString();
    }

    if (pocetnaOcjena != null) {
      queryParams['PocetnaOcjena'] = pocetnaOcjena.toString();
    }
    if (krajnjaOcjena != null) {
      queryParams['KrajnjaOcjena'] = krajnjaOcjena.toString();
    }

    if (korisnikId != null) queryParams['korisnikId'] = korisnikId.toString();
    if (serviserId != null) queryParams['serviserId'] = serviserId.toString();
    if (page == null) {
      queryParams['Page'] = "";
    } else {
      queryParams['Page'] = page.toString();
    }
    if (pageSize == null) {
      queryParams['PageSize'] = "";
    } else {
      queryParams['PageSize'] = pageSize.toString();
    }

    Uri uri = Uri.parse('${HelperService.baseUrl}/Serviser/GetServiserDTOList');
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
        final data = jsonDecode(response.body);

        listaServisera = data['resultsList'] ?? [];
        countServisera = data['count'] ?? 0;

        logger.i("Uspješno preuzeti serviseri: $listaServisera");
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri preuzimanju servisera: $e");
    } finally {
      ioClient.close();
    }
  }

  Future<HttpClientResponse> upravljanjeServiserom(
      String status, int odabraniId) async {
    final String baseUrl = '${HelperService.baseUrl}/Serviser';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader(); // Dodavanje authorization header-a

      if (status == "aktivan") {
        uri = Uri.parse('$baseUrl/aktivacija/$odabraniId')
            .replace(queryParameters: {'aktivacija': 'true'});
      } else if (status == "vracen") {
        uri = Uri.parse('$baseUrl/aktivacija/$odabraniId')
            .replace(queryParameters: {'aktivacija': 'false'});
      } else if (status == "obrisan") {
        uri = Uri.parse('$baseUrl/$odabraniId');
      } else {
        throw Exception('Nevažeći status');
      }

      final request = await httpClient.openUrl(
        status == "obrisan"
            ? 'DELETE'
            : 'PUT', // Odabir metode temeljem statusa
        uri,
      );

      final String authHeader = _dio.options.headers['Authorization'];
      request.headers.set('Authorization', authHeader);
      request.headers.set('accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        logger.i("Status uspješno ažuriran");
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
      }

      return response; // Dodana povratna vrijednost
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri ažuriranju statusa: $e");
      throw e;
    } finally {
      httpClient.close();
    }
  }

  Future<List<int>> getSlobodniDani({
    required int serviserId,
    required int mjesec,
    required int godina,
  }) async {
    final Map<String, dynamic> queryParams = {};

    queryParams['serviserId'] = serviserId.toString();
    queryParams['mjesec'] = mjesec.toString();
    queryParams['godina'] = godina.toString();

    Uri uri =
        Uri.parse('${HelperService.baseUrl}/RezervacijaServisa/slobodni-dani');
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
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<int> slobodniDani = List<int>.from(responseData);
        return slobodniDani;
      } else {
        throw Exception('Failed to load slobodni dani');
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      throw Exception('Failed to load slobodni dani');
    } finally {
      ioClient.close();
    }
  }

  Future<String?> editServiser(double cijena, int serviserId) async {
    final String baseUrl = HelperService.baseUrl;
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

      uri = Uri.parse('$baseUrl/Serviser/$serviserId');

      final request = await httpClient.putUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode({'cijena': cijena}));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Serviser uspješno izmjenjen";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Došlo je do greške prilikom izmjene servisera';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError is HttpException && httpError.message != null) {
        return 'Došlo je do greške: ${httpError.message}';
      }
      return 'Došlo je do greške: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
