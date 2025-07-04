import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/settings.dart';
import 'dart:math';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class Common {
  /// -------------------------- WEB --------------------------
  static Future<List<Alert>> getAlertByWindow(
      double east, double south, double west, double north) async {
    if (Settings.getByWindowEndpoint.isEmpty) {
      return [];
    }

    Map<String, String> queryParams = {
      "east": east.toString(),
      "south": south.toString(),
      "west": west.toString(),
      "north": north.toString()
    };

    try {
      Uri uri = Uri.parse(Settings.apiUrl + Settings.getByWindowEndpoint);
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(finalUri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        List<Alert> alerts = [];

        if (Settings.policeEnable && data.containsKey("polices")) {
          alerts.addAll(data["polices"]
              .where((json) =>
                  json.containsKey("latitude") && json.containsKey("longitude"))
              .map<Alert>((json) =>
                  Police(position: LatLng(json["latitude"], json["longitude"])))
              .toList());
        }

        if (Settings.controlZoneEnable && data.containsKey("control-zones")) {
          alerts.addAll(data["control-zones"]
              .where((json) =>
                  json.containsKey("latitude") && json.containsKey("longitude"))
              .map<Alert>((json) {
            bool? centroid =
                json.containsKey("centroid") ? json["centroid"] : null;
            return ControlZone(
              position: LatLng(json["latitude"], json["longitude"]),
              radius: 500,
              centroid: centroid ??
                  false, // Si centroid n'est pas recu, false par defaut
            );
          }).toList());
        }

        return alerts;
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  static Future<List<Alert>> getAlertByRadius(LatLng position) async {
    if (Settings.getByRadiusEndpoint.isEmpty) {
      return [];
    }

    Map<String, String> queryParams = {
      "longitude": position.longitude.toString(),
      "latitude": position.latitude.toString()
    };

    try {
      Uri uri = Uri.parse(Settings.apiUrl + Settings.getByRadiusEndpoint);
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(finalUri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        List<Alert> alerts = [];

        if (Settings.policeEnable && data.containsKey("polices")) {
          alerts.addAll(data["polices"]
              .where((json) =>
                  json.containsKey("latitude") && json.containsKey("longitude"))
              .map<Alert>((json) =>
                  Police(position: LatLng(json["latitude"], json["longitude"])))
              .toList());
        }
        if (Settings.controlZoneEnable && data.containsKey("control-zones")) {
          alerts.addAll(data["control-zones"]
              .where((json) =>
                  json.containsKey("latitude") && json.containsKey("longitude"))
              .map<Alert>((json) => ControlZone(
                  position: LatLng(json["latitude"], json["longitude"]),
                  radius: 500))
              .toList());
        }

        return alerts;
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  static Future<void> postAlert(LatLng position, String type) async {
    if (Settings.postPoliceEndpoint.isEmpty ||
        Settings.postControlZoneEndpoint.isEmpty) {
      return;
    }

    Map<String, String> body = {
      "longitude": position.longitude.toString(),
      "latitude": position.latitude.toString()
    };

    try {
      String endpoint = "";
      if (type == "controlZone") {
        endpoint = Settings.postControlZoneEndpoint;
      } else if (type == "police") {
        endpoint = Settings.postPoliceEndpoint;
      } else {
        return;
      }

      Uri uri = Uri.parse(Settings.apiUrl + endpoint);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type':
              'application/json', // specifie que les donnees envoyees sont en JSON
        },
        body: jsonEncode(body), // Encode le corps en JSON
      );

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }

  /// -------------------------- Sonare Control --------------------------

  static Future<void> initializeSonare() async {
    // Vérifie si l'endpoint est vide
    if (Settings.apiInfoEndpoint.isEmpty) {
      return;
    }

    try {
      Uri finalUri = Uri.parse(Settings.apiUrl + Settings.apiInfoEndpoint);

      final response = await http.get(finalUri).timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                http.Response('{}', 408), // reponse vite apres 5s sans reponse
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data.containsKey("mapUrl") && data["mapUrl"] != null) {
          Settings.mapUrl = data["mapUrl"];
        }

        if (data.containsKey("apiVersion") && data["apiVersion"] != null) {
          Settings.apiVersion = data["apiVersion"];
        }
      }
    } catch (e) {}
  }

  /// -------------------------- Permissions --------------------------

  static Future<void> requestPermissions() async {
    await Common.checkLocationPermission(); //demande location permission
    await Common.checkNotificationPermission(); // demande notif permission
  }

  static Future<void> checkLocationPermission() async {
    Settings.locationPermission = await getLocationPermission();
  }

  static Future<void> checkNotificationPermission() async {
    if (Platform.isAndroid) {
      Settings.notificationPermission =
          await getNotificationPermissionAndroid();
    } else if (Platform.isIOS) {
      Settings.notificationPermission = await getNotificationPermissionIOS();
    }
  }

  static Future<bool> getLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false; // Permission refusee
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Permission definitivement refusee
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return false; // Service de localisation desactives
    }

    return true;
  }

  static Future<bool> getNotificationPermissionIOS() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return granted ?? false;
  }

  static Future<bool> getNotificationPermissionAndroid() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final bool? isGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    return isGranted ?? false;
  }

  /// -------------------------- SharedPreferences --------------------------

  // Tutorial done
  static Future<void> setTutorialDone(bool enabled) async {
    Settings.tutorialDone = enabled;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.tutorialKey, enabled);
  }

  static Future<bool> getTutorialDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Settings.tutorialKey) ?? false;
  }

  // Sound setting
  static Future<void> setSoundEnabled(bool enabled) async {
    Settings.soundEnable = enabled;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.soundKey, enabled);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Settings.soundKey) ?? true;
  }

  // Notification setting
  static Future<void> setNotificationsEnabled(bool enabled) async {
    Settings.notificationEnable = enabled;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.notificationsKey, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Settings.notificationsKey) ?? true;
  }

  // Notifier pour anoncer un changement
  static ValueNotifier<bool> alertNotifier = ValueNotifier(true);

  // police enabled
  static Future<void> setPoliceEnabled(bool enabled) async {
    Settings.policeEnable = enabled;
    alertNotifier.value =
        !alertNotifier.value; // Change la valeur pour notifier
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.policeKey, enabled);
  }

  static Future<bool> getPoliceEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Settings.policeKey) ?? true;
  }

  // controlZones enabled
  static Future<void> setControlZoneEnabled(bool enabled) async {
    Settings.controlZoneEnable = enabled;
    alertNotifier.value =
        !alertNotifier.value; // Change la valeur pour notifier
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Settings.controlZoneKey, enabled);
  }

  static Future<bool> getControlZoneEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Settings.controlZoneKey) ?? true;
  }

  /// -------------------------- SOUNDS --------------------------

  static Future<void> PlayControlZoneByLevel(int level) async {
    final soundFiles = {
      1: 'sounds/enterControlZone.mp3',
      2: 'sounds/controlZone800m.mp3'
    };

    if (soundFiles.containsKey(level)) {
      await playSound(soundFiles[level]!);
    }
  }

  static Future<void> playPoliceByLevel(int level) async {
    final soundFiles = {
      1: 'sounds/police400m.mp3',
      2: 'sounds/police800m.mp3',
      3: 'sounds/police3km.mp3',
    };

    if (soundFiles.containsKey(level)) {
      await playSound(soundFiles[level]!);
    }
  }

  static Future<void> playSound(String soundPath) async {
    if (Settings.voiceTalking) return;

    final audioPlayer = AudioPlayer();

    // config pour baisser temporairement la musique en cours
    await audioPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        usageType: AndroidUsageType.assistant,
        contentType: AndroidContentType.sonification,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.duckOthers},
      ),
    ));

    Settings.voiceTalking = true;

    try {
      await audioPlayer.play(AssetSource(soundPath));

      // attend la fin du son pour retablir le volume
      audioPlayer.onPlayerComplete.listen((_) async {
        Settings.voiceTalking = false;

        // retabli le volume normal en supprimant l'effet ducking
        await audioPlayer.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            audioFocus: AndroidAudioFocus.none,
            usageType: AndroidUsageType.assistant,
            contentType: AndroidContentType.sonification,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ));
      });
    } catch (e) {
      Settings.voiceTalking = false;
    }
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

  /// -------------------------- TOOLS --------------------------

  // Return le plus petit entier d'une liste
  static int getMinLevel(List<int> levels) {
    // A prendre en compte dans l'appel de la fonction
    if (levels.isEmpty) return -1;

    return levels.reduce(
        (currentMin, element) => currentMin < element ? currentMin : element);
  }

  /**
   * Police
   *  1: urgent, 2: medium, 3: far
   * 
   * Schema :
   * 
   *      Police
   *      |
   *   1  |
   *      |
   *      <Settings.policeThreshold1>
   *      |
   *   2  |
   *      |
   *      <Settings.policeThreshold2>
   *      |
   *   3  |
   *      |
   *      <Settings.policeThreshold3>
   * 
   *   3
   */
  static int getPoliceLevel(LatLng me, LatLng alert) {
    double distance = Common.calculateDistance(me, alert);

    if (distance <= Settings.policeThreshold1) {
      return 1;
    } else if (distance <= Settings.policeThreshold2) {
      return 2;
    } else if (distance <= Settings.policeThreshold3) {
      return 3;
    }
    return 3;
  }

  /**
   * ControlZone
   *  1: dedans, 2: medium, 3: far
   * 
   * Schema : 
   * 
   *      <Point central>
   *      |
   *  1   |  zone de controle
   *      |
   *      <rayon>
   *      |
   *  2   |  Settings.controlZoneThreshold
   *      |
   *      <Seuil d'alerte>
   * 
   *  3
   */
  static int getControlZoneLevel(
      LatLng me, LatLng alert, double radiusOfControlZone) {
    double distance = Common.calculateDistance(me, alert);

    if (distance <= radiusOfControlZone) {
      return 1;
    } else if (distance - radiusOfControlZone <=
        Settings.controlZoneThreshold) {
      return 2;
    }
    return 3;
  }
}
