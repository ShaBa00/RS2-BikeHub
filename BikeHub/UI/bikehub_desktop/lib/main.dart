import 'package:flutter/material.dart';
import 'screens/pocetni_prozor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BikeHub Desktop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PocetniProzor(), 
    );
  }
}
