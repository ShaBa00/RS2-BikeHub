// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List slikeBiciklis;
  final int initialIndex;

  ImageCarousel({
    required this.slikeBiciklis,
    required this.initialIndex,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late int _currentBicikliSlikaIndex;

  @override
  void initState() {
    super.initState();
    _currentBicikliSlikaIndex = widget.initialIndex;
  }

  void _showPreviousImage() {
    setState(() {
      _currentBicikliSlikaIndex =
          (_currentBicikliSlikaIndex - 1 + widget.slikeBiciklis.length) %
              widget.slikeBiciklis.length;
    });
  }

  void _showNextImage() {
    setState(() {
      _currentBicikliSlikaIndex =
          (_currentBicikliSlikaIndex + 1) % widget.slikeBiciklis.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.slikeBiciklis.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    15), // Postavi vrijednost prema željenom zaobljenju
                child: Image.memory(
                  base64Decode(
                      widget.slikeBiciklis[_currentBicikliSlikaIndex]['slika']),
                  width: MediaQuery.of(context).size.width * 0.55,
                  height: MediaQuery.of(context).size.height * 0.24,
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white), // Ikona bijele boje
                    onPressed: _showPreviousImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward,
                        color: Colors.white), // Ikona bijele boje
                    onPressed: _showNextImage,
                  ),
                ],
              ),
            ],
          )
        : Center(
            child: const Text(
              "Nema dostupnih slika",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          );
  }
}
