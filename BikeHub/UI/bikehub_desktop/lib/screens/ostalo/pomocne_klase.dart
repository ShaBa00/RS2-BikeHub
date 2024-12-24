import 'package:flutter/material.dart';

class DiagonalClipper extends CustomClipper<Path> {
  final bool isTop;

  DiagonalClipper({required this.isTop});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (isTop) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
