// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, use_build_context_synchronously, deprecated_member_use

import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';

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
    required String status,
    required int biciklId,
  }) async {
    try {
      // Dodaj Authorization header prije slanja zahtjeva
      await _addAuthorizationHeader();

      final queryParameters = <String, dynamic>{
        'korisnikId': korisnikId,
        if (biciklId != 0) 'BiciklId': biciklId,
      };

      final response = await _dio.get(
        '${HelperService.baseUrl}/SpaseniBicikli',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        final List<Map<String, dynamic>> spaseniBicikli =
            List<Map<String, dynamic>>.from(response.data['resultsList']);

        List<Map<String, dynamic>> filtriraniBicikli = spaseniBicikli.toList();
        if(status.isEmpty){
          filtriraniBicikli = filtriraniBicikli
          .where((bicikl) => bicikl['status'] != 'obrisan')
          .toList();
        }
        else{
          filtriraniBicikli = filtriraniBicikli
          .where((bicikl) => bicikl['status'] == 'obrisan')
          .toList();
          return filtriraniBicikli;
        }

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
  Future<void> updateSpaseniBicikl(int idSpasenogBicikla, int biciklId, String datumSpasavanja, int korisnikId) async {
    try {
      await _addAuthorizationHeader();

      final data = {
        'biciklId': biciklId,
        'datumSpasavanja': datumSpasavanja,
        'korisnikId': korisnikId,
      };

      final response = await _dio.put(
        '${HelperService.baseUrl}/SpaseniBicikli/$idSpasenogBicikla',
        data: data,
      );

      if (response.statusCode == 200) {
        // Ažuriraj lokalnu listu ako je potrebno
        final index = listaUcitanihSpasenihBicikli.value.indexWhere((bicikl) => bicikl['id'] == idSpasenogBicikla);
        if (index != -1) {
          listaUcitanihSpasenihBicikli.value[index] = data;
          listaUcitanihSpasenihBicikli.notifyListeners();
        }
        logger.i('Sačuvani bicikl uspješno ažuriran.');
      } else {
        throw Exception('Neuspješno ažuriranje sačuvanog bicikla.');
      }
    } catch (e) {
      logger.e('Greška pri ažuriranju sačuvanog bicikla: $e');
    }
  }
  
  Future<bool> addSpaseniBicikl(BuildContext context, int biciklID, int korisnikId) async {
    String trenutniDatum = DateTime.now().toIso8601String().split('T').first;
    var spaseniBicikli = await getSpaseniBicikli(
      korisnikId: korisnikId,
      status: "obrisan",
      biciklId: biciklID,
    );

    bool postojiBicikl = spaseniBicikli.any((bicikl) =>
        bicikl['biciklId'] == biciklID && bicikl['status'] == 'obrisan');
    if (postojiBicikl) {
      int idSpasenogBicikla = spaseniBicikli[0]['spaseniBicikliId'];
      await updateSpaseniBicikl(idSpasenogBicikla, biciklID, trenutniDatum, korisnikId);
      PorukaHelper.prikaziPorukuUspjeha(context, 'Bicikl uspješno sačuvan.');
      return true;
    }

    try {
      await _addAuthorizationHeader();
      final data = {
        'biciklId': biciklID,
        'datumSpasavanja': trenutniDatum,
        'korisnikId': korisnikId,
      };
      final response = await _dio.post(
        '${HelperService.baseUrl}/SpaseniBicikli',
        data: data,
      );

      if (response.statusCode == 200) {
        logger.i('Bicikl uspješno sačuvan.');
        PorukaHelper.prikaziPorukuUspjeha(context, 'Bicikl uspješno sačuvan.');
        return true; // Uspješno
      } else {
        throw Exception('Neuspješno čuvanje bicikla.');
      }
    } catch (e) {
      String errorMessage = 'Došlo je do greške pri čuvanja bicikla.';
      if (e is DioError && e.response != null && e.response!.data != null) {
        var errorData = e.response!.data;
        if (errorData['errors'] != null && errorData['errors']['userError'] != null) {
          errorMessage = errorData['errors']['userError'][0];
        }
      }
      
      logger.e('Greška pri čuvanju bicikla: $errorMessage');
      PorukaHelper.prikaziPorukuGreske(context, errorMessage); // Prikazuje grešku korisniku
      return false; // Neuspješno
    }
  }

}
