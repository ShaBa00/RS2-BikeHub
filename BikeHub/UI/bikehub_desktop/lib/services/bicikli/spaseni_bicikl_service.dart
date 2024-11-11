// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class SpaseniBicikliService {
  final Dio _dio = Dio();
  final logger = Logger();
  final KorisnikService _korisnikService = KorisnikService();

  final ValueNotifier<List<Map<String, dynamic>>> listaUcitanihSpasenihBicikli = ValueNotifier([]);
  int count = 0;

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

  Future<List<Map<String, dynamic>>> getSpaseniBicikli({
    required int korisnikId,
  }) async {
    try {
      // Dodaj Authorization header prije slanja zahtjeva
      await _addAuthorizationHeader();

      final queryParameters = <String, dynamic>{
        'korisnikId': korisnikId,
      };

      final response = await _dio.get(
        '${HelperService.baseUrl}/SpaseniBicikli',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        final List<Map<String, dynamic>> spaseniBicikli =
            List<Map<String, dynamic>>.from(response.data['resultsList']);

        final List<Map<String, dynamic>> filtriraniBicikli = spaseniBicikli
          .where((bicikl) => bicikl['status'] != 'obrisan')
          .toList();

        listaUcitanihSpasenihBicikli.value = filtriraniBicikli;
        // ignoriraj za testiranje
        listaUcitanihSpasenihBicikli.notifyListeners();
        return filtriraniBicikli;
      } else {
        throw Exception('Failed to load spaseni bicikli');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }
  Future<void> removeSpaseniBicikl(int idSpasenogBicikla) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.delete(
        '${HelperService.baseUrl}/SpaseniBicikli/$idSpasenogBicikla',
      );

      if (response.statusCode == 200) {
        listaUcitanihSpasenihBicikli.value.removeWhere((bicikl) => bicikl['id'] == idSpasenogBicikla);
        listaUcitanihSpasenihBicikli.notifyListeners();
        logger.i('Sačuvani bicikl uspješno uklonjen.');
      } else {
        throw Exception('Neuspješno uklanjanje sačuvanog bicikla.');
      }
    } catch (e) {
      logger.e('Greška pri uklanjanju sačuvanog bicikla: $e');
    }
  }
}
