import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
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
  bool isReported = false;
  double opacity = 1.0;

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
    setState(() {
      // Lance le fondu
      opacity = 0.0;
    });

    // Delai avant de changer l'affichage
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        isReported = true;
        opacity = 1.0;
      });
    });

    // Delai avant de fermer la sheet
    Future.delayed(Duration(seconds: 3), () {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    double circleSize = MediaQuery.of(context).size.width / 4;

    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: horizontalPadding * 0.5,
        ),
        child: AnimatedOpacity(
            duration: Duration(milliseconds: 200), // Delai de fondu
            opacity: opacity,
            child: !isReported
                // Ecran principal
                ? Column(
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
                      SizedBox(height: 15),
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
                              SizedBox(
                                  height:
                                      8), // Espacement entre cercle et texte
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
                      SizedBox(height: 20),
                      Visibility(
                        visible: selectedCircle != null,
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: report,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sonareFlashi,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 13), // Hauteur du bouton
                            ),
                            child: Text(
                              'Signaler',
                              style: AppFonts.sheetReportButton,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  )
                // Ecran de confirmation
                : Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.sonareFlashi,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Signalement ajouté à la carte.',
                          style: AppFonts.sheetReportConfirmationText,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  )),
      ),
    );
  }
}
