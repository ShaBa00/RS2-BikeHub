import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';
import 'package:flutter/foundation.dart';

class AdresaService {
  final Dio _dio = Dio();
  final logger = Logger();
  final KorisnikService _korisnikService = KorisnikService();

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
      if (postanskiBroj != null) {
        queryParameters['PostanskiBroj'] = postanskiBroj;
      }
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
        final List<Map<String, dynamic>> gradKorisniciDto = List<Map<String, dynamic>>.from(response.data.map((grad) => {
              "GradId": grad['gradId'],
              "Grad": grad['grad'],
              "KorisnikIds": List<int>.from(grad['korisnikIds']),
            }));
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

  Future<void> addAdresa(int korisnikId, String grad, String ulica, String postanskiBroj) async {
    try {
      // Dodavanje Authorization headera
      await _addAuthorizationHeader();
      if (korisnikId == 0 || grad.isEmpty || ulica.isEmpty || postanskiBroj.isEmpty) {
        throw Exception('Potrebno je unjeti sve podatke: grad, ulica, postanskiBroj.');
      }

      final body = <String, dynamic>{
        'korisnikId': korisnikId,
        'grad': grad,
        'ulica': ulica,
        'postanskiBroj': postanskiBroj,
      };
      // Slanje POST zahtjeva
      final response = await _dio.post(
        '${HelperService.baseUrl}/Adresa',
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

  Future<String> postAdresa({
    required int korisnikId,
    required String grad,
    required String postanskiBroj,
    required String ulica,
  }) async {
    try {
      await _addAuthorizationHeader();
      final response = await _dio.post(
        '${HelperService.baseUrl}/Adresa',
        data: {
          'korisnikId': korisnikId,
          'grad': grad,
          'postanskiBroj': postanskiBroj,
          'ulica': ulica,
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
      logger.e("Greska pri dodavanju adrese: $e");
      return 'Greska pri dodavanju adrese: $e';
    }
  }

  Future<void> updateAdresa(int adresaId, String grad, String ulica, String postanskiBroj) async {
    try {
      // Dodavanje Authorization headera
      await _addAuthorizationHeader();
      if (adresaId == 0) {
        return;
      }
      if (grad.isEmpty && ulica.isEmpty && postanskiBroj.isEmpty) {
        throw Exception('Potrebno je promjenuti barem jedan zapis');
      }
      // Priprema body za slanje
      final body = <String, String>{};
      if (grad.isNotEmpty) {
        body['grad'] = grad;
      }
      if (ulica.isNotEmpty) {
        body['ulica'] = ulica;
      }
      if (postanskiBroj.isNotEmpty) {
        body['postanskiBroj'] = postanskiBroj;
      }

      // Slanje POST zahtjeva
      final response = await _dio.put(
        '${HelperService.baseUrl}/Adresa/$adresaId',
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
}
