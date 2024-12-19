import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import './closeButton.dart';
import '../../styles/AppFonts.dart';

class ReportSheet extends StatefulWidget {
  final VoidCallback onClose;

  ReportSheet({required this.onClose});

  @override
  _ReportSheetState createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  int? selectedCircle; // null == aucun cercle sélectionné

  void toggleSelection(int index) {
    setState(() {
      if (selectedCircle == index) {
        selectedCircle = null;
      } else {
        selectedCircle = index;
      }
    });
  }

  void report() {
    // @TODO
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    double circleSize = MediaQuery.of(context).size.width / 4;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Que voyez-vous ?',
                  style: AppFonts.sheetTitle,
                ),
                CloseButtonWidget(
                  onClose: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: horizontalPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => toggleSelection(0),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedCircle == 0
                                ? AppColors.sonareFlashi
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: circleSize * 0.7,
                            height: circleSize * 0.7,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.asset('assets/fish.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8), // Espacement entre cercle et texte
                    Text(
                      'Poisson',
                      style: AppFonts.sheetReportItem,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => toggleSelection(1),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedCircle == 1
                                ? AppColors.sonareFlashi
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: circleSize * 0.7,
                            height: circleSize * 0.7,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.asset('assets/shell.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Coquillage',
                      style: AppFonts.sheetReportItem,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: horizontalPadding),
            Visibility(
              visible: selectedCircle != null,
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    report();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sonareFlashi,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 13), // Hauteur du bouton
                  ),
                  child: Text(
                    'Signaler',
                    style: AppFonts.sheetReportButton,
                  ),
                ),
              ),
            ),
            SizedBox(height: horizontalPadding * 2),
          ],
        ),
      ),
    );
  }
}
