import 'package:bikehub_desktop/modeli/korisnik/korisnik_model.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class KorisnikService {
  final Dio _dio = Dio();
  final logger = Logger();
  final _storage = const FlutterSecureStorage();

  List<dynamic> listaKorisnika = [];
  int countKorisnika = 0;
  List<dynamic> listaAdministratora = [];

  Future<void> getKorisniks({String? status, int? page, int? pageSize}) async {
    try {
      final queryParams = <String, dynamic>{};

      // Dodavanje query parametara samo ako su uneseni
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (page != null) {
        queryParams['Page'] = page;
      }
      if (pageSize != null) {
        queryParams['PageSize'] = pageSize;
      }

      final response = await _dio.get(
        '${HelperService.baseUrl}/Korisnik',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Postavljanje rezultata u varijable
        listaKorisnika = data['resultsList'] ?? [];
        countKorisnika = data['count'] ?? 0;

        listaAdministratora = data['resultsList'].where((korisnik) => korisnik['isAdmin'] == true).toList();

        logger.i("Uspješno preuzeti korisnici: $listaKorisnika");
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Greška pri preuzimanju korisnika: $e");
    }
  }

  Future<Response> _getWithBasicAuth(String url) async {
    final credentials = await getCredentials();
    final username = credentials['username'];
    final password = credentials['password'];

    if (username == null || password == null) {
      throw Exception("User not logged in");
    }

    final authHeader = encodeBasicAuth(username, password);
    _dio.options.headers['Authorization'] = authHeader; // Dodavanje Basic Auth headera

    return await _dio.get(url);
  }

  Future<bool> isLoggedIn() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return username != null && password != null;
  }

  Future<void> _addAuthorizationHeader() async {
    // Provjera da li je korisnik prijavljen
    final loggedInStatus = await isLoggedIn();
    if (!loggedInStatus) {
      throw Exception("User not logged in");
    }

    // Dohvati korisničke podatke iz secure storage-a
    final korisnikInfo = await getUserInfo();
    final username = korisnikInfo['username'];
    final password = korisnikInfo['password'];

    if (username == null || password == null) {
      throw Exception("Missing credentials");
    }
    // Generiraj Authorization header
    final authHeader = encodeBasicAuth(username, password);
    _dio.options.headers['Authorization'] = authHeader;
  }

  Future<void> upravljanjeKorisnikom(KorisnikModel korisnik) async {
    try {
      await _addAuthorizationHeader();

      if (korisnik.ak == 1) {
        if (korisnik.stanje == "aktivan") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Korisnik/aktivacija/${korisnik.korisnikId}',
            queryParameters: {'aktivacija': true},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Korisnik uspješno aktiviran');
          } else {
            throw Exception('Greška pri aktivaciji korisnika');
          }
        } else if (korisnik.stanje == "vracen") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Korisnik/aktivacija/${korisnik.korisnikId}',
            queryParameters: {'aktivacija': false},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Korisnik uspješno vraćen');
          } else {
            throw Exception('Greška pri vraćanju korisnika');
          }
        } else if (korisnik.stanje == "obrisan") {
          final response = await _dio.delete(
            '${HelperService.baseUrl}/Korisnik/${korisnik.korisnikId}',
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Korisnik uspješno obrisan');
          } else {
            throw Exception('Greška pri brisanju korisnika');
          }
        }
      } else {
        if (korisnik.username.isNotEmpty ||
            korisnik.email.isNotEmpty ||
            (korisnik.staraLozinka.isNotEmpty && korisnik.lozinka.isNotEmpty && korisnik.lozinkaPotvrda.isNotEmpty)) {
          final korisniciUpdateR = {
            'Username': korisnik.username,
            'StaraLozinka': korisnik.staraLozinka,
            'Lozinka': korisnik.lozinka,
            'LozinkaPotvrda': korisnik.lozinkaPotvrda,
            'Email': korisnik.email,
          };
          final response = await _dio.put(
            '${HelperService.baseUrl}/Korisnik/${korisnik.korisnikId}',
            data: korisniciUpdateR,
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Korisnik uspješno ažuriran');
          } else {
            throw Exception('Greška pri ažuriranju korisnika');
          }
        } else {
          throw Exception('Nedovoljno podataka za ažuriranje korisnika');
        }
      }
    } catch (e) {
      logger.e('Greška: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<String?> postAdmina(KorisnikModel korisnikModel) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.post(
        '${HelperService.baseUrl}/Korisnik/NoviAdmin',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: korisnikModel,
      );

      if (response.statusCode == 200) {
        return "Administrator uspješno dodan";
      } else {
        final errors = response.data['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Došlo je do greške prilikom dodavanja administratora';
        }
      }
    } on DioException catch (dioError) {
      if (dioError.response != null && dioError.response?.data != null) {
        final errors = dioError.response?.data['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        }
      }
      return 'Došlo je do greške: ${dioError.message}';
    } catch (e) {
      logger.e('Greška: $e');
      return e.toString();
    }
  }

  Future<Map<String, String?>> getCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {'username': username, 'password': password};
  }

  String encodeBasicAuth(String username, String password) {
    final credentials = '$username:$password';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  Future<Map<String, String?>> getUserInfo() async {
    final korisnikId = await _storage.read(key: 'korisnikId');
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    final isAdmin = await _storage.read(key: 'isAdmin');
    final status = await _storage.read(key: 'status');

    return {
      'korisnikId': korisnikId,
      'username': username,
      'password': password,
      'isAdmin': isAdmin,
      'status': status,
    };
  }

  Future<void> logout() async {
    await _storage.deleteAll(); // Briše sve podatke o korisniku
  }

  Future<Map<String, dynamic>?> getKorisnikInfo() async {
    try {
      final response = await _getWithBasicAuth('${HelperService.baseUrl}/Korisnik/info');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load korisnik info');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

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

  // Nova funkcija za login
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '${HelperService.baseUrl}/Korisnik/login',
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> korisnik = response.data;
        // Pohrani korisničke podatke u secure storage
        await _storage.write(key: 'username', value: korisnik['username']);
        await _storage.write(key: 'status', value: korisnik['status']);
        await _storage.write(key: 'password', value: password); // Pohranjujemo lozinku
        await _storage.write(key: 'korisnikId', value: korisnik['korisnikId'].toString());
        await _storage.write(key: 'isAdmin', value: korisnik['isAdmin'].toString());
        await _storage.write(key: 'token', value: korisnik['token']); // Možeš pohraniti token ako je potrebno
        return korisnik;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> postKorisnik({
    required String username,
    required String lozinka,
    required String lozinkaPotvrda,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '${HelperService.baseUrl}/Korisnik',
        data: {
          'username': username,
          'lozinka': lozinka,
          'lozinkaPotvrda': lozinkaPotvrda,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final korisnikId = data['korisnikId'] ?? 0;
        return {'korisnikId': korisnikId, 'poruka': 'Uspjesno'};
      } else {
        final errorMessage = response.data['errors'] != null ? response.data['errors']['userError'].join(', ') : 'Nepoznata greska';
        return {'korisnikId': 0, 'poruka': errorMessage};
      }
    } catch (e) {
      logger.e("Greska pri dodavanju korisnika: $e");
      return {'korisnikId': 0, 'poruka': 'Greska pri dodavanju korisnika: $e'};
    }
  }

  Future<bool> ceckKorisnikUsername({String? username}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (username != null && username.isNotEmpty) {
        queryParams['username'] = username;
      }

      final response = await _dio.get(
        '${HelperService.baseUrl}/Korisnik',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final resultsList = data['resultsList'] ?? [];

        if (resultsList.isNotEmpty) {
          logger.i("Uspješno preuzeti korisnici: $resultsList");
          return true;
        } else {
          return false;
        }
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.e("Greška pri preuzimanju korisnika: $e");
      return false;
    }
  }

  Future<bool> ceckKorisnikEmail({String? email}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (email != null && email.isNotEmpty) {
        queryParams['email'] = email;
      }

      final response = await _dio.get(
        '${HelperService.baseUrl}/Korisnik',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final resultsList = data['resultsList'] ?? [];

        if (resultsList.isNotEmpty) {
          logger.i("Uspješno preuzeti korisnici: $resultsList");
          return true;
        } else {
          return false;
        }
      } else {
        logger.e("Neuspješan zahtjev: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.e("Greška pri preuzimanju korisnika: $e");
      return false;
    }
  }
}
