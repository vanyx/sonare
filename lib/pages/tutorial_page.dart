import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  final VoidCallback onTutorialCompleted;

  TutorialPage({required this.onTutorialCompleted});

  Future<void> _onButtonClick() async {
    onTutorialCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.purple,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'tutorial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onButtonClick,
              child: Text('Click Me'),
            ),
          ],
        ),
      ),
    );
  }
}
