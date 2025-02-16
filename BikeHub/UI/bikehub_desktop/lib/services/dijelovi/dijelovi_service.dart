// ignore_for_file: unnecessary_null_comparison

import 'package:bikehub_desktop/modeli/dijelovi/dijelovi_model.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';

class DijeloviService {
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

  Future<Map<String, dynamic>?> postDijelovi(Dijelovi dijeloviData) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.post(
        '${HelperService.baseUrl}/Dijelovi',
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Content-Type': 'application/json',
          },
        ),
        data: dijeloviData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> bicikl = response.data;
        return bicikl;
      } else {
        throw Exception('Failed to create bicikl');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  // ignore: non_constant_identifier_names
  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_dijelova = ValueNotifier([]);
  List<dynamic> listaDijelova = [];
  int count = 0;
  Future<List<Map<String, dynamic>>> getDijelovi({
    String? naziv,
    int? korisnikId,
    String? status = "aktivan",
    double? pocetnaCijena,
    double? krajnjaCijena,
    int? kolicina,
    String? opis,
    int? kategorijaId,
    List<int>? korisniciId,
    int? page = 0,
    int? pageSize = 10,
    bool isSlikaIncluded = true,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (naziv != null) queryParameters['Naziv'] = naziv;
      if (korisnikId != null) queryParameters['KorisnikId'] = korisnikId;
      if (status != null) queryParameters['Status'] = status;
      if (pocetnaCijena != null) queryParameters['pocetnaCijena'] = pocetnaCijena;
      if (krajnjaCijena != null) queryParameters['krajnjaCijena'] = krajnjaCijena;
      if (kolicina != null) queryParameters['Kolicina'] = kolicina;
      if (opis != null) queryParameters['Opis'] = opis;
      if (kategorijaId != null) queryParameters['KategorijaId'] = kategorijaId;
      if (korisniciId != null) queryParameters['korisniciId'] = korisniciId;
      if (isSlikaIncluded != null) queryParameters['isSlikaIncluded'] = isSlikaIncluded;

      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Dijelovi',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        listaDijelova = response.data['resultsList'] ?? [];
        count = response.data['count'];
        List<Map<String, dynamic>> dijelovi = List<Map<String, dynamic>>.from(response.data['resultsList']);
        if (korisniciId != null && korisniciId.isNotEmpty) {
          final filteredDijelovi = dijelovi.where((dio) {
            return korisniciId.contains(dio['korisnikId']);
          }).toList();

          lista_ucitanih_dijelova.value = filteredDijelovi;
          dijelovi = lista_ucitanih_dijelova.value;
        } else {
          lista_ucitanih_dijelova.value = dijelovi;
        }
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_dijelova.notifyListeners();
        return dijelovi;
      } else {
        throw Exception('Failed to load dijelovi');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDijeloviById(int dioId) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/Dijelovi/$dioId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dio = response.data;
        return dio;
      } else {
        throw Exception('Failed to load dio');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<void> removeDijelovi(int idDijelovi) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.delete(
        '${HelperService.baseUrl}/Dijelovi/$idDijelovi',
      );

      if (response.statusCode == 200) {
        lista_ucitanih_dijelova.value.removeWhere((dijelovi) => dijelovi['id'] == idDijelovi);
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_dijelova.notifyListeners();
        logger.i('Dio uspješno uklonjen.');
      } else {
        throw Exception('Neuspješno uklanjanje  dijela.');
      }
    } catch (e) {
      logger.e('Greška pri uklanjanju  dijela: $e');
    }
  }

  Future<void> upravljanjeDijelom(Dijelovi dijeloviModel) async {
    try {
      await _addAuthorizationHeader();

      if (dijeloviModel.ak == 1) {
        if (dijeloviModel.stanje == "aktivan") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Dijelovi/aktivacija/${dijeloviModel.dijeloviId}',
            queryParameters: {'aktivacija': true},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Dijelovi uspješno aktiviran');
          } else {
            throw Exception('Greška pri aktivaciji Dijelova');
          }
        } else if (dijeloviModel.stanje == "vracen") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Dijelovi/aktivacija/${dijeloviModel.dijeloviId}',
            queryParameters: {'aktivacija': false},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Dijelovi uspješno vraćeni');
          } else {
            throw Exception('Greška pri vraćanju Dijelova');
          }
        } else if (dijeloviModel.stanje == "obrisan") {
          final response = await _dio.delete(
            '${HelperService.baseUrl}/Dijelovi/${dijeloviModel.dijeloviId}',
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Dijelovi uspješno obrisani');
          } else {
            throw Exception('Greška pri brisanju Dijelova');
          }
        }
      }
    } catch (e) {
      logger.e('Greška: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<Map<String, dynamic>?> putDijelovi(
    int dijeloviId,
    String naziv,
    int cijena,
    String opis,
    int kategorijaId,
    int korisnikId,
    int kolicina,
  ) async {
    if (dijeloviId == 0 || korisnikId == 0) {
      return null;
    }
    if (naziv.isEmpty && cijena == 0 && opis.isEmpty && kolicina == 0 && kategorijaId == 0 && kolicina == 0) {
      return null;
    }
    try {
      await _addAuthorizationHeader();

      final data = <String, dynamic>{};
      data['korisnikId'] = korisnikId;

      if (naziv.isNotEmpty) {
        data['naziv'] = naziv;
      }
      if (cijena != 0) {
        data['cijena'] = cijena;
      }
      if (opis.isNotEmpty) {
        data['opis'] = opis;
      }
      if (kategorijaId != 0) {
        data['kategorijaId'] = kategorijaId;
      }
      if (kolicina != 0) {
        data['kolicina'] = kolicina;
      }

      final response = await _dio.put(
        '${HelperService.baseUrl}/Dijelovi/$dijeloviId',
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = response.data;
        return result;
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<String?> deleteDijelovi(int dijeloviId) async {
    if (dijeloviId == 0) {
      return null;
    }
    try {
      await _addAuthorizationHeader();

      final response = await _dio.delete(
        '${HelperService.baseUrl}/Dijelovi/$dijeloviId',
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final String result = response.data;
        return result;
      } else {
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }
}
