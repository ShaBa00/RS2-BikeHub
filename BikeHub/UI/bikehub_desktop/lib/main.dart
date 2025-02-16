import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/pocetni_prozor.dart';
import 'services/bicikli/bicikl_notifier.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowToFullScreen();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BiciklNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

void setWindowToFullScreen() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final screen = await getScreenList();
    if (screen.isNotEmpty) {
      final screenFrame = screen.first.frame;
      setWindowFrame(screenFrame);
    }
  });
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
