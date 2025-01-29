import 'package:flutter/material.dart';
import '../../styles/AppFonts.dart';

class Step3Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titre
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text('Adaptez votre navigation.',
                    style: AppFonts.tutorialCardTitle),
              ),
              // 1ere row
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        'assets/images/explorer.png',
                        width: MediaQuery.of(context).size.width * 0.4,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Explorer', style: AppFonts.tutorialRowTitle),
                          SizedBox(height: 0),
                          Text(
                            'Imaginé pour vous aider à visualiser les zones sensibles.',
                            style: AppFonts.tutorialRowText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 2e row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/images/sonare.png',
                      width: MediaQuery.of(context).size.width * 0.4,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sonare', style: AppFonts.tutorialRowTitle),
                        SizedBox(height: 0),
                        Text(
                          'Un scan à 360° qui dévoile les dangers autour de vous, avant même de les voir.',
                          style: AppFonts.tutorialRowText,
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
    );
  }
}
