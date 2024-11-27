// ignore_for_file: unnecessary_null_comparison

import 'package:bikehub_desktop/modeli/bicikli/bicikl_model.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class BiciklService {
  final Dio _dio = Dio();
  final logger = Logger();
  final KorisnikService _korisnikService = KorisnikService();

  // ignore: non_constant_identifier_names
  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_bicikala = ValueNotifier([]);
  List<dynamic> listaBicikala = [];
  int count=0;
  Future<List<Map<String, dynamic>>> getBicikli({
    String? naziv,
    String? status,//="aktivan",
    double? pocetnaCijena,
    double? krajnjaCijena,
    int? kolicina,
    int? korisnikId,
    String? velicinaRama,
    String? velicinaTocka,
    int? brojBrzina,
    int? kategorijaId,
    List<int>? korisniciId,
    int? page =0,
    int? pageSize =10,
    bool isSlikaIncluded=true,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (naziv != null) queryParameters['Naziv'] = naziv;
      if (status != null) queryParameters['Status'] = status;
      if (pocetnaCijena != null) queryParameters['pocetnaCijena'] = pocetnaCijena;
      if (krajnjaCijena != null) queryParameters['krajnjaCijena'] = krajnjaCijena;
      if (kolicina != null) queryParameters['Kolicina'] = kolicina;
      if (korisnikId != null) queryParameters['KorisnikId'] = korisnikId;
      if (velicinaRama != null) queryParameters['VelicinaRama'] = velicinaRama;
      if (velicinaTocka != null) queryParameters['VelicinaTocka'] = velicinaTocka;
      if (brojBrzina != null) queryParameters['BrojBrzina'] = brojBrzina;
      if (kategorijaId != null) queryParameters['KategorijaId'] = kategorijaId;
      if (korisniciId != null) queryParameters['korisniciId'] = korisniciId;
      if (isSlikaIncluded != null) queryParameters['isSlikaIncluded'] = isSlikaIncluded;

      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Bicikli',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        listaBicikala = response.data['resultsList'] ?? [];
        List<Map<String, dynamic>> bicikli = List<Map<String, dynamic>>.from(response.data['resultsList']);
        if (korisniciId != null && korisniciId.isNotEmpty) {
          final filteredBicikli = bicikli.where((bicikl) {
            return korisniciId.contains(bicikl['korisnikId']);
          }).toList();
          
          lista_ucitanih_bicikala.value = filteredBicikli;
          bicikli=lista_ucitanih_bicikala.value;
        }
        else{
        lista_ucitanih_bicikala.value = bicikli;
        }
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_bicikala.notifyListeners();
        return bicikli; 
      } else {
        throw Exception('Failed to load bicikli');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return []; 
    }
  }

  Future<List<Map<String, dynamic>>> getPromotedItems() async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/Bicikli/promoted-items',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load promoted items');
      }
    } catch (e) {
      logger.e('Greška prilikom dohvata promoviranih artikala: $e');
      return [];
    }
  }
  
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

  Future<Map<String, dynamic>?> postBicikl(Bicikl biciklData) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.post(
        '${HelperService.baseUrl}/Bicikli',
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Content-Type': 'application/json',
          },
        ),
        data: biciklData,
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

  Future<void> removeBicikl(int idBicikl) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.delete(
        '${HelperService.baseUrl}/Bicikli/$idBicikl',
      );

      if (response.statusCode == 200) {
        lista_ucitanih_bicikala.value.removeWhere((bicikl) => bicikl['id'] == idBicikl);
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_bicikala.notifyListeners();
        logger.i('Bicikl uspješno uklonjen.');
      } else {
        throw Exception('Neuspješno uklanjanje  bicikla.');
      }
    } catch (e) {
      logger.e('Greška pri uklanjanju  bicikla: $e');
    }
  }

  Future<void> upravljanjeBiciklom(Bicikl biciklModel) async {
    try {
      await _addAuthorizationHeader();

      if (biciklModel.ak == 1) {
        if (biciklModel.stanje == "aktivan") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Bicikli/aktivacija/${biciklModel.biciklId}',
            queryParameters: {'aktivacija': true},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Bicikl uspješno aktiviran');
          } else {
            throw Exception('Greška pri aktivaciji Bicikla');
          }
        } else if (biciklModel.stanje == "vracen") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Bicikli/aktivacija/${biciklModel.biciklId}',
            queryParameters: {'aktivacija': false},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Bicikl uspješno vraćen');
          } else {
            throw Exception('Greška pri vraćanju Bicikla');
          }
        } else if (biciklModel.stanje == "obrisan") {
          final response = await _dio.delete(
            '${HelperService.baseUrl}/Bicikli/${biciklModel.biciklId}',
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Bicikl uspješno obrisan');
          } else {
            throw Exception('Greška pri brisanju Bicikla');
          }
        }
      } 
    } catch (e) {
      logger.e('Greška: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getBiciklById(int biciklId) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/Bicikli/$biciklId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> bicikl = response.data;
        return bicikl;
      } else {
        throw Exception('Failed to load bicikl');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }
}
