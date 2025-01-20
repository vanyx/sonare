import 'package:flutter/material.dart';
import '../../styles/AppFonts.dart';

class Step1Widget extends StatefulWidget {
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
      setState(() {
        _showCursor = !_showCursor;
      });
    }
    setState(() {
      _startTyping = true;
      _showCursor = true;
    });
    _startTypingEffect();
  }

  void _startTypingEffect() {
    Future.delayed(_typingDelay, () {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _currentText += _fullText[_currentIndex];
          _currentIndex++;
        });
        _startTypingEffect();
      } else {
        // Une fois le texte terminé, cache la barre
        setState(() {
          _showCursor = false;
        });
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
