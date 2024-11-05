import 'package:flutter/material.dart';
import '../styles/AppColors.dart';

class SelectModeSheet extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeSelected;

  SelectModeSheet({
    required this.selectedMode,
    required this.onModeSelected,
  });

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
                  'Choisir un mode',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(30, 30),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: CircleBorder(),
                    backgroundColor: AppColors.greyButton,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.greyButtonSeconday,
                    size: 21,
                  ),
                ),
              ],
            ),
            SizedBox(height: horizontalPadding),

            // Options de mode (cartes)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Premiere carte
                Expanded(
                  child: GestureDetector(
                    onTap: () => onModeSelected(1),
                    child: Container(
                      margin: EdgeInsets.only(right: horizontalPadding / 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: selectedMode == 1
                              ? AppColors.sonareFlashi
                              : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/explorer.png',
                              width: double.infinity,
                              height: cardHeight,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 8.0),
                                color: AppColors.greyButton.withOpacity(0.97),
                                child: Text(
                                  'Explorer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Deuxieme carte
                Expanded(
                  child: GestureDetector(
                    onTap: () => onModeSelected(2),
                    child: Container(
                      margin: EdgeInsets.only(left: horizontalPadding / 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: selectedMode == 2
                              ? AppColors.sonareFlashi
                              : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/sonare.jpg',
                              width: double.infinity,
                              height: cardHeight,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 8.0),
                                color: AppColors.greyButton.withOpacity(0.97),
                                child: Text(
                                  'Sonare',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: horizontalPadding * 3),
          ],
        ),
      ),
    );
  }
}
