import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: AppColors.background2.withValues(alpha: 0.97),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      child: Container(
        width: screenSize.width * 0.6,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Mise à jour requise',
              style: AppFonts.dialogTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              'Une nouvelle version de l\'application est disponible. Veuillez mettre à jour pour continuer.',
              textAlign: TextAlign.center,
              style: AppFonts.dialogText,
            ),
          ],
        ),
      ),
    );
  }
}
