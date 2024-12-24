import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:bikehub_desktop/services/ostalo/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class KorisnikInfoService {
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

  Future<void> addInfo(int korisnikId, String imePrezime, String telefon) async {
    try {
      // Dodavanje Authorization headera
      await _addAuthorizationHeader();
      if (korisnikId == 0 || imePrezime.isEmpty || telefon.isEmpty) {
        throw Exception('Potrebno je unjeti sve podatke: korisnikId, Ime i Prezime, Telefon.');
      }

      final body = <String, dynamic>{
        'korisnikId': korisnikId,
        'imePrezime': imePrezime,
        'telefon': telefon,
      };
      // Slanje POST zahtjeva
      final response = await _dio.post(
        '${HelperService.baseUrl}/KorisnikInfo',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      // Provjera statusa odgovora
      if (response.statusCode == 200) {
        logger.i('Podatci uspješno promjenjeni.');
      } else {
        throw Exception('Neuspješno dodavanje podataka.');
      }
    } catch (e) {
      logger.e('Greška prilikom dodavanja podataka: $e');
    }
  }

  Future<void> updateInfo(int korisnikInfoId, String imePrezime, String telefon) async {
    try {
      // Dodavanje Authorization headera
      await _addAuthorizationHeader();
      if (korisnikInfoId == 0) {
        return;
      }
      if (imePrezime.isEmpty && telefon.isEmpty) {
        throw Exception('Potrebno je promjenuti barem jedan zapis');
      }
      // Priprema body za slanje
      final body = <String, String>{};
      if (imePrezime.isNotEmpty) {
        body['imePrezime'] = imePrezime;
      }
      if (telefon.isNotEmpty) {
        body['telefon'] = telefon;
      }

      // Slanje POST zahtjeva
      final response = await _dio.put(
        '${HelperService.baseUrl}/KorisnikInfo/$korisnikInfoId',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      // Provjera statusa odgovora
      if (response.statusCode == 200) {
        logger.i('Podatci uspješno promjenjeni.');
      } else {
        throw Exception('Neuspješno dodavanje podataka.');
      }
    } catch (e) {
      logger.e('Greška prilikom dodavanja podataka: $e');
    }
  }

  Future<String> postKorisnikinfo({
    required int korisnikId,
    required String imePrezime,
    required String telefon,
  }) async {
    try {
      await _addAuthorizationHeader();
      final response = await _dio.post(
        '${HelperService.baseUrl}/KorisnikInfo',
        data: {
          'korisnikId': korisnikId,
          'imePrezime': imePrezime,
          'telefon': telefon,
        },
        options: Options(
          headers: {
            'Authorization': _dio.options.headers['Authorization'],
          },
        ),
      );

      if (response.statusCode == 200) {
        return 'Uspjesno';
      } else {
        final errorMessage = response.data['errors'] != null ? response.data['errors']['userError'].join(', ') : 'Nepoznata greska';
        return errorMessage;
      }
    } catch (e) {
      logger.e("Greska pri dodavanju korisnickih informacija: $e");
      return 'Greska pri dodavanju korisnickih informacija: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getKorisnikInfos({
    String? imePrezime,
    String? status, //="aktivan",
    String? telefon,
    int? brojNarudbi,
    int? brojServisa,
    int? korisnikId,
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (imePrezime != null) queryParameters['ImePrezime'] = imePrezime;
      if (status != null) queryParameters['Status'] = status;
      if (telefon != null) queryParameters['Telefon'] = telefon;
      if (brojNarudbi != null) queryParameters['BrojNarudbi'] = brojNarudbi;
      if (brojServisa != null) queryParameters['BrojServisa'] = brojServisa;
      if (korisnikId != null) queryParameters['KorisnikId'] = korisnikId;

      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/KorisnikInfo',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> korisnikInfos = List<Map<String, dynamic>>.from(response.data['resultsList']);

        return korisnikInfos;
      } else {
        throw Exception('Failed to load bicikli');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }
}
