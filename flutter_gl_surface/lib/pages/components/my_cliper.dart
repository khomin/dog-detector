import 'package:flutter/material.dart';

class MyClipper extends CustomClipper<Path> {
  MyClipper();

  @override
  Path getClip(Size size) {
    var path = Path();

    double radius = 20.0;
    path.moveTo(0, 0); // Starting point
    // path.lineTo(size.width, 0); // Top line
    // path.lineTo(size.width, 50); // Right line
    // path.lineTo(0, 80); // Right line
    // path.lineTo(20, 80); // Right line

    // path.moveTo(50, 0);
    // path.lineTo(50, 100); // Right line
    // path.lineTo(0, 100); // Right line

    // path. cubicTo(
    //   size.width * 2,
    //   0,
    //   0,
    //   size.width * 2,
    //   0,
    //   0,
    // );

    var w = size.width;
    var h = size.height;

    // // Start at the top-left corner of the square
    // path.moveTo(0, 0);

    // // Draw the square
    // path.lineTo(size.width, 100); // top-right corner
    // path.lineTo(190, 180); // bottom-right corner
    // path.lineTo(50, 180); // bottom-left corner

    // 2
    path.moveTo(radius, 0);
    path.lineTo(w - radius, 0);
    path.quadraticBezierTo(w, 0, w, radius);
    path.lineTo(w, h - radius);
    path.quadraticBezierTo(w, h, w - radius, h);
    path.lineTo(radius, h);
    path.quadraticBezierTo(0, h, 0, h - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // path.lineTo(
    //     size.width - 20, size.height); // Add bottom right rounded corner
    // path.quadraticBezierTo(
    //     size.width, size.height, size.width, size.height - roundedRadius);
    // path.lineTo(size.width, 20); // Top right rounded corner
    // path.quadraticBezierTo(size.width, 0, size.width - roundedRadius, 0);
    // path.lineTo(20, 0); // Top left rounded corner
    // path.quadraticBezierTo(0, 0, 0, roundedRadius);
    // path.lineTo(0, size.height - roundedRadius); // Left bottom rounded corner
    // path.quadraticBezierTo(0, size.height, roundedRadius, size.height);
    // path.lineTo(size.width - 20, size.height); // Bottom right line

    // path.moveTo(0, 0);
    // path.lineTo(size.width, 0);
    // path.lineTo(size.width, size.height);
    // path.lineTo(size.width * 0.75, size.height);
    // path.lineTo(size.width * 0.75, size.height * 0.45);
    // path.lineTo(size.width * 0.25, size.height * 0.45);
    // path.lineTo(size.width * 0.25, size.height);
    // path.lineTo(0, size.height);
    // path.lineTo(40, 40);
    // path.lineTo(0, 50);
    // path.lineTo(0, 40);

    // path.lineTo(50, 50);
    // path.lineTo(50, 50);
    // path.lineTo(size.width, size.height);
    path.close();

    // if (isTriangle) {
    // path.lineTo(size.width / 2, 0);
    // path.lineTo(size.width, size.height);
    // path.close();
    // } else {
    //   path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
