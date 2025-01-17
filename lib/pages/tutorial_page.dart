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
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.purple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _onNextPressed,
                  child: Text(_currentPage < _pages.length - 1
                      ? 'Suivant'
                      : 'Terminer'),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.purple,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
