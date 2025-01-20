import 'package:flutter/material.dart';
import '../../styles/AppFonts.dart';
import '../../styles/AppColors.dart';

class Step3Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    double cardHeight =
        MediaQuery.of(context).size.width * 0.25; // Taille fixe pour l'image

    return Container(
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligner à gauche
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre
                Padding(
                  padding: EdgeInsets.only(bottom: horizontalPadding),
                  child: Text('Adaptez votre navigation.',
                      style: AppFonts.tutorialCardTitle),
                ),
                // Première ligne
                Padding(
                  padding: EdgeInsets.only(bottom: horizontalPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/images/explorer.png',
                          height: cardHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Explorer',
                                style: AppFonts.tutorialCardSubtitle),
                            SizedBox(height: 8.0),
                            Text(
                              'Imaginé pour vous aider à repérer les zones sensibles.',
                              style: AppFonts.tutorialCardText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Deuxième ligne
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        'assets/images/sonare.png',
                        height: cardHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sonare', style: AppFonts.tutorialCardSubtitle),
                          SizedBox(height: 8.0),
                          Text(
                            'Un scan à 360° qui dévoile les dangers autour de vous, avant même de les voir.',
                            style: AppFonts.tutorialCardText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
