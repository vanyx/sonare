import 'dart:math';
import 'package:flutter/material.dart';

class Test2Page extends StatefulWidget {
  @override
  _Test2PageState createState() => _Test2PageState();
}

class _Test2PageState extends State<Test2Page> {
  double _angle = 0.0; // Angle initial en radians

  @override
  Widget build(BuildContext context) {
    // Obtenir la taille de l'écran
    final Size screenSize = MediaQuery.of(context).size;

    // Calcul du rayon comme 90% de la largeur de l'écran
    final double _radius = (screenSize.width * 0.9) / 2;

    // Coordonnées du centre de l'écran
    final Offset center = Offset(screenSize.width / 2, screenSize.height / 2);

    // Calcul de la position actuelle du cercle rouge
    final Offset circlePosition = Offset(
      center.dx + _radius * cos(_angle),
      center.dy + _radius * sin(_angle),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onPanUpdate: (details) {
          // Calcule l'angle en fonction de la position du doigt par rapport au centre
          final offset = details.localPosition - center;

          setState(() {
            _angle =
                atan2(offset.dy, offset.dx); // Convertit en angle (radians)
          });
        },
        child: Stack(
          children: [
            // Cercle bleu pour représenter la trajectoire
            CustomPaint(
              size: Size(screenSize.width, screenSize.height),
              painter: CirclePainter(center, _radius),
            ),
            // Cercle rouge
            Positioned(
              left:
                  circlePosition.dx - 10, // Position du cercle (moins le rayon)
              top:
                  circlePosition.dy - 10, // Position du cercle (moins le rayon)
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomPainter pour dessiner le cercle bleu
class CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;

  CirclePainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    // Définir un pinceau pour dessiner le cercle bleu
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // Épaisseur de la bordure

    // Dessiner le cercle bleu
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // Pas besoin de redessiner constamment
  }
}
