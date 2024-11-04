import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ostalo/helper_service.dart';

class PromocijaDijeloviService {
  Future<List<dynamic>> getPromocijaDijelovi() async {
    final response = await http.get(Uri.parse('${HelperService.baseUrl}/PromocijaDijelovi'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['resultsList'];
    } else {
      throw Exception("Failed to load Promocija Dijelovi");
    }
  }
}
