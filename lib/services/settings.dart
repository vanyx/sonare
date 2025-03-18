import 'package:Sonare/services/common_functions.dart';

class Settings {
  /// -------------------------- INITIALISATION --------------------------

  static Future<void> initialize() async {
    soundEnable = await Common.getSoundEnabled();
    notificationEnable = await Common.getNotificationsEnabled();
    tutorialDone = await Common.getTutorialDone();
    policeEnable = await Common.getPoliceEnabled();
    controlZoneEnable = await Common.getControlZoneEnabled();
  }

  /// -------------------------- SETTINGS DATA --------------------------

  static bool tutorialDone = false;

  static bool appIsActive = true;

  static bool locationPermission = false;

  static bool notificationPermission = false;

  static bool soundEnable = false;

  static bool notificationEnable = false;

  static bool policeEnable = false;

  static bool controlZoneEnable = false;

  static const String version = '1.0.0'; //current version

  static String apiVersion = '1.0.0'; //version returned by api

  static String termsUrl = 'https://fr.wikipedia.org/wiki/Lorem_ipsum';

  static String mapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static bool voiceTalking = false;

  /**************** API - endpoints ****************/

  static String apiUrl = 'http://192.168.1.37:8080';

  static String apiInfoEndpoint = '/api/infos';

  static String getByWindowEndpoint = '/api/fauna/window';

  static String getByRadiusEndpoint = '/api/fauna/radius';

  static String postPoliceEndpoint = '/api/fauna/fish';

  static String postControlZoneEndpoint = '/api/fauna/shell';

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
  static const String policeKey = 'policeEnabled';
  static const String controlZoneKey = 'controlZoneEnabled';
}
