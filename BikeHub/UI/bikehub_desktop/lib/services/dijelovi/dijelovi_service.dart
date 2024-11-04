import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class DijeloviService {
  final Dio _dio = Dio();
  final logger = Logger();

  // ignore: non_constant_identifier_names
  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_dijelova = ValueNotifier([]);
  int count=0;
  Future<List<Map<String, dynamic>>> getDijelovi({
    String? naziv,
    int? korisnikId,
    String? status="aktivan",
    double? pocetnaCijena,
    double? krajnjaCijena,
    int? kolicina,
    String? opis,
    int? kategorijaId,
    List<int>? korisniciId,
    int page = 0,
    int pageSize = 10,
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

      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Dijelovi',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        List<Map<String, dynamic>> dijelovi = List<Map<String, dynamic>>.from(response.data['resultsList']);
          if (korisniciId != null && korisniciId.isNotEmpty) {
            final filteredDijelovi = dijelovi.where((dio) {
            return korisniciId.contains(dio['korisnikId']);
            }).toList();
          
            lista_ucitanih_dijelova.value = filteredDijelovi;
            dijelovi=lista_ucitanih_dijelova.value;
          }
          else{
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
}
