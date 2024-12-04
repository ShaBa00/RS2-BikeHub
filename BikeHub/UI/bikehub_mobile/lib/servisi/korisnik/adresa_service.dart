// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';
import 'package:bikehub_mobile/servisi/ostalo/helper_service.dart';

class AdresaServis {
  final logger = Logger();

  Future<Map<String, dynamic>?> getAdresa(
      {int? korisnikId,
      String? grad,
      String? postanskiBroj,
      String? ulica,
      String? status,
      int? page,
      int? pageSize}) async {
    final Map<String, dynamic> queryParams = {};

    if (korisnikId != null) queryParams['korisnikId'] = korisnikId.toString();
    if (grad != null) queryParams['grad'] = grad;
    if (postanskiBroj != null) queryParams['postanskiBroj'] = postanskiBroj;
    if (ulica != null) queryParams['ulica'] = ulica;
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['pageSize'] = pageSize.toString();

    // Ručno sastavljanje URL-a
    Uri uri = Uri.parse('${HelperService.baseUrl}/Adresa');
    uri = uri.replace(queryParameters: queryParams);

    final String url = uri.toString();

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    final IOClient ioClient = IOClient(httpClient);

    try {
      final http.Response response = await ioClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['resultsList'] != null && data['resultsList'].isNotEmpty) {
          return data['resultsList'][0];
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load address: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Failed to load address: Server is not available');
    } catch (e) {
      logger.e('Greška: $e');
      throw Exception('Failed to load address: $e');
    } finally {
      ioClient.close();
    }
  }
}
