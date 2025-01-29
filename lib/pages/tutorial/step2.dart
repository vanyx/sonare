import 'package:flutter/material.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class Step2Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      // Card
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
              // Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                child: Image.asset(
                  'assets/images/tutomap.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              // Partie texte
              Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anticipez chaque surprise.',
                      style: AppFonts.tutorialCardTitle,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 8.0),
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: AppFonts.tutorialCardText,
                        children: [
                          TextSpan(
                            text:
                                'Recevez des alertes en temps réel quand vous pénétrez dans une zone de contrôle. Contribuez en alertant la communauté et soyez informé des présences autour de vous, qu’elles soient ',
                          ),
                          TextSpan(
                            text: 'fixes',
                            style: AppFonts.tutorialCardText.copyWith(
                              color: AppColors.iconBackgroundShell,
                            ),
                          ),
                          TextSpan(
                            text: ' ou ',
                          ),
                          TextSpan(
                            text: 'mobiles',
                            style: AppFonts.tutorialCardText.copyWith(
                              color: AppColors.iconBackgroundFish,
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
