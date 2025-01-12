import 'package:bikehub_desktop/modeli/serviseri/serviser_model.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';

class ServiserService {
  final Dio _dio = Dio();
  final logger = Logger();

  final KorisnikService _korisnikService = KorisnikService();
  final ValueNotifier<List<Map<String, dynamic>>> listaUcitanihServisera = ValueNotifier([]);
  List<dynamic> listaServisra = [];
  int count = 0;

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

  Future<String?> dodajServisera(int korisnikId, double cijena) async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.post(
        '${HelperService.baseUrl}/Serviser',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'korisnikId': korisnikId,
          'cijena': cijena,
        },
      );

      if (response.statusCode == 200) {
        return "Zahtjev uspjesno poslan";
      } else {
        final errors = response.data['errors'];
        if (errors != null && errors['userError'] != null) {
          return errors['userError'].join(', ');
        } else {
          return 'Došlo je do greške prilikom dodavanja servisera';
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

  Future<List<Map<String, dynamic>>> getServiseriDTO({
    String? username,
    String? status, //="aktivan",
    double? pocetnaCijena,
    double? krajnjaCijena,
    double? pocetnaOcjena,
    double? krajnjaOcjena,
    int? pocetniBrojServisa,
    int? korisnikId,
    int? krajnjiBrojServisa,
    List<int>? korisniciId,
    int? page = 1,
    int? pageSize = 5,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (username != null) queryParameters['Username'] = username;
      if (status != null) queryParameters['Status'] = status;
      if (pocetnaCijena != null) queryParameters['PocetnaCijena'] = pocetnaCijena;
      if (krajnjaCijena != null) queryParameters['KrajnjaCijena'] = krajnjaCijena;

      if (pocetniBrojServisa != null) queryParameters['PocetniBrojServisa'] = pocetniBrojServisa;
      if (krajnjiBrojServisa != null) queryParameters['KrajnjiBrojServisa'] = krajnjiBrojServisa;

      if (pocetnaOcjena != null) queryParameters['PocetnaOcjena'] = pocetnaOcjena;
      if (krajnjaOcjena != null) queryParameters['KrajnjaOcjena'] = krajnjaOcjena;

      if (korisniciId != null) queryParameters['korisniciId'] = korisniciId;
      if (korisnikId != null) queryParameters['korisnikId'] = korisnikId;
      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Serviser/GetServiserDTOList',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        listaServisra = response.data['resultsList'] ?? [];
        count = response.data['count'];
        List<Map<String, dynamic>> serviseri = List<Map<String, dynamic>>.from(response.data['resultsList']);
        if (korisniciId != null && korisniciId.isNotEmpty) {
          final filteredDijelovi = serviseri.where((dio) {
            return korisniciId.contains(dio['korisnikId']);
          }).toList();

          listaUcitanihServisera.value = filteredDijelovi;
          serviseri = listaUcitanihServisera.value;
        } else {
          listaUcitanihServisera.value = serviseri;
        }
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        listaUcitanihServisera.notifyListeners();
        return serviseri;
      } else {
        throw Exception('Failed to load serviseri');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getServiserDtoByKorisnikId({
    int? serviserId,
    int? page = 1,
    int? pageSize = 5,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (serviserId != null) queryParameters['serviserId'] = serviserId;
      queryParameters['Page'] = page;
      queryParameters['PageSize'] = pageSize;

      final response = await _dio.get(
        '${HelperService.baseUrl}/Serviser/GetServiserDTOList',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final listaServisra = response.data['resultsList'] ?? [];
        if (listaServisra.isNotEmpty) {
          return listaServisra[0];
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load serviseri');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getServiserByID(int serviserID) async {
    try {
      final response = await _dio.get(
        '${HelperService.baseUrl}/Serviser/$serviserID',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> serviser = response.data;
        return serviser;
      } else {
        throw Exception('Failed to load korisnik');
      }
    } catch (e) {
      logger.e('Greška: $e');
      return null;
    }
  }

  Future<void> upravljanjeServiserom(ServiserModel serviser) async {
    try {
      await _addAuthorizationHeader();

      if (serviser.ak == 1) {
        if (serviser.stanje == "aktivan") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Serviser/aktivacija/${serviser.serviserId}',
            queryParameters: {'aktivacija': true},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Serviser uspješno aktiviran');
          } else {
            throw Exception('Greška pri aktivaciji Servisera');
          }
        } else if (serviser.stanje == "vracen") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/Serviser/aktivacija/${serviser.serviserId}',
            queryParameters: {'aktivacija': false},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Serviser uspješno vraćeni');
          } else {
            throw Exception('Greška pri vraćanju Servisera');
          }
        } else if (serviser.stanje == "obrisan") {
          final response = await _dio.delete(
            '${HelperService.baseUrl}/Serviser/${serviser.serviserId}',
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Serviser uspješno obrisani');
          } else {
            throw Exception('Greška pri brisanju Servisera');
          }
        }
      }
    } catch (e) {
      logger.e('Greška: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<Map<String, dynamic>> getServiserIzvjestaj() async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.get('${HelperService.baseUrl}/Serviser/izvjestaj-serviser');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to load Izvjestaj Promocija");
      }
    } catch (e) {
      logger.e('Greška: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }
}
