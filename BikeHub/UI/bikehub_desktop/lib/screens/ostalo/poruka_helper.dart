import 'package:flutter/material.dart';

class PorukaHelper {
  static OverlayEntry? _trenutnaPoruka;

  static void prikaziPorukuUpozorenja(BuildContext context, String poruka) {
    _prikaziPoruku(context, poruka, const Color.fromARGB(255, 255, 255, 62).withOpacity(0.8), const Color.fromARGB(255, 0, 0, 0));
  }

  static void prikaziPorukuGreske(BuildContext context, String poruka) {
    _prikaziPoruku(context, poruka, Colors.red.withOpacity(0.8), const Color.fromARGB(255, 255, 255, 255));
  }

  static void prikaziPorukuUspjeha(BuildContext context, String poruka) {
    _prikaziPoruku(context, poruka, Colors.green.withOpacity(0.8), Colors.greenAccent);
  }

  static void _prikaziPoruku(BuildContext context, String poruka, Color backgroundColor, Color textColor) {
    // Ukloni prethodnu poruku ako postoji
    _trenutnaPoruka?.remove();
    _trenutnaPoruka = null;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0, // Razmak od vrha ekrana
        right: 16.0, // Razmak od desne strane
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            width: MediaQuery.of(context).size.width * 0.3, 
            child: Text(
              poruka,
              style: TextStyle(color: textColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Prikaži novu poruku
    overlay.insert(overlayEntry);
    _trenutnaPoruka = overlayEntry;

    // Automatski ukloni poruku nakon određenog vremena
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
      if (_trenutnaPoruka == overlayEntry) {
        _trenutnaPoruka = null;
      }
    });
  }
}
