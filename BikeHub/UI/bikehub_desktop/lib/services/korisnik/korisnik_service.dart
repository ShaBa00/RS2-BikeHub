import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class KorisnikService {
  final Dio _dio = Dio();
  final logger = Logger();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String?>> _getCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {'username': username, 'password': password};
  }

  String encodeBasicAuth(String username, String password) {
    final credentials = '$username:$password';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
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

  Future<Response> _getWithBasicAuth(String url) async {
    final credentials = await _getCredentials();
    final username = credentials['username'];
    final password = credentials['password'];

    if (username == null || password == null) {
      throw Exception("User not logged in");
    }

    final authHeader = encodeBasicAuth(username, password);
    _dio.options.headers['Authorization'] = authHeader; // Dodavanje Basic Auth headera

    return await _dio.get(url);
  }

  Future<bool> isLoggedIn() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return username != null && password != null;
  }
  Future<void> logout() async {
    await _storage.deleteAll(); // Briše sve podatke o korisniku
  }

  Future<Map<String, dynamic>?> getKorisnikInfo() async {
    try {
      final response = await _getWithBasicAuth('${HelperService.baseUrl}/Korisnik/info');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load korisnik info');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getKorisnikByID(int korisnikId) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/Korisnik/$korisnikId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> korisnik = response.data;
        return korisnik;
      } else {
        throw Exception('Failed to load korisnik');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  // Nova funkcija za login
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
        await _storage.write(key: 'password', value: password);  // Pohranjujemo lozinku
        await _storage.write(key: 'korisnikId', value: korisnik['korisnikId'].toString());
        await _storage.write(key: 'isAdmin', value: korisnik['isAdmin'].toString());
        await _storage.write(key: 'token', value: korisnik['token']);  // Možeš pohraniti token ako je potrebno
        return korisnik;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }
}