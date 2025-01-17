import 'package:flutter/material.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class Step1Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.overBackground,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundFish,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 80 * 0.75,
                    height: 80 * 0.75,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset('assets/images/fish.png'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Ya des poissons',
                style: AppFonts.tutorialCardTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'Alors voilà, il y a des poissons et des fishs.',
                style: AppFonts.tutorialCardText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
