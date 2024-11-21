
// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

class PayPalServis {
  final String clientId = 'AZTwj2Q5A3x2PONONzImLVHzEUsqMzeAx6JvtgBZqEEl4-_u0puY0MUOU5N3RWGnijN75D39-k9HkL2O';
  final String clientSecret = 'EGtpQlU01_uMJpyfpcWym1PtWbCOeBuKfVyDcF1XDTc0XJ9n8heWs85sgVH2w1kx5eYnZ42Yo13Zqc68';
  final String _paypalBaseUrl = 'https://api.sandbox.paypal.com';

  Future<String> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('$_paypalBaseUrl/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['access_token'];
    } else {
      throw Exception('Failed to obtain access token');
    }
  }

  Future<void> pokreniPlacanje(int cijena, int brojDana) async {

    final accessToken = await _getAccessToken();

    final transaction = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {"total": cijena.toString(), "currency": "USD"},
          "description": "Plaćanje za $brojDana dana"
        }
      ],
      "redirect_urls": {
        "return_url": "https://example.com/return",
        "cancel_url": "https://example.com/cancel"
      }
    };

    final response = await http.post(
      Uri.parse('$_paypalBaseUrl/v1/payments/payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode(transaction),
    );

    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      final approvalUrl = body['links'].firstWhere((link) => link['rel'] == 'approval_url')['href'];
      print("Approval URL: $approvalUrl");
      // Otvorite approvalUrl u web pretraživaču ili WebView-u
    } else {
      throw Exception('Failed to create payment');
    }
  }
}

