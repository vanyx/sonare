import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings.dart';
import 'dart:math';

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

  /// -------------------------- MATH --------------------------

/**
 * Convertit un angle de degrés en radians.
 * 
 * @param degrees L'angle en degrés.
 * @return L'angle converti en radians.
 */
  static double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

/**
 * https://github.com/Ujjwalsharma2210/flutter_map_math/blob/main/lib/flutter_geo_math.dart
 * 
 * Calcul de l'azimut (en radians) entre un centre (lat1, lon1) 
 * et un point cible (lat2, lon2).
 * 
 * @param lat1 Latitude du point central en degrés.
 * @param lon1 Longitude du point central en degrés.
 * @param lat2 Latitude du point cible en degrés.
 * @param lon2 Longitude du point cible en degrés.
 * @return L'azimut en radians entre le centre et le point cible.
 */
  static double azimutBetweenCenterAndPointRadian(
      double lat1, double lon1, double lat2, double lon2) {
    var dLon = degreesToRadians(lon2 - lon1);
    var y = sin(dLon) * cos(degreesToRadians(lat2));
    var x = cos(degreesToRadians(lat1)) * sin(degreesToRadians(lat2)) -
        sin(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * cos(dLon);
    var angle = atan2(y, x);
    return angle - pi / 2;
  }

/**
 * Interpolation linéaire entre deux coordonnées géographiques.
 * 
 * @param start La position de départ (LatLng).
 * @param end La position d'arrivée (LatLng).
 * @param t Le facteur d'interpolation (entre 0 et 1).
 * @return Une nouvelle position interpolée (LatLng).
 */
  static LatLng lerp(LatLng start, LatLng end, double t) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * t,
      start.longitude + (end.longitude - start.longitude) * t,
    );
  }

/**
 * Interpolation linéaire entre deux angles (en degrés), prenant en compte
 * la continuité circulaire (ex. : passage de 359° à 0°).
 * 
 * @param start Angle de départ en degrés.
 * @param end Angle d'arrivée en degrés.
 * @param t Le facteur d'interpolation (entre 0 et 1).
 * @return L'angle interpolé en degrés.
 */
  static double lerpAngle(double start, double end, double t) {
    double difference = end - start;
    if (difference.abs() > 180.0) {
      if (difference > 0) {
        start += 360.0;
      } else {
        end += 360.0;
      }
    }
    double result = start + (end - start) * t;
    return result % 360.0;
  }

/**
 * Calcule l'angle de cap (bearing) en degrés entre deux positions géographiques.
 * 
 * @param from La position de départ (LatLng).
 * @param to La position d'arrivée (LatLng).
 * @return Le cap (bearing) en degrés, dans la plage [0, 360].
 */
  static double calculateBearing(LatLng from, LatLng to) {
    double lat1 = degreesToRadians(from.latitude);
    double lon1 = degreesToRadians(from.longitude);
    double lat2 = degreesToRadians(to.latitude);
    double lon2 = degreesToRadians(to.longitude);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x);

    return (bearing * (180.0 / pi) + 360.0) %
        360.0; // converti en degres et ramene dans la plage [0, 360]
  }

/**
 * Calcule la distance entre deux points géographiques en mètres,
 * en utilisant la formule de Haversine.
 * 
 * @param start La position de départ (LatLng).
 * @param end La position d'arrivée (LatLng).
 * @return La distance en mètres entre les deux points.
 */
  static double calculateDistance(LatLng start, LatLng end) {
    const double R = 6371000; // rayon de la Terre en m
    double lat1 = degreesToRadians(start.latitude);
    double lat2 = degreesToRadians(end.latitude);
    double deltaLat = degreesToRadians(end.latitude - start.latitude);
    double deltaLon = degreesToRadians(end.longitude - start.longitude);

    double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(deltaLon / 2) * sin(deltaLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}
