import 'package:flutter/material.dart';

class CustomMarker extends StatelessWidget {
  final double size;

  CustomMarker({this.size = 30.0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // triangle
        Positioned(
          bottom: -size / 4,
          child: CustomPaint(
            size: Size(size / 3, size / 3),
            painter: TrianglePainter(),
          ),
        ),
        // cercle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 255, 139, 56),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
      ],
    );
  }
}

// Peint le triangle
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    Path path = Path()
      // Commence par le bas gauche du triangle
      ..moveTo(size.width / 2, size.height) // Point du sommet du triangle (bas)
      ..lineTo(0, 0) // Point bas gauche
      ..lineTo(size.width, 0) // Point bas droit
      ..close(); // Fermeture du triangle

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // Pas besoin de redessiner si l'élément ne change pas
  }
}
