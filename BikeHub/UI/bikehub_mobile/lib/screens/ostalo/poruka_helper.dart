// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PorukaHelper {
  static OverlayEntry? _trenutnaPoruka;
  static AnimationController? _controller;

  static void prikaziPorukuUspjeha(BuildContext context, String poruka) {
    _prikaziPoruku(
        context, poruka, Colors.green.withOpacity(0.8), Colors.white);
  }

  static void prikaziPorukuUpozorenja(BuildContext context, String poruka) {
    _prikaziPoruku(context, poruka,
        const Color.fromARGB(255, 255, 255, 62).withOpacity(0.8), Colors.black);
  }

  static void prikaziPorukuGreske(BuildContext context, String poruka) {
    _prikaziPoruku(context, poruka, Colors.red.withOpacity(0.8), Colors.white);
  }

  static void _prikaziPoruku(BuildContext context, String poruka,
      Color backgroundColor, Color textColor) {
    // Ukloni prethodnu poruku ako postoji
    _trenutnaPoruka?.remove();
    _controller?.dispose();
    _trenutnaPoruka = null;
    _controller = null;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        _controller = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: Navigator.of(context),
        );

        Animation<double> opacityAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(_controller!);

        _controller!.forward();

        return Positioned(
          top: MediaQuery.of(context).size.height * 0.4, // Sredina ekrana
          left: MediaQuery.of(context).size.width *
              0.1, // Mala margina s lijeve strane
          right: MediaQuery.of(context).size.width *
              0.1, // Mala margina s desne strane
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: opacityAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 4),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: textColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        poruka,
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Prikaži novu poruku
    overlay.insert(overlayEntry);
    _trenutnaPoruka = overlayEntry;

    // Automatski ukloni poruku nakon određenog vremena s animacijom
    Future.delayed(const Duration(seconds: 3), () {
      _controller?.reverse().then((value) {
        if (_trenutnaPoruka == overlayEntry) {
          overlayEntry.remove();
          _trenutnaPoruka = null;
          _controller?.dispose();
          _controller = null;
        }
      });
    });
  }
}
