import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class BiciklService {
  final Dio _dio = Dio();
  final logger = Logger();

  // ignore: non_constant_identifier_names
  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_bicikala = ValueNotifier([]);
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
    int page = 0,
    int pageSize = 10,
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

      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Bicikli',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
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