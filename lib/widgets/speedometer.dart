import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import '../styles/AppFonts.dart';

class Speedometer extends StatelessWidget {
  final double speed;
  final int mode;

  const Speedometer({Key? key, required this.speed, required this.mode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.button.withValues(alpha: mode == 1 ? 0.9 : 1.0),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/icons/speedometer.png',
              color: AppColors.textOverCard,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  speed.toInt().toString(),
                  style: AppFonts.speedometerSpeed
                      .copyWith(height: 0), // reduis la taille invisible
                ),
                Text(
                  'km/h',
                  style: AppFonts.speedometerUnit.copyWith(height: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
