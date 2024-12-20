import 'package:flutter/material.dart';
import './AppColors.dart';

class AppFonts {
  // sheet

  static const sheetTitle = TextStyle(
      fontFamily: 'sf-pro-display-black',
      fontSize: 23,
      color: Color.fromARGB(255, 255, 255, 255));

  static const sheetMode = TextStyle(
      fontFamily: 'sf-pro-display-bold',
      fontSize: 16,
      color: Color.fromARGB(255, 255, 255, 255));

  static const sheetReportItem = TextStyle(
      fontFamily: 'sf-pro-display-bold',
      fontSize: 16,
      color: Color.fromARGB(255, 255, 255, 255));

  static const sheetReportButton = TextStyle(
      fontFamily: 'sf-pro-display-heavy',
      fontSize: 18,
      color: Color.fromARGB(255, 255, 255, 255));

  static const sheetReportConfirmationText = TextStyle(
      fontFamily: 'sf-pro-display-semibold',
      fontSize: 18,
      color: Color.fromARGB(255, 255, 255, 255));

  // settings

  static const settingsList = TextStyle(
      fontFamily: 'sf-pro-display-bold',
      fontSize: 17,
      color: Color.fromARGB(255, 255, 255, 255));

  static const settingsTitle = TextStyle(
      fontFamily: 'sf-pro-display-black',
      fontSize: 17,
      color: Color.fromARGB(255, 255, 255, 255));

  static const settingsNotif = TextStyle(
      fontFamily: 'sf-pro-display-bold',
      fontSize: 17,
      color: Color.fromARGB(255, 255, 255, 255));

  static const settingsNotifSubtitle = TextStyle(
      fontFamily: 'sf-pro-display-bold',
      fontSize: 13,
      color: AppColors.legendText);

  static const settingsLexiqueTitle = TextStyle(
      fontFamily: 'sf-pro-display-heavy',
      fontSize: 17,
      color: Color.fromARGB(255, 255, 255, 255));

  static const settingsLexiqueText = TextStyle(
      fontFamily: 'sf-pro-display-semibold',
      fontSize: 14,
      color: AppColors.textOverCard);
}
