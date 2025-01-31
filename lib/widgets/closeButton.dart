import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import 'package:flutter/cupertino.dart';

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
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 15.5,
            height: 15.5,
            child: Image.asset(
              'assets/images/icons/croix.webp',
              color: AppColors.buttonMain,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
