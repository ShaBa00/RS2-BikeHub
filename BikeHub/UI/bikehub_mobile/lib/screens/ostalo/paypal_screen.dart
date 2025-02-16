// File: paypal_screen.dart
// ignore_for_file: unused_field, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PayPalScreen extends StatefulWidget {
  final double totalAmount;

  PayPalScreen({super.key, required this.totalAmount});

  @override
  _PayPalScreenState createState() => _PayPalScreenState();
}

class _PayPalScreenState extends State<PayPalScreen> {
  bool isLoading = true;
  late final double _totalAmount;
  late WebViewController _controller;

  final String clientId =
      'AQ_tU1xavnIwPZhAE4tc4WHwu9MqKz5vCIIGO6tM8MC3hRQXsZ7KzcPDm3J3F4wS1luocGtS08ffq6km';
  final String clientSecret =
      'EKFd1B6JdUyy8Hpr2xW1rTAUYIcW23MpRN-3uP7_k5N5AaXiXW_X7kav-zaR_fgs7OU2IlT_bgFGctTC';

  final String _paypalBaseUrl = 'https://api.sandbox.paypal.com'; // Sandbox URL

  @override
  void initState() {
    super.initState();
    _totalAmount = widget.totalAmount;
    _startPaymentProcess();
  }

  Future<void> _startPaymentProcess() async {
    try {
      final accessToken = await _getAccessToken();
      final orderUrl = await _createOrder(accessToken, _totalAmount);
      _redirectToPayPal(orderUrl);
    } catch (e) {
      print("Error during PayPal payment process: $e");
    }
  }

  Future<String> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('$_paypalBaseUrl/v1/oauth2/token'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to obtain PayPal access token');
    }
  }

  Future<String> _createOrder(String accessToken, double total) async {
    final response = await http.post(
      Uri.parse('$_paypalBaseUrl/v2/checkout/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'intent': 'CAPTURE',
        'purchase_units': [
          {
            'amount': {
              'currency_code': 'USD',
              'value': total.toStringAsFixed(2),
            },
          },
        ],
        'application_context': {
          'return_url': 'https://example.com/return',
          'cancel_url': 'https://example.com/cancel',
        }
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final approvalUrl =
          data['links'].firstWhere((link) => link['rel'] == 'approve')['href'];
      return approvalUrl;
    } else {
      throw Exception('Failed to create PayPal order');
    }
  }

  void _redirectToPayPal(String approvalUrl) {
    final webviewController = _createWebViewController(approvalUrl);

    Navigator.of(context).push(MaterialPageRoute(builder: (builder) {
      return Scaffold(
        body: WebViewWidget(
          controller: webviewController,
        ),
      );
    })).then((result) {
      // Odmah se vraćamo na prethodni ekran nakon navigacije
      Navigator.of(context).pop(result);
    });
  }

  WebViewController _createWebViewController(String approvalUrl) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith('https://example.com/return')) {
              Navigator.of(context).pop({
                'status': 'success'
              }); // Povratak na prethodni ekran s uspjehom
            }

            if (url.startsWith('https://example.com/cancel')) {
              Navigator.of(context).pop({
                'status': 'cancel'
              }); // Povratak na prethodni ekran s otkazivanjem
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
