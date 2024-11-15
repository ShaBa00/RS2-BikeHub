// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, non_constant_identifier_names

import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';


class RezervacijaServisaService {
  final Dio _dio = Dio();
  final logger = Logger();
  final KorisnikService _korisnikService = KorisnikService();
  int count=0;

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

  Future<void> dodajOcjenu(int rezervacijaId, int ocjena) async {
    try {
      // Dodavanje Authorization headera
      await _addAuthorizationHeader();
      if(ocjena<1 && ocjena >5) {
        return;
      }
      // Priprema body za slanje
      final body = {
        'ocjena': ocjena,
      };

      // Slanje POST zahtjeva
      final response = await _dio.put(
        '${HelperService.baseUrl}/RezervacijaServisa/$rezervacijaId',
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
        logger.i('Ocjena uspješno dodana.');
      } else {
        throw Exception('Neuspješno dodavanje ocjene.');
      }
    } catch (e) {
      logger.e('Greška prilikom dodavanja ocjene: $e');
    }
  }

 
  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_rezervacija = ValueNotifier([]);
  Future<Map<String, dynamic>?> getRezervacije({
    int? serviserId,
    int? korisnikId,
    double? ocjena,
    String? status,
    int page = 0,
    int pageSize = 5,
  }) async {
    try {
      await _addAuthorizationHeader();

      final queryParams = <String, dynamic>{};

      if (serviserId != null) queryParams['ServiserId'] = serviserId;
      if (korisnikId != null) queryParams['KorisnikId'] = korisnikId;
      if (ocjena != null) queryParams['Ocjena'] = ocjena;
      if (status != null) queryParams['Status'] = status;

      queryParams['Page'] = page;
      queryParams['PageSize'] = pageSize;

      // Pošalji GET zahtev
      final response = await _dio.get(
        '${HelperService.baseUrl}/RezervacijaServisa',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        count = response.data['count'];

        List<Map<String, dynamic>> lista = List<Map<String, dynamic>>.from(response.data['resultsList']);
        
        lista_ucitanih_rezervacija.value= lista;
        lista_ucitanih_rezervacija.notifyListeners();

        final Map<String, dynamic> data = response.data;
        return data;
      } else {
        throw Exception('Failed to fetch rezervacije servisa');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<List<int>> getSlobodniDani({
    required int serviserId,
    required int mjesec,
    required int godina,
  }) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/RezervacijaServisa/slobodni-dani',
        queryParameters: {
          'serviserId': serviserId,
          'mjesec': mjesec,
          'godina': godina,
        },
      );

      if (response.statusCode == 200) {
        final List<int> slobodniDani = List<int>.from(response.data);
        return slobodniDani;
      } else {
        throw Exception('Failed to load slobodni dani');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }

  Future<bool> postaviStanje(int idRezervacije, String stanje) async {
    try {
      await _addAuthorizationHeader();

      final pathMap = {
        "aktivan": "/RezervacijaServisa/aktivacija/$idRezervacije",
        "vracen": "/RezervacijaServisa/aktivacija/$idRezervacije",
        "zavrseno": "/RezervacijaServisa/zavrsi/$idRezervacije",
        "obrisan": "/RezervacijaServisa/$idRezervacije"
      };

      final queryParameters = (stanje == "aktivan" || stanje == "vracen")
          ? {'aktivacija': stanje == "aktivan"}
          : null;

      Response response;

      if (stanje == "obrisan") {
        response = await _dio.delete(
          '${HelperService.baseUrl}${pathMap[stanje]}',
          options: Options(headers: {'accept': 'application/json'}),
        );
      } else {
        response = await _dio.put(
          '${HelperService.baseUrl}${pathMap[stanje]}',
          queryParameters: queryParameters,
          options: Options(headers: {'accept': 'application/json'}),
        );
      }

      if (response.statusCode == 200) {
        logger.i('Rezervacija status updated successfully');
        return true;
      } else {
        throw Exception('Failed to update rezervacija status');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return false;
    }
  }


  Future<bool> rezervisi({
    required int korisnikId,
    required int serviserId,
    required DateTime datumRezervacije,
  }) async {
    try {
      await _addAuthorizationHeader();

      // Kreiraj JSON tijelo zahtjeva
      final data = {
        "korisnikId": korisnikId,
        "serviserId": serviserId,
        "datumRezervacije": datumRezervacije.toIso8601String(),
      };

      // Pošalji POST zahtjev
      final response = await _dio.post(
        '${HelperService.baseUrl}/RezervacijaServisa',
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        logger.i('Rezervacija uspješno kreirana');
        return true;
      } else {
        throw Exception('Failed to create rezervacija');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return false;
    }
  }
}
