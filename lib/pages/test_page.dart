import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour MethodChannel

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  double _angle = 0; // L'angle du petit cercle
  final double _radius = 140; // Rayon du grand cercle
  final double _thumbSize = 32; // Taille du petit cercle
  double? _direction; // Direction du Nord en degrés

  // Déclare un MethodChannel pour communiquer avec la partie native
  static const platform = MethodChannel('com.sonare/compass');

  @override
  void initState() {
    super.initState();

    // Écouter les événements de direction via le MethodChannel
    platform.setMethodCallHandler((call) async {
      if (call.method == "updateDirection") {
        // Met à jour la direction en fonction de la valeur reçue
        final double newDirection = call.arguments as double;
        setState(() {
          _direction = newDirection;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            // Calcule l'angle en fonction de la position du doigt
            final offset =
                details.localPosition - Offset(150, 150); // Centre du cercle
            setState(() {
              _angle = atan2(offset.dy, offset.dx); // Convertit en radians
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grand cercle
              CustomPaint(
                size: Size(300, 300),
                painter: CirclePainter(),
              ),
              // Petit cercle
              Positioned(
                left: 150 + _radius * cos(_angle) - _thumbSize / 2,
                top: 150 + _radius * sin(_angle) - _thumbSize / 2,
                child: Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Texte qui indique le Nord
              Positioned(
                child: Text(
                  _direction == null
                      ? 'Aucun signal'
                      : '${_direction!.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
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

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    // Dessine un grand cercle
    canvas.drawCircle(size.center(Offset.zero), 140, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
