import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class CloseButtonWidget extends StatelessWidget {
  final VoidCallback onClose;

  CloseButtonWidget({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          color: AppColors.button,
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.clear,
          color: AppColors.buttonMain,
          size: 17.0,
        ),
      ),
    );
  }
}
