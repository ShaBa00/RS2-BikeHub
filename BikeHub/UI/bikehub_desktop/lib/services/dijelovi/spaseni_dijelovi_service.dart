// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, use_build_context_synchronously

import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:flutter/widgets.dart';

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
    required String status,
    required int dijeloviId
  }) async {
    try {

      await _addAuthorizationHeader();

      final queryParameters = <String, dynamic>{
        'KorisnikId': korisnikId,
        if (dijeloviId != 0) 'BiciklId': dijeloviId,
      };

      final response = await _dio.get(
        '${HelperService.baseUrl}/SpaseniDijelovi',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        final List<Map<String, dynamic>> spaseniDijelovi =
            List<Map<String, dynamic>>.from(response.data['resultsList']);
            
        List<Map<String, dynamic>> filtriraniDijelovi = spaseniDijelovi.toList();
        if(status.isEmpty){
          filtriraniDijelovi = filtriraniDijelovi
          .where((dijelovi) => dijelovi['status'] != 'obrisan')
          .toList();
        }
        else{
          filtriraniDijelovi = filtriraniDijelovi
          .where((dijelovi) => dijelovi['status'] == 'obrisan')
          .toList();
          return filtriraniDijelovi;
        }

        listaUcitanihSpasenihDijelova.value = filtriraniDijelovi;
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
        
        listaUcitanihSpasenihDijelova.notifyListeners();
        logger.i('Sačuvani dio uspješno uklonjen.');
      } else {
        throw Exception('Neuspješno uklanjanje sačuvanog dijela.');
      }
    } catch (e) {
      logger.e('Greška pri uklanjanju sačuvanog dijela: $e');
    }
  }

  Future<bool> addSpaseniDijelovi(BuildContext context, int dijeloviId, int korisnikId) async {

    String trenutniDatum = DateTime.now().toIso8601String().split('T').first;
    var spaseniDijelovi = await getSpaseniDijelovi(
      korisnikId: korisnikId,
      status: "obrisan",
      dijeloviId: dijeloviId,
    );

    bool postojiDio = spaseniDijelovi.any((dijelovi) =>
        dijelovi['dijeloviId'] == dijeloviId && dijelovi['status'] == 'obrisan');
    if (postojiDio) {
      int idSpasenogDijela = spaseniDijelovi[0]['spaseniDijeloviId'];
      await updateSpaseniBicikl(idSpasenogDijela, dijeloviId, trenutniDatum, korisnikId);
      PorukaHelper.prikaziPorukuUspjeha(context, 'Dijelovi uspješno sačuvan.');
      return true;
    }

    try {
      await _addAuthorizationHeader();
      final data = {
        'dijeloviId': dijeloviId,
        'datumSpasavanja': trenutniDatum,
        'korisnikId': korisnikId,
      };
      final response = await _dio.post(
        '${HelperService.baseUrl}/SpaseniDijelovi',
        data: data,
      );

      if (response.statusCode == 200) {
        logger.i('Dijelovi uspješno sačuvani.');
        PorukaHelper.prikaziPorukuUspjeha(context, 'Dijelovi uspješno sačuvani.');
        return true; // Uspješno
      } else {
        throw Exception('Neuspješno čuvanje dijelova.');
      }
    } catch (e) {
      String errorMessage = 'Došlo je do greške pri čuvanja dijelova.';
      if (e is DioException  && e.response != null && e.response!.data != null) {
        var errorData = e.response!.data;
        if (errorData['errors'] != null && errorData['errors']['userError'] != null) {
          errorMessage = errorData['errors']['userError'][0];
        }
      }
      
      logger.e('Greška pri čuvanju dijelova: $errorMessage');
      PorukaHelper.prikaziPorukuGreske(context, errorMessage); // Prikazuje grešku korisniku
      return false; // Neuspješno
    }
  }

  Future<void> updateSpaseniBicikl(int idSpasenogDijela, int dijeloviId, String datumSpasavanja, int korisnikId) async {
    try {
      await _addAuthorizationHeader();

      final data = {
        'dijeloviId': dijeloviId,
        'datumSpasavanja': datumSpasavanja,
        'korisnikId': korisnikId,
      };

      final response = await _dio.put(
        '${HelperService.baseUrl}/SpaseniDijelovi/$idSpasenogDijela',
        data: data,
      );

      if (response.statusCode == 200) {
        // Ažuriraj lokalnu listu ako je potrebno
        final index = listaUcitanihSpasenihDijelova.value.indexWhere((dijelovi) => dijelovi['id'] == idSpasenogDijela);
        if (index != -1) {
          listaUcitanihSpasenihDijelova.value[index] = data;
          listaUcitanihSpasenihDijelova.notifyListeners();
        }
        logger.i('Sačuvani dijelovi uspješno ažuriran.');
      } else {
        throw Exception('Neuspješno ažuriranje sačuvanog dijela.');
      }
    } catch (e) {
      logger.e('Greška pri ažuriranju sačuvanog dijela: $e');
    }
  }

}
