import 'package:flutter/material.dart';
import '../../styles/AppFonts.dart';

class Step1Widget extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  Step1Widget({required this.onAnimationComplete});

  @override
  _Step1WidgetState createState() => _Step1WidgetState();
}

class _Step1WidgetState extends State<Step1Widget> {
  String _fullText = 'Naviguez sereinement.';
  String _currentText = '';
  int _currentIndex = 0;
  Duration _typingDelay = Duration(milliseconds: 100);
  bool _showCursor = true;
  bool _startTyping = false;

  @override
  void initState() {
    super.initState();
    _startCursorBlinking();
  }

  void _startCursorBlinking() async {
    for (int i = 0; i < 6; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    }
    if (mounted) {
      setState(() {
        _startTyping = true;
        _showCursor = true;
      });
    }

    _startTypingEffect();
  }

  void _startTypingEffect() {
    Future.delayed(_typingDelay, () async {
      if (_currentIndex < _fullText.length - 1) {
        // -1 pour ne pas animer la dernière lettre
        if (mounted) {
          setState(() {
            _currentText += _fullText[_currentIndex];
            _currentIndex++;
          });
        }
        _startTypingEffect();
      } else {
        // Une fois le texte terminé
        if (mounted) {
          // affiche la derniere lettre
          setState(() {
            _currentText += _fullText[_currentIndex];
            _currentIndex++;
          });
        }

        if (mounted) {
          setState(() {
            _showCursor = false;
          });
        }
        await Future.delayed(Duration(milliseconds: 1800));
        widget.onAnimationComplete(); // Appel du callback
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _currentText,
                  style: AppFonts.tutorialTypeWriter,
                ),
                TextSpan(
                  text: (_showCursor &&
                          (_startTyping || _currentIndex < _fullText.length))
                      ? '|'
                      : ' ', // espace pour eviter le decalage
                  style: TextStyle(
                    fontFamily: 'sf-pro-display-light',
                    fontSize: 30,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
