class Settings {
  /// -------------------------- INITIALISATION --------------------------

  static Future<void> initialize() async {
    wishUrl = await _fetchWishUrl();
  }

  static Future<String> _fetchWishUrl() async {
    //@TODO
    //fonction tmp
    await Future.delayed(Duration(seconds: 1));
    return 'https://www.waze.com/live-map/api/georss';
  }

  /// -------------------------- SETTINGS DATA --------------------------

  static String version = "1.0.0";

  static String termsUrl = 'https://fr.wikipedia.org/wiki/Lorem_ipsum';

  /**************** Map URL ****************/

  static String mapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /**************** API URLs ****************/

  static String wishUrl = '';

  /**************** Seuils ****************/

  /// Seuil d'alerte le plus éloigné en m.
  static double furthestThreshold = 3000;

  /// Seuil d'alerte médian en m.
  static double medianThreshold = 500;

  /// Seuil d'alerte urgent en m.
  static double urgentThreshold = 100;

  /**************** Notif sharedPreferences keys ****************/

  static const String soundKey = 'soundEnabled';
  static const String notificationsKey = 'notificationsEnabled';
}
