import 'package:flutter/material.dart';
import '../styles/AppColors.dart';

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
        backgroundColor: AppColors.greyButton,
      ),
      child: Icon(
        Icons.close,
        color: AppColors.greyButtonSeconday,
        size: 21,
      ),
    );
  }
}
