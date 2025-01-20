import 'dart:io';
import 'package:Sonare/services/common_functions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Settings {
  /// -------------------------- INITIALISATION --------------------------

  static Future<void> initialize() async {
    wishUrl = await fetchWishUrl();

    soundEnable = await Common.getSoundEnabled();
    notificationEnable = await Common.getNotificationsEnabled();
  }

  static Future<void> requestLocationPermission() async {
    print('je demande');
    locationPermission = await checkLocationPermission();
    print(locationPermission);
  }

  static Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      notificationPermission = await checkNotificationPermissionAndroid();
    } else if (Platform.isIOS) {
      notificationPermission = await checkNotificationPermissionIOS();
    }
  }

  static Future<String> fetchWishUrl() async {
    //@TODO
    //fonction tmp
    await Future.delayed(Duration(seconds: 1));
    return 'https://www.waze.com/live-map/api/georss';
  }

  static Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      if (permission == LocationPermission.denied) {
        return false; // Permission refusee
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Permission definitivement refusee
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return false; // Service de localisation desactives
    }

    return true;
  }

  static Future<bool> checkNotificationPermissionIOS() async {
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

  static Future<bool> checkNotificationPermissionAndroid() async {
    if (Platform.isAndroid) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      final bool? isGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();

      return isGranted ?? false;
    }
    return false;
  }

  /// -------------------------- SETTINGS DATA --------------------------

  static bool appIsActive = true;

  static bool locationPermission = false;

  static bool notificationPermission = false;

  static bool soundEnable = false;

  static bool notificationEnable = false;

  static String version = "1.0.0";

  static String termsUrl = 'https://fr.wikipedia.org/wiki/Lorem_ipsum';

  static String mapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static String wishUrl = '';

  /**************** Seuils ****************/

  /// Seuil d'alerte le plus éloigné en m.
  static double furthestThreshold = 3000;

  /// Seuil d'alerte médian en m.
  static double medianThreshold = 800;

  /// Seuil d'alerte urgent en m.
  static double urgentThreshold = 400;

  /**************** Notif sharedPreferences keys ****************/

  static const String tutorialKey = 'tutorialDone';
  static const String soundKey = 'soundEnabled';
  static const String notificationsKey = 'notificationsEnabled';
}
