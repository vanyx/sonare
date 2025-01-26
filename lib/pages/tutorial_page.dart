import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'tutorial/step1.dart';
import 'tutorial/step2.dart';
import 'tutorial/step3.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';
import '../services/settings.dart';

class TutorialPage extends StatefulWidget {
  final VoidCallback onTutorialCompleted;

  TutorialPage({required this.onTutorialCompleted});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isStep1Complete = false;

  void _onNextPressed() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onTutorialCompleted();
    }
  }

  void _onAnimationComplete() {
    setState(() {
      _isStep1Complete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      body: Column(
        children: [
          // Contenu
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: _isStep1Complete
                  ? AlwaysScrollableScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                Step1Widget(onAnimationComplete: _onAnimationComplete),
                Step2Widget(),
                Step3Widget(),
              ],
            ),
          ),
          // Footer
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding * 1.5,
                vertical: horizontalPadding),
            color: const Color.fromARGB(255, 0, 0, 0),
            child: AnimatedOpacity(
              opacity: _isStep1Complete ? 1.0 : 0.0,
              duration: Duration(milliseconds: 400),
              child: Row(
                children: [
                  // Espace vide à gauche
                  Expanded(
                    child: SizedBox(),
                  ),
                  // 3 points
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.sonareFlashi
                              : AppColors.button,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _currentPage < 2
                          ? IconButton(
                              icon: Icon(
                                CupertinoIcons.chevron_forward,
                                color: AppColors.sonareFlashi,
                                size: 30.0,
                              ),
                              onPressed: () {
                                if (_isStep1Complete) _onNextPressed();
                              },
                            )
                          : ElevatedButton(
                              onPressed:
                                  _isStep1Complete ? _onNextPressed : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.overBackground,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Terminer',
                                style: AppFonts.tutorialButton,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
