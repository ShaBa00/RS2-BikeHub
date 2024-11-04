import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class AdresaService {
  final Dio _dio = Dio();
  final logger = Logger();

  final ValueNotifier<List<Map<String, dynamic>>> listaUcitanihAdresa = ValueNotifier([]);
  int count = 0;

  Future<List<Map<String, dynamic>>> getAdrese({
    String? grad,
    String? postanskiBroj,
    String? ulica,
    String? status,
    int? adresaId,
    int? korisnikId,
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (grad != null) queryParameters['Grad'] = grad;
      if (postanskiBroj != null) queryParameters['PostanskiBroj'] = postanskiBroj;
      if (ulica != null) queryParameters['Ulica'] = ulica;
      if (status != null) queryParameters['Status'] = status;
      if (adresaId != null) queryParameters['AdresaId'] = adresaId;
      if (korisnikId != null) queryParameters['KorisnikId'] = korisnikId;

      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Adresa',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        count = response.data['count'];
        final List<Map<String, dynamic>> adrese = List<Map<String, dynamic>>.from(response.data['resultsList']);
        listaUcitanihAdresa.value = adrese;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        listaUcitanihAdresa.notifyListeners();
        return adrese;
      } else {
        throw Exception('Failed to load adrese');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }
  final ValueNotifier<List<Map<String, dynamic>>> listaGradKorisniciDto = ValueNotifier([]);

    Future<List<Map<String, dynamic>>> getGradKorisniciDto({
    int? gradId,
    String? grad,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (grad != null) queryParameters['Grad'] = grad;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Adresa/gradovi',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> gradKorisniciDto = List<Map<String, dynamic>>.from(
          response.data.map((grad) => {
            "GradId": grad['gradId'],
            "Grad": grad['grad'],
            "KorisnikIds": List<int>.from(grad['korisnikIds']),
          })
        );
        listaGradKorisniciDto.value = gradKorisniciDto;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        listaGradKorisniciDto.notifyListeners();
        return gradKorisniciDto;
      } else {
        throw Exception('Failed to load adrese');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }
  Future<Map<String, dynamic>?> getAdresaByKorisnikId(int korisnikId) async {
  try {
    final response = await _dio.get(
      '${HelperService.baseUrl}/Adresa',
      queryParameters: {'KorisnikId': korisnikId},
    );

    if (response.statusCode == 200) {
      if (response.data['resultsList'].isNotEmpty) {
        final Map<String, dynamic> adresa = response.data['resultsList'][0];
        return adresa;
      } else {
        throw Exception('No address found for the given user ID');
      }
    } else {
      throw Exception('Failed to load address');
    }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }
}
