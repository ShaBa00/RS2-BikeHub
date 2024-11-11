import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class KategorijaServis {
  final Dio _dio = Dio();
  final logger = Logger();

  // ignore: non_constant_identifier_names
  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_kategorija = ValueNotifier([]);

  Future<List<Map<String, dynamic>>> getBikeKategorije() async {
    try {
      final response = await _dio.get('${HelperService.baseUrl}/Kategorija');

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> kategorije = List<Map<String, dynamic>>.from(response.data['resultsList'])
            .where((kategorija) => kategorija['isBikeKategorija'] == true)
            .toList();
        lista_ucitanih_kategorija.value = kategorije;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_kategorija.notifyListeners();
        return kategorije;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      logger.e('Error: $e');
      return [];
    }
  }
  // ignore: non_constant_identifier_names
  final ValueNotifier<List<Map<String, dynamic>>> lista_ucitanih_d_kategorija = ValueNotifier([]);
  Future<List<Map<String, dynamic>>> getDijeloviKategorije() async {
    try {
      final response = await _dio.get('${HelperService.baseUrl}/Kategorija');

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> kategorije = List<Map<String, dynamic>>.from(response.data['resultsList'])
            .where((kategorija) => kategorija['isBikeKategorija'] == false)
            .toList();
        lista_ucitanih_d_kategorija.value = kategorije;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        lista_ucitanih_d_kategorija.notifyListeners();
        return kategorije;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      logger.e('Error: $e');
      return [];
    }
  }
}
