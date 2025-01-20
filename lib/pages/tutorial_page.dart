import 'package:Sonare/styles/AppColors.dart';
import 'package:Sonare/styles/AppFonts.dart';
import 'package:flutter/material.dart';
import 'tutorial/step1.dart';
import 'tutorial/step2.dart';
import 'tutorial/step3.dart';

class TutorialPage extends StatefulWidget {
  final VoidCallback onTutorialCompleted;

  TutorialPage({required this.onTutorialCompleted});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    Step1Widget(),
    Step2Widget(),
    Step3Widget(),
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onTutorialCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      body: Column(
        children: [
          // Contenu principal
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages,
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding * 1.5,
                vertical: horizontalPadding * 0.8),
            color: const Color.fromARGB(255, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentPage == index ? 13 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : AppColors.button,
                        borderRadius: BorderRadius.circular(50), // Bord arrondi
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.overBackground,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bord arrondi
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Suivant' : 'Terminer',
                    style: AppFonts.tutorialButton,
                  ),
                )
              ],
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
