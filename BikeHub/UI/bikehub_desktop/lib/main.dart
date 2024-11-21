import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/pocetni_prozor.dart';
import 'services/bicikli/bicikl_notifier.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BiciklNotifier()), 
      ],
      child: const MyApp(),
    ),
  );
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
