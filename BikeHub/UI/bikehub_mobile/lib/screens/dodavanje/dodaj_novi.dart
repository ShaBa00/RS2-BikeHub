import 'package:flutter/material.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';

class DodajNovi extends StatelessWidget {
  const DodajNovi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Novi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Dodaj Novi'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const GlavniProzor()),
                );
              },
              child: const Text('Nazad na Glavni Prozor'),
            ),
          ],
        ),
      ),
    );
  }
}
