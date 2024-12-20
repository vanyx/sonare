import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const String soundKey = 'soundEnabled';
  static const String notificationsKey = 'notificationsEnabled';

  // Sauvegarde des preferences
  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(soundKey, enabled);
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(notificationsKey, enabled);
  }

  // Recuperation des preferences
  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(soundKey) ?? true; // valeur par defaut
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationsKey) ?? true;
  }
}
