import 'package:flutter/material.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class Step1Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Naviguez en toute tranquillité.',
            style: AppFonts.tutorialCardTitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
