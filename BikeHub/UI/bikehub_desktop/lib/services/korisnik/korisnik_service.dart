import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';

class KorisnikService {
  final Dio _dio = Dio();
  final logger = Logger();

  Future<Map<String, dynamic>?> getKorisnikByID(int korisnikId) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/Korisnik/$korisnikId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> korisnik = response.data;
        return korisnik;
      } else {
        throw Exception('Failed to load korisnik');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }
}