import 'package:flutter/material.dart';
import '../styles/AppColors.dart';

/********************************************************
 *                                                      *
 *                  / !\ WARNING /!\                    *
 *                                                      *
 * La taille (width et height) du Marker parent         *
 * doit être egale à celle fournie dans ce constructeur *
 *                                                      *
 ********************************************************/

class CustomMarker extends StatelessWidget {
  final double size;
  final String type;

  CustomMarker({required this.size, required this.type})
      : assert(type == "fish" || type == "shell",
            'Type must be either "fish" or "shell".');

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0, -size * 0.7),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // cercle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: type == "fish"
                    ? AppColors.iconBackgroundFish
                    : (type == "shell"
                        ? AppColors.iconBackgroundShell
                        : AppColors.iconBackgroundFish), //valeur par defaut
                border: Border.all(
                  color: Colors.white,
                  width: size / 9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2, // Rayonnement de l'ombre
                    blurRadius: 4, // Flou de l'ombre
                    offset: Offset(0, 3), // Déplacement vertical de l'ombre
                  ),
                ],
              ),
            ),
            Positioned(
              child: Image.asset(
                type == 'fish' ? 'assets/fish.png' : 'assets/shell.png',
                width: size / 1.5,
                height: size / 1.5,
              ),
            ),
            // triangle
            Positioned(
              bottom: -size / 4,
              child: CustomPaint(
                size: Size(size / 3, size / 3),
                painter: TrianglePainter(),
              ),
            ),
          ],
        ));
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dessine l'ombre du triangle
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2) // Couleur de l'ombre
      ..style = PaintingStyle.fill;

    Path shadowPath = Path()
      ..moveTo(size.width / 2, size.height + 3) // Décalage pour l'ombre
      ..lineTo(3, 3) // Décalage pour l'ombre
      ..lineTo(size.width - 3, 3) // Décalage pour l'ombre
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);

    // Dessine le triangle lui-même
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
