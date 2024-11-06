import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import './closeButton.dart';

class ReportSheet extends StatelessWidget {
  final VoidCallback onClose;

  ReportSheet({required this.onClose});

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    double cardWidth =
        (MediaQuery.of(context).size.width - (horizontalPadding * 2)) / 2;
    double cardHeight = cardWidth * 10 / 16; //ratio 16/10

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre et bouton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Que voyez-vous ?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white),
                ),
                CloseButtonWidget(
                  onClose: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: horizontalPadding),

            // TODO
            Row(),
            SizedBox(height: horizontalPadding * 3),
          ],
        ),
      ),
    );
  }
}
