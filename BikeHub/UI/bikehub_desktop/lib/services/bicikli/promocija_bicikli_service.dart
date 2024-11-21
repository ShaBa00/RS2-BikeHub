import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ostalo/helper_service.dart';

class PromocijaBicikliService {
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
}
