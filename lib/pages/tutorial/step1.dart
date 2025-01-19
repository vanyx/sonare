import 'package:flutter/material.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class Step1Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image centrée
            Image.asset(
              'assets/images/logo/icon.png',
              height: 120.0,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.0),
            // Titre
            Text(
              'Explorez le monde',
              style: AppFonts.tutorialCardTitle.copyWith(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            // Texte explicatif
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Soyez alerté et alertez de présence sous-marine autour de vous, qu’elles soient mobiles (fish) ou fixes (coquillage).',
                style: AppFonts.tutorialCardText.copyWith(
                  color: Colors.white70,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
