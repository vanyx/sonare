import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';
import '../services/settings.dart';
import '../services/common_functions.dart';

class Fauna {
  String type;
  LatLng position;
  int level;

  Fauna({required this.type, required this.position, required this.level});
}

class BackgroundService {
  static LatLng? _currentPosition;
  static StreamSubscription<Position>? _positionSubscription;

  static List<Fauna> _faunas = [];

  static LatLng? _lastApiPosition;

  static bool _isSoundEnabled = true;

  static final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _notificationsAllowed = true;

  static final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: _onStart,
        isForegroundMode: false,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
    _service.startService();
  }

  static bool _onIosBackground(ServiceInstance service) {
    print("IOS BACKGROUND !");
    return true;
  }

  static void _onStart(ServiceInstance service) async {
    await _initializeNotifications();

    // await BackgroundLocation.startLocationService(distanceFilter: 10);

    _functionTest();
    getLocation();
  }

  /// Test d'envoi de notifications toutes les 5 secondes
  static void _functionTest() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      print(AppLifecycleState.paused);
      await _sendNotification("test");
    });
  }

  static void getLocation() async {
    // BackgroundLocation.getLocationUpdates((location) async {
    //   _currentPosition = new LatLng(location.latitude!, location.longitude!);
    // });
  }
/**
 * Ce que j'avais fait avant mais qui ne fonctionne pas EN DESSOUS, mais à integrer
 * 
 * Les methodes et attribus doivent être static, j'ai testé
 * Le probleme maintenant est : comment obtenir la position de l'utilisateur en arriere plan ?
 * Car usage restreint par OS, donc gelolocator ne fonctione pas
 * 
 */

// /*
// TODO: à l'init, aller chercher les faunas et les annoncer
// */

  // static Future<void> initLocation() async {
  //   LocationPermission permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     return;
  //   }
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.bestForNavigation);

  //   _currentPosition = LatLng(position.latitude, position.longitude);
  //   _lastApiPosition = _currentPosition;

  //   await _sendNotification("position OK, tu es ${_currentPosition}");
  // }

//   static void _onStart(ServiceInstance service) async {
//     if (service is AndroidServiceInstance) {
//       service.on('setAsForeground').listen((event) {
//         service.setAsForegroundService();
//       });

//       service.on('setAsBackground').listen((event) {
//         service.setAsBackgroundService();
//       });
//     }

//     service.on('stopService').listen((event) {
//       _positionSubscription?.cancel();
//       service.stopSelf();
//     });

//     _service.on("stop").listen((event) {
//       _positionSubscription?.cancel();
//     });

//     if (service is AndroidServiceInstance) {
//       service.setForegroundNotificationInfo(
//         title: "Service Actif",
//         content: "Suivi de localisation en cours...",
//       );
//     }

//     Common.getSoundEnabled().then((value) {
//       _isSoundEnabled = value;
//     });

//     await _initializeNotifications();

//     // _sendNotification("connard");
//     // await initLocation();
//     // _startListeningToLocationChanges();
//   }

//   static void _startListeningToLocationChanges() {
//     _positionSubscription = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//       ),
//     ).listen((Position position) {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//       updateBackground();
//     });
//   }

//   static void updateBackground() async {
//     if (_currentPosition == null) return;

//     // Distance min avant nouvel appel API en m
//     double apiCallDistanceThreshold = Settings.furthestThreshold / 10;

//     // filtrage
//     _faunas.removeWhere((fauna) =>
//         Common.calculateDistance(_currentPosition!, fauna.position) >
//         Settings.furthestThreshold);

//     bool firstAnounced = false;

//     List<int> levelsToAnnounce = [];

//     // Update des levels existants
//     for (var fauna in _faunas) {
//       int newLevel = Common.getFaunaLevel(_currentPosition!, fauna.position);

//       if (newLevel < fauna.level) {
//         levelsToAnnounce.add(newLevel);
//       }
//       if (newLevel != fauna.level) {
//         fauna.level = newLevel;
//       }
//     }
//     // Annonce sonore eventuelle du fauna le plus proche si changement
//     int firstMaxLevelExisting = Common.getMaxLevel(levelsToAnnounce);
//     if (firstMaxLevelExisting != -1 && _isSoundEnabled) {
//       firstAnounced = true;
//       Common.playWarningByLevel(firstMaxLevelExisting);
//     }

//     // return si pas assez bougé
//     if (_lastApiPosition != null) {
//       if (Common.calculateDistance(_lastApiPosition!, _currentPosition!) <
//           apiCallDistanceThreshold) {
//         return;
//       }
//     }

//     // CALL NEW FAUNAs

//     print("call api");

//     _lastApiPosition = _currentPosition;

//     List<int> tmpLevels = [];

//     List<LatLng> wish = await Common.getWishByPosition(_currentPosition!);

//     print('il y a des nouveaux : ${wish.length}');
//     for (var position in wish) {
//       if (!existPositionInFauna(position)) {
//         _faunas.add(Fauna(
//             position: position,
//             type: 'fish',
//             level: Common.getFaunaLevel(_currentPosition!, position)));

//         // util pour les sons et notif
//         tmpLevels.add(Common.getFaunaLevel(_currentPosition!, position));
//       }
//     }

//     int firstMaxLevel = Common.getMaxLevel(tmpLevels);

//     // Annonce sonore eventuelle du nouveau fauna le plus proche
//     if (!firstAnounced) {
//       if (firstMaxLevel != -1 && _isSoundEnabled) {
//         Common.playWarningByLevel(firstMaxLevel);
//       }
//     }

//     _notifyByLevel(firstMaxLevel);
//   }

//   static bool existPositionInFauna(LatLng position) {
//     for (Fauna fauna in _faunas) {
//       if (fauna.position.latitude == position.latitude &&
//           fauna.position.longitude == position.longitude) {
//         return true;
//       }
//     }
//     return false;
//   }

  static Future<void> _notifyByLevel(int level) async {
    print("je dois notif pour le level $level");
    if (level == 1)
      await _sendNotification(
          "Présence détéctée à moins de ${Settings.urgentThreshold} mètres !");
    else if (level == 2)
      await _sendNotification(
          "Présence détéctée à moins de ${Settings.medianThreshold} mètres !");
    else if (level == 3)
      await _sendNotification("Présence détéctée à moins de 3 km .");
  }

  static Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotifications.initialize(initializationSettings);

    // Permissions pour IOS
    final bool? granted = await _flutterLocalNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (granted == false || granted == null) {
      _notificationsAllowed = false;
    } else {
      _notificationsAllowed = true;
    }
  }

  static Future<void> _sendNotification(String notifContent) async {
    if (!_notificationsAllowed) {
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotifications.show(
      0,
      'Sonare',
      notifContent,
      platformChannelSpecifics,
    );
  }
}
