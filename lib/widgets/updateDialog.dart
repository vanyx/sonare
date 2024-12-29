import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double horizontalPadding = screenSize.width * 0.05;

    return Dialog(
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: screenSize.width * 0.8,
          padding: EdgeInsets.all(horizontalPadding),
          color: AppColors.background2, // couleur de fond
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Mise à jour requise',
                style: AppFonts.dialogTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: horizontalPadding * 0.3),
              Text(
                'Une nouvelle version de l\'application est disponible. Veuillez mettre à jour pour continuer.',
                textAlign: TextAlign.center,
                style: AppFonts.dialogText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
