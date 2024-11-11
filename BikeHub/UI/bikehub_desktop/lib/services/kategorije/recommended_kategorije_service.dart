import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class RecommendedKategorijaService {
  final Dio _dio = Dio();
  final logger = Logger();

  final ValueNotifier<List<Map<String, dynamic>>> recommendedBicikliList = ValueNotifier([]);

  Future<void> getRecommendedBiciklList(int dijeloviId) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/RecommendedKategorija/GetRecommendedBiciklList',
        queryParameters: {'DijeloviID': dijeloviId},
      );

      if (response.statusCode == 200) {
        recommendedBicikliList.value = List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load recommended bicikl list');
      }
    } catch (e) {
      logger.e('Greška: $e');
    }
  }

  final ValueNotifier<List<Map<String, dynamic>>> recommendedDijeloviList = ValueNotifier([]);
  Future<void>  getRecommendedDijeloviList(int biciklId) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/RecommendedKategorija/GetRecommendedDijeloviList',
        queryParameters: {'BiciklID': biciklId},
      );

      if (response.statusCode == 200) {
        recommendedDijeloviList.value= List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load recommended dijelovi list');
      }
    } catch (e) {
      logger.e('Greška: $e');
    }
  }
}
