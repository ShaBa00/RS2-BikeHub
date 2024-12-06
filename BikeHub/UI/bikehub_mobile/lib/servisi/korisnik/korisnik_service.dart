// ignore_for_file: unused_field, use_rethrow_when_possible, prefer_const_declarations, unnecessary_null_comparison, unnecessary_type_check

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KorisnikServis {
  final Dio _dio;
  final logger = Logger();
  final _storage = const FlutterSecureStorage();

  KorisnikServis() : _dio = Dio() {
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
    final loggedInStatus = await isLoggedIn();
    if (!loggedInStatus) {
      throw Exception("User not logged in");
    }

    // Dohvati korisničke podatke iz secure storage-a
    final korisnikInfo = await getUserInfo();
    final username = korisnikInfo['username'];
    final password = korisnikInfo['password'];

    if (username == null || password == null) {
      throw Exception("Missing credentials");
    }
    // Generiraj Authorization header
    final authHeader = encodeBasicAuth(username, password);
    _dio.options.headers['Authorization'] = authHeader;
  }

  String encodeBasicAuth(String username, String password) {
    final credentials = '$username:$password';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  Future<Map<String, String?>> getCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {'username': username, 'password': password};
  }

  Future<bool> isLoggedIn() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return username != null && password != null;
  }

  Future<Map<String, String?>> getUserInfo() async {
    final korisnikId = await _storage.read(key: 'korisnikId');
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    final isAdmin = await _storage.read(key: 'isAdmin');

    return {
      'korisnikId': korisnikId,
      'username': username,
      'password': password,
      'isAdmin': isAdmin,
    };
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '${HelperService.baseUrl}/Korisnik/login',
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> korisnik = response.data;
        // Pohrani korisničke podatke u secure storage
        await _storage.write(key: 'username', value: korisnik['username']);
        await _storage.write(
            key: 'password', value: password); // Pohranjujemo lozinku
        await _storage.write(
            key: 'korisnikId', value: korisnik['korisnikId'].toString());
        await _storage.write(
            key: 'isAdmin', value: korisnik['isAdmin'].toString());
        await _storage.write(
            key: 'token',
            value: korisnik['token']); // Možeš pohraniti token ako je potrebno
        return korisnik;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll(); // Briše sve podatke o korisniku
  }

  Future<Map<String, dynamic>> getKorisnikById(int korisnikId) async {
    final String url = '${HelperService.baseUrl}/Korisnik/$korisnikId';

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

  List<dynamic> listaKorisnika = [];
  List<dynamic> listaAdministratora = [];
  int countKorisnika = 0;

  Future<void> getKorisniks({String? status, int? page, int? pageSize}) async {
    final Map<String, dynamic> queryParams = {};

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (page != null) {
      queryParams['Page'] = page;
    }
    if (pageSize != null) {
      queryParams['PageSize'] = pageSize;
    }

    Uri uri = Uri.parse('${HelperService.baseUrl}/Korisnik');
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

        listaKorisnika = data['resultsList'] ?? [];
        countKorisnika = data['count'] ?? 0;

        listaAdministratora = data['resultsList']
            .where((korisnik) => korisnik['isAdmin'] == true)
            .toList();

        logger.i("Uspješno preuzeti korisnici: $listaKorisnika");
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri preuzimanju korisnika: $e");
    } finally {
      ioClient.close();
    }
  }

  Future<void> upravljanjeKorisnikom(String status, int odabraniId) async {
    final String baseUrl = '${HelperService.baseUrl}/Korisnik';
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
    } on TimeoutException catch (_) {
      throw Exception('Failed to load users: Server is not available');
    } catch (e) {
      logger.e("Greška pri ažuriranju statusa: $e");
      throw e;
    } finally {
      httpClient.close();
    }
  }

  Future<String?> postAdmina(String username, String lozinka,
      String lozinkaPotvrda, String email) async {
    final String baseUrl = '${HelperService.baseUrl}/Korisnik';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      await _addAuthorizationHeader();

      uri = Uri.parse('$baseUrl/NoviAdmin');

      final request = await httpClient.postUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode({
        'username': username,
        'lozinka': lozinka,
        'lozinkaPotvrda': lozinkaPotvrda,
        'email': email,
      }));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Administrator uspješno dodan";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Došlo je do greške prilikom dodavanja administratora';
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

  Future<String?> izmjeniKorisnika(
      String? email, String? username, int korisnikId) async {
    final String baseUrl = '${HelperService.baseUrl}/Korisnik';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      // Provjeri da li je poslan korisnikId
      if (korisnikId == 0) {
        return "Korisnik ID je obavezan";
      }

      // Provjeri da li je poslan barem jedan zapis za izmjenu
      if ((email == null || email.isEmpty) &&
          (username == null || username.isEmpty)) {
        return "Potrebno je izmjenuti barem jedan zapis";
      }

      // Dodavanje Authorization header-a
      await _addAuthorizationHeader();

      // Priprema body za slanje
      final body = <String, String>{};
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }
      if (username != null && username.isNotEmpty) {
        body['username'] = username;
      }

      uri = Uri.parse('$baseUrl/$korisnikId');

      final request = await httpClient.putUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Korisnik uspješno izmjenjen";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom izmjene korisnika';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError is HttpException && httpError.message != null) {
        return 'Greška prilikom izmjene korisnika: ${httpError.message}';
      }
      return 'Greška prilikom izmjene korisnika: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom izmjene korisnika: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }

  Future<String?> izmjeniLozinkuKorisnika(String? staraLozinka, String? lozinka,
      String? lozinkaPotvrda, int korisnikId) async {
    final String baseUrl = '${HelperService.baseUrl}/Korisnik';
    Uri uri;

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      if (korisnikId == 0) {
        return "Korisnik ID je obavezan";
      }

      // Provjeri da li je poslan barem jedan zapis za izmjenu
      if ((lozinka == null || lozinka.isEmpty) ||
          (lozinkaPotvrda == null || lozinkaPotvrda.isEmpty) ||
          (staraLozinka == null || staraLozinka.isEmpty)) {
        return "Za promjenu lozinke potrebno je unjeti sve podatke";
      }

      if (lozinka != lozinkaPotvrda) {
        return "Nova lozinka i potvrda moraju biti iste";
      }

      if (lozinka == staraLozinka) {
        return "Nova lozinka i stara lozinka moraju biti razlicite";
      }

      await _addAuthorizationHeader();

      // Priprema body za slanje
      final body = <String, String>{};
      if (lozinka != null && lozinka.isNotEmpty) {
        body['lozinka'] = lozinka;
      }
      if (lozinkaPotvrda != null && lozinkaPotvrda.isNotEmpty) {
        body['lozinkaPotvrda'] = lozinkaPotvrda;
      }
      if (staraLozinka != null && staraLozinka.isNotEmpty) {
        body['staraLozinka'] = staraLozinka;
      }

      uri = Uri.parse('$baseUrl/$korisnikId');

      final request = await httpClient.putUrl(uri);
      request.headers.set('accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers
          .set('Authorization', _dio.options.headers['Authorization']);

      request.write(jsonEncode(body));

      final response = await request.close();

      if (response.statusCode == 200) {
        return "Lozinka uspješno izmjenjena";
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedResponse = jsonDecode(responseBody);
        final errors = decodedResponse['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Greška prilikom izmjene lozinke';
        }
      }
    } on HttpException catch (httpError) {
      if (httpError is HttpException && httpError.message != null) {
        return 'Greška prilikom izmjene korisnika: ${httpError.message}';
      }
      return 'Greška prilikom izmjene korisnika: ${httpError.toString()}';
    } catch (e) {
      logger.e('Greška prilikom izmjene korisnika: $e');
      return e.toString();
    } finally {
      httpClient.close();
    }
  }
}
