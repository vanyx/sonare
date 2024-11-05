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
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre et bouton de fermeture
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
                    elevation: 0,
                    shape: CircleBorder(),
                    backgroundColor: AppColors.grey2Button,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.grey2ButtonSeconday,
                    size: 21,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Options de mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => onModeSelected(1),
                  child: Container(
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
                            width: 150,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 8.0),
                              color: AppColors.grey2Button.withOpacity(0.97),
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
                GestureDetector(
                  onTap: () => onModeSelected(2),
                  child: Container(
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
                            width: 150,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 8.0),
                              color: AppColors.grey2Button.withOpacity(0.97),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
