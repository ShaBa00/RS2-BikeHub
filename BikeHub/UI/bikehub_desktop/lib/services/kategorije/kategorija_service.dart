// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class KategorijaServis {
  final Dio _dio = Dio();
  final logger = Logger();
  final KorisnikService _korisnikService = KorisnikService();

  Future<void> _addAuthorizationHeader() async {
    // Provjera da li je korisnik prijavljen
    final isLoggedIn = await _korisnikService.isLoggedIn();
    if (!isLoggedIn) {
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

  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_kategorija = ValueNotifier([]);

  Future<List<Map<String, dynamic>>> getBikeKategorije() async {
    try {
      final response = await _dio.get('${HelperService.baseUrl}/Kategorija');

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> kategorije =
            List<Map<String, dynamic>>.from(response.data['resultsList']).where((kategorija) => kategorija['isBikeKategorija'] == true).toList();
        lista_ucitanih_kategorija.value = kategorije;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_kategorija.notifyListeners();
        return kategorije;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      logger.e('Error: $e');
      return [];
    }
  }

  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_d_kategorija = ValueNotifier([]);
  Future<List<Map<String, dynamic>>> getDijeloviKategorije() async {
    try {
      final response = await _dio.get('${HelperService.baseUrl}/Kategorija');

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> kategorije =
            List<Map<String, dynamic>>.from(response.data['resultsList']).where((kategorija) => kategorija['isBikeKategorija'] == false).toList();
        lista_ucitanih_d_kategorija.value = kategorije;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_d_kategorija.notifyListeners();
        return kategorije;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      logger.e('Error: $e');
      return [];
    }
  }

  Future<String> addKategorija(String naziv, bool isBikeKategorija) async {
    try {
      // Dodavanje Authorization headera
      await _addAuthorizationHeader();
      if (naziv.isEmpty) {
        throw Exception('Potrebno je unjeti sve podatke');
      }

      final body = <String, dynamic>{
        'naziv': naziv,
        'isBikeKategorija': isBikeKategorija,
      };
      // Slanje POST zahtjeva
      final response = await _dio.post(
        '${HelperService.baseUrl}/Kategorija',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      // Provjera statusa odgovora
      if (response.statusCode == 200) {
        return "Uspjesno dodana kategorija";
      } else {
        if (response.data['errors'] != null) {
          // Dobivanje poruke greške iz odgovora
          var userErrors = response.data['errors']['userError'];
          if (userErrors != null && userErrors.isNotEmpty) {
            return userErrors[0];
          }
        }
        return 'Neuspješno dodavanje podataka';
      }
    } on DioError catch (e) {
      // Provjera ako postoji odgovor sa porukom greške
      if (e.response != null && e.response?.data['errors'] != null) {
        var userErrors = e.response?.data['errors']['userError'];
        if (userErrors != null && userErrors.isNotEmpty) {
          return userErrors[0];
        }
      }
      return 'Greška prilikom dodavanja podataka: ${e.message}';
    } catch (e) {
      return 'Greška prilikom dodavanja podataka: $e';
    }
  }

  Future<String> updateKategorija(int kategorijaId, String naziv, bool isBikeKategorija) async {
    try {
      // Dodavanje Authorization headera
      await _addAuthorizationHeader();
      if (naziv.isEmpty) {
        throw Exception('Potrebno je unjeti sve podatke');
      }

      final body = <String, dynamic>{
        'naziv': naziv,
        'isBikeKategorija': isBikeKategorija,
      };
      // Slanje PUT zahtjeva
      final response = await _dio.put(
        '${HelperService.baseUrl}/Kategorija/$kategorijaId',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      // Provjera statusa odgovora
      if (response.statusCode == 200) {
        return "Uspjesno ažurirana kategorija";
      } else {
        if (response.data['errors'] != null) {
          // Dobivanje poruke greške iz odgovora
          var userErrors = response.data['errors']['userError'];
          if (userErrors != null && userErrors.isNotEmpty) {
            return userErrors[0];
          }
        }
        return 'Neuspješno ažuriranje podataka';
      }
    } on DioError catch (e) {
      // Provjera ako postoji odgovor sa porukom greške
      if (e.response != null && e.response?.data['errors'] != null) {
        var userErrors = e.response?.data['errors']['userError'];
        if (userErrors != null && userErrors.isNotEmpty) {
          return userErrors[0];
        }
      }
      return 'Greška prilikom ažuriranja podataka: ${e.message}';
    } catch (e) {
      return 'Greška prilikom ažuriranja podataka: $e';
    }
  }

  Future<String> upravljanjeKategorijom(String status, int kategorijaId) async {
    try {
      await _addAuthorizationHeader();
      String url;
      String method;

      if (status == 'aktiviraj') {
        url = '${HelperService.baseUrl}/Kategorija/aktivacija/$kategorijaId?aktivacija=true';
        method = 'PUT';
      } else if (status == 'vrati') {
        url = '${HelperService.baseUrl}/Kategorija/aktivacija/$kategorijaId?aktivacija=false';
        method = 'PUT';
      } else if (status == 'obrisi') {
        url = '${HelperService.baseUrl}/Kategorija/$kategorijaId';
        method = 'DELETE';
      } else {
        throw Exception('Nepoznat status: $status');
      }

      Response response;
      if (method == 'PUT') {
        response = await _dio.put(url,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json',
              },
            ));
      } else {
        response = await _dio.delete(url,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json',
              },
            ));
      }

      // Provjera statusa odgovora
      if (response.statusCode == 200) {
        return "Uspješno izvršena operacija za kategoriju";
      } else {
        if (response.data['errors'] != null) {
          // Dobivanje poruke greške iz odgovora
          var userErrors = response.data['errors']['userError'];
          if (userErrors != null && userErrors.isNotEmpty) {
            return userErrors[0];
          }
        }
        return 'Neuspješno izvršavanje operacije';
      }
    } on DioError catch (e) {
      // Provjera ako postoji odgovor sa porukom greške
      if (e.response != null && e.response?.data['errors'] != null) {
        var userErrors = e.response?.data['errors']['userError'];
        if (userErrors != null && userErrors.isNotEmpty) {
          return userErrors[0];
        }
      }
      return 'Greška prilikom izvršavanja operacije: ${e.message}';
    } catch (e) {
      return 'Greška prilikom izvršavanja operacije: $e';
    }
  }
}
