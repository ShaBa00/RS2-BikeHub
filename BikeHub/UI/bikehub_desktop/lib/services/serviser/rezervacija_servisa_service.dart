import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';

class RezervacijaServisaService {
  final Dio _dio = Dio();
  final logger = Logger();

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
}
