import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class SpaseniDijeloviService {
  final Dio _dio = Dio();
  final logger = Logger();
  final KorisnikService _korisnikService = KorisnikService();

  final ValueNotifier<List<Map<String, dynamic>>> listaUcitanihSpasenihDijelova = ValueNotifier([]);
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

  Future<List<Map<String, dynamic>>> getSpaseniDijelovi({
    required int korisnikId,
  }) async {
    try {

      await _addAuthorizationHeader();

      final queryParameters = <String, dynamic>{
        'KorisnikId': korisnikId,
      };

      final response = await _dio.get(
        '${HelperService.baseUrl}/SpaseniDijelovi',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        final List<Map<String, dynamic>> spaseniDijelovi =
            List<Map<String, dynamic>>.from(response.data['resultsList']);
            
        final List<Map<String, dynamic>> filtriraniDijelovi = spaseniDijelovi
          .where((dijelovi) => dijelovi['status'] != 'obrisan')
          .toList();

        listaUcitanihSpasenihDijelova.value = filtriraniDijelovi;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        listaUcitanihSpasenihDijelova.notifyListeners();
        return filtriraniDijelovi;
      } else {
        throw Exception('Failed to load spaseni dijelovi');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }

  Future<void> removeSpaseniDijelovi(int idSpasenogDijelovi) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.delete(
        '${HelperService.baseUrl}/SpaseniDijelovi/$idSpasenogDijelovi',
      );

      if (response.statusCode == 200) {
        listaUcitanihSpasenihDijelova.value.removeWhere((dijelovi) => dijelovi['id'] == idSpasenogDijelovi);
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        listaUcitanihSpasenihDijelova.notifyListeners();
        logger.i('Sačuvani dio uspješno uklonjen.');
      } else {
        throw Exception('Neuspješno uklanjanje sačuvanog dijela.');
      }
    } catch (e) {
      logger.e('Greška pri uklanjanju sačuvanog dijela: $e');
    }
  }
}
