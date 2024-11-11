import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';

class SlikeBicikliService {
  final Dio _dio = Dio();
  final logger = Logger();
  final KorisnikService _korisnikService = KorisnikService();

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

  Future<Map<String, dynamic>?> postBiciklSlika(int biciklId, String slika) async {
    try {
      await _addAuthorizationHeader();

      final data = {
        'biciklId': biciklId,
        'slika': slika,
      };

      final response = await _dio.post(
        '${HelperService.baseUrl}/SlikeBicikli',
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = response.data;
        return result;
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }
}
