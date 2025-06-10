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

  static bool soundEnable = true;

  static bool notificationEnable = true;

  static bool policeEnable = true;

  static bool controlZoneEnable = true;

  static const String version = '1.0.0'; //current version

  static String apiVersion = '1.0.0'; //version returned by api

  static String termsUrl = 'https://fr.wikipedia.org/wiki/Lorem_ipsum';

  static String mapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static bool voiceTalking = false;

  /**************** API - endpoints ****************/

  // @TODO: Change this to your API URL
  static String apiUrl = 'http://172.20.10.2:8080';

  static String apiInfoEndpoint = '/api/infos';

  static String getByWindowEndpoint = '/api/alerts/window';

  static String getByRadiusEndpoint = '/api/alerts/radius';

  static String postPoliceEndpoint = '/api/alerts/police';

  static String postControlZoneEndpoint = '/api/alerts/control-zone';

  /**************** Seuils ****************/

  /// Seuil d'alerte le plus éloigné en m.
  static double policeThreshold3 = 3000;

  /// Seuil d'alerte médian en m.
  static double policeThreshold2 = 800;

  /// Seuil d'alerte urgent en m.
  static double policeThreshold1 = 400;

  /// Seuil d'alerte en m.
  static double controlZoneThreshold = 800;

  /**************** Notif sharedPreferences keys ****************/

  static const String tutorialKey = 'tutorialDone';
  static const String soundKey = 'soundEnabled';
  static const String notificationsKey = 'notificationsEnabled';
  static const String policeKey = 'policeEnabled';
  static const String controlZoneKey = 'controlZoneEnabled';
}
