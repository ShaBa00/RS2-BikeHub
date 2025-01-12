// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:bikehub_desktop/modeli/bicikli/bicikli_promocija_model.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../ostalo/helper_service.dart';

class PromocijaBicikliService {
  final Dio _dio = Dio();
  final logger = Logger();
  Future<void> _addAuthorizationHeader() async {
    final KorisnikService _korisnikService = KorisnikService();
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

  Future<List<dynamic>> getPromocijaBicikli() async {
    final response = await http.get(Uri.parse('${HelperService.baseUrl}/PromocijaBicikli'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['resultsList'];
    } else {
      throw Exception("Failed to load Promocija Bicikli");
    }
  }

  Future<Map<String, dynamic>> getPromocijaBicikliById(int biciklId) async {
    final response = await http.get(Uri.parse('${HelperService.baseUrl}/PromocijaBicikli?BiciklId=$biciklId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['count'] > 0) {
        return data['resultsList'][0];
      } else {
        throw Exception("No promotion found for the given bike ID");
      }
    } else {
      throw Exception("Failed to load Promocija Bicikli by ID");
    }
  }

  Future<void> upravljanjePromocijomBicikl(BicikliPromocijaModel serviser) async {
    try {
      await _addAuthorizationHeader();

      if (serviser.ak == 1) {
        if (serviser.stanje == "aktivan") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/PromocijaBicikli/aktivacija/${serviser.promocijaBicikliId}',
            queryParameters: {'aktivacija': true},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Promocija uspješno aktiviran');
          } else {
            throw Exception('Greška pri aktivaciji Promocije');
          }
        } else if (serviser.stanje == "vracen") {
          final response = await _dio.put(
            '${HelperService.baseUrl}/PromocijaBicikli/aktivacija/${serviser.promocijaBicikliId}',
            queryParameters: {'aktivacija': false},
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Promocija uspješno vraćeni');
          } else {
            throw Exception('Greška pri vraćanju Promocije');
          }
        } else if (serviser.stanje == "obrisan") {
          final response = await _dio.delete(
            '${HelperService.baseUrl}/PromocijaBicikli/${serviser.promocijaBicikliId}',
            options: Options(headers: {'accept': 'application/json'}),
          );

          if (response.statusCode == 200) {
            logger.i('Promocija uspješno obrisani');
          } else {
            throw Exception('Greška pri brisanju Promocije');
          }
        }
      }
    } catch (e) {
      logger.e('Greška: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<Map<String, dynamic>> getIzvjestajPromocije() async {
    try {
      await _addAuthorizationHeader();

      final response = await _dio.get('${HelperService.baseUrl}/PromocijaBicikli/izvjestaj-promocija');

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
