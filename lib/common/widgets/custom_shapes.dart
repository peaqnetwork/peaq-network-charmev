import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CurvePainter extends CustomPainter {
  CurvePainter(this.color);
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();

    // path.lineTo(size.width, 0);
    // // path.lineTo(, size.height * .9);
    // path.lineTo(size.width, size.width);
    // // path.quadraticBezierTo(
    // //     size.width * 0.70, size.height, size.width, size.height * .55);
    // // path.lineTo(size.width, 0);
    // path.close();

    paint.color = color;
    // canvas.drawPath(path, paint);

    // Top
    canvas.drawLine(
      Offset(size.width / 6, 0),
      Offset(size.width / 1.2, 0),
      paint,
    );

    // Left
    canvas.drawLine(
      Offset(0, size.width / 6),
      Offset(0, size.width / 1.2),
      paint,
    );

    // Bottom
    canvas.drawLine(
      Offset(size.height, size.width / 6),
      Offset(size.height, size.height / 1.2),
      paint,
    );

    // Right
    canvas.drawLine(
      Offset(size.width / 6, size.height),
      Offset(size.height / 1.2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
