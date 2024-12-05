import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class CloseButtonWidget extends StatelessWidget {
  final VoidCallback onClose;

  CloseButtonWidget({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClose,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(30, 30),
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: CircleBorder(),
        backgroundColor: AppColors.button,
      ),
      child: Icon(
        CupertinoIcons.clear,
        color: AppColors.buttonMain,
        size: 22.0,
      ),
    );
  }
}
