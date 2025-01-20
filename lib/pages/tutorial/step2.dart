import 'package:flutter/material.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class Step2Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: AppColors.overBackground,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Partie image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                child: Image.asset(
                  'assets/images/explorer.png',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                ),
              ),
              // Partie texte
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alignement global
                  children: [
                    Text(
                      'Explorez le monde',
                      style: AppFonts.tutorialCardTitle,
                      textAlign: TextAlign.left, // Alignement du titre à gauche
                    ),
                    SizedBox(height: 8.0),
                    RichText(
                      textAlign: TextAlign
                          .left, // Alignement du texte principal à gauche
                      text: TextSpan(
                        style: AppFonts.tutorialCardText,
                        children: [
                          TextSpan(
                            text:
                                'Soyez alerter et alertez de présence sous marine autour de vous, qu\'elles soient ',
                          ),
                          TextSpan(
                            text: 'mobile',
                            style: AppFonts.tutorialCardTextBold.copyWith(
                              color: AppColors.iconBackgroundFish,
                            ),
                          ),
                          TextSpan(
                            text: ' ou ',
                          ),
                          TextSpan(
                            text: 'fixe',
                            style: AppFonts.tutorialCardTextBold.copyWith(
                              color: AppColors.iconBackgroundShell,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
