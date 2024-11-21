import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatelessWidget {
  final String approvalUrl;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  WebViewPage({required this.approvalUrl});

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: approvalUrl,
      // ignore: prefer_const_constructors
      appBar: AppBar(title: Text('PayPal Payment')),
    );
  }
}