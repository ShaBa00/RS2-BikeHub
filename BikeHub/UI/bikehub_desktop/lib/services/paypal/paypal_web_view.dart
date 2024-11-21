// ignore_for_file: unused_import, prefer_const_constructors, deprecated_member_use

import 'package:bikehub_desktop/services/paypal/paypal_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalPayment extends StatefulWidget {
  const PayPalPayment({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PayPalPaymentState createState() => _PayPalPaymentState();
}

class _PayPalPaymentState extends State<PayPalPayment> {
  String approvalUrl = "https://your-approval-url.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PayPal Plaćanje')),
      // ignore: unnecessary_null_comparison
      body: approvalUrl == null
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (await canLaunch(approvalUrl)) {
                    await launch(approvalUrl);
                  } else {
                    throw 'Could not launch $approvalUrl';
                  }
                },
                child: Text('Pokreni PayPal Plaćanje'),
              ),
            ),
    );
  }
}
