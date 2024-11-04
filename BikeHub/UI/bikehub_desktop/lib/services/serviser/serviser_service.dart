import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';

class ServiserService {
  final Dio _dio = Dio();
  final logger = Logger();

  final ValueNotifier<List<Map<String, dynamic>>> listaUcitanihServisera = ValueNotifier([]);
  int count = 0;

  Future<List<Map<String, dynamic>>> getServiseriDTO({
    String? username,
    String? status,//="aktivan",
    double? pocetnaCijena,
    double? krajnjaCijena,
    double? pocetnaOcjena,
    double? krajnjaOcjena,
    int? pocetniBrojServisa,
    int? krajnjiBrojServisa,
    List<int>? korisniciId,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (username != null) queryParameters['Username'] = username;
      if (status != null) queryParameters['Status'] = status;
      if (pocetnaCijena != null) queryParameters['PocetnaCijena'] = pocetnaCijena;
      if (krajnjaCijena != null) queryParameters['KrajnjaCijena'] = krajnjaCijena;

      if (pocetniBrojServisa != null) queryParameters['PocetniBrojServisa'] = pocetniBrojServisa;
      if (krajnjiBrojServisa != null) queryParameters['KrajnjiBrojServisa'] = krajnjiBrojServisa;

      if (pocetnaOcjena != null) queryParameters['PocetnaOcjena'] = pocetnaOcjena;
      if (krajnjaOcjena != null) queryParameters['KrajnjaOcjena'] = krajnjaOcjena;

      if (korisniciId != null) queryParameters['korisniciId'] = korisniciId;
      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Serviser/GetServiserDTOList',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        List<Map<String, dynamic>> serviseri = List<Map<String, dynamic>>.from(response.data['resultsList']);
        if (korisniciId != null && korisniciId.isNotEmpty) {
          final filteredDijelovi = serviseri.where((dio) {
            return korisniciId.contains(dio['korisnikId']);
          }).toList();
          
          listaUcitanihServisera.value = filteredDijelovi;
          serviseri=listaUcitanihServisera.value;
        }
        else{
        listaUcitanihServisera.value = serviseri;
        }
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        listaUcitanihServisera.notifyListeners();
        return serviseri;
      } else {
        throw Exception('Failed to load serviseri');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }
}
