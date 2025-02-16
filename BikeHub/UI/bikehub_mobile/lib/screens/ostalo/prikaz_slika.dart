// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'dart:convert'; // Dodano za base64Decode

class PrikazSlike extends StatefulWidget {
  final List<Map<String, dynamic>> slikeBiciklis;
  final bool isPromovisan;

  PrikazSlike(
      {super.key, required this.slikeBiciklis, required this.isPromovisan});

  @override
  _PrikazSlikeState createState() => _PrikazSlikeState();
}

class _PrikazSlikeState extends State<PrikazSlike> {
  int _currentIndex = 0;

  void _nextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.slikeBiciklis.length;
    });
  }

  void _previousImage() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.slikeBiciklis.length) %
          widget.slikeBiciklis.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.35,
          color: Colors.grey,
          child: Column(
            children: [
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 0) {
                    _previousImage();
                  } else {
                    _nextImage();
                  }
                },
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        key: ValueKey<int>(_currentIndex),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: widget.slikeBiciklis.isNotEmpty
                            ? Image.memory(
                                base64Decode(widget.slikeBiciklis[_currentIndex]
                                    ['slika']),
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                              ),
                      ),
                      if (widget.isPromovisan)
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0,
                          left: MediaQuery.of(context).size.width * 0.4,
                          right: 0,
                          child: Transform.rotate(
                            angle: 0,
                            child: Container(
                              color: Color.fromARGB(255, 0, 251, 255),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Promovisan',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
