import 'package:flutter/material.dart';

class Step3Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Vous pouvez aussi alerter en temps reel, et vous pouvez recevoir des alerts',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
