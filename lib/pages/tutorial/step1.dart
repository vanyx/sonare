import 'package:flutter/material.dart';
import '../../styles/AppFonts.dart';

class Step1Widget extends StatefulWidget {
  final VoidCallback
      onAnimationComplete; // Callback pour informer que l'animation est terminée

  Step1Widget({required this.onAnimationComplete});

  @override
  _Step1WidgetState createState() => _Step1WidgetState();
}

class _Step1WidgetState extends State<Step1Widget> {
  String _fullText = 'Naviguez en toute tranquillité.';
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
    for (int i = 0; i < 4; i++) {
      // la barre clignote 4 fois
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
    Future.delayed(_typingDelay, () {
      if (_currentIndex < _fullText.length) {
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
          setState(() {
            _showCursor = false;
          });
        }
        widget.onAnimationComplete(); // Appel de la callback
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentText,
                style: AppFonts.tutorialCardTitle,
              ),
              if (_showCursor &&
                  (_startTyping || _currentIndex < _fullText.length))
                Text('|',
                    style: TextStyle(
                        fontFamily: 'sf-pro-display-ultralight',
                        fontSize: 25,
                        color: Color.fromARGB(255, 255, 255, 255))),
            ],
          ),
        ),
      ),
    );
  }
}
