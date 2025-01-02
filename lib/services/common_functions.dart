import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings.dart';

class Common {
  /// -------------------------- FETCH FAUNA --------------------------

  static const int maxRetry = 3;

  static Future<List<LatLng>> fetchWish(
      double north, double south, double west, double east, int retries) async {
    // Return empty si url vide
    if (Settings.wishUrl.length == 0) {
      return [];
    }
    Map<String, String> queryParams = {
      "top": north.toString(),
      "bottom": south.toString(),
      "left": west.toString(),
      "right": east.toString(),
      "env": "row",
      "types": "alerts"
    };

    try {
      Uri uri = Uri.parse(Settings.wishUrl);
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(finalUri);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<LatLng> newFish = [];

        if (data['alerts'] != null) {
          for (var alert in data['alerts']) {
            var location = alert['location'];
            if (location != null && alert['type'] == 'POLICE') {
              LatLng fishPosition = LatLng(location['y'], location['x']);
              newFish.add(fishPosition);
            }
          }
        }
        return newFish;
      } else {
        return [];
      }
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(Duration(milliseconds: 200));
        return await fetchWish(north, south, west, east, retries - 1);
      } else {
        return [];
      }
    }
  }

  /// -------------------------- SharedPreferences --------------------------

  // Sauvegarde des preferences
  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.soundKey, enabled);
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.notificationsKey, enabled);
  }

  // Recuperation des preferences
  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Settings.soundKey) ?? true; // valeur par defaut
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Settings.notificationsKey) ?? true;
  }

  /// -------------------------- SOUNDS --------------------------

  static Future<void> playWarningByLevel(int level) async {
    if (level == 1)
      play400mWarning();
    else if (level == 2)
      play800mWarning();
    else if (level == 3) play3kmWarning();
  }

  static Future<void> play3kmWarning() async {
    final AudioPlayer audioPlayer = AudioPlayer();

    try {
      await audioPlayer.play(AssetSource('sounds/3km.mp3'));
    } catch (e) {}
  }

  static Future<void> play800mWarning() async {
    final AudioPlayer audioPlayer = AudioPlayer();

    try {
      await audioPlayer.play(AssetSource('sounds/800m.mp3'));
    } catch (e) {}
  }

  static Future<void> play400mWarning() async {
    final AudioPlayer audioPlayer = AudioPlayer();

    try {
      await audioPlayer.play(AssetSource('sounds/400m.mp3'));
    } catch (e) {}
  }
}
