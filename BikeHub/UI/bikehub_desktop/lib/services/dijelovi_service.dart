import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DijeloviService {
  final String baseUrl = 'http://localhost:5033';
  final Dio _dio = Dio();
  final logger = Logger();

  Future<List<Map<String, dynamic>>> getDijelovi() async {
    try {
      final response = await _dio.get('$baseUrl/Dijelovi');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['resultsList']);
      } else {
        throw Exception('Failed to load dijelovi');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }
}
