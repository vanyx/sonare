import 'dart:async';
import 'package:Sonare/models/FaunaBackground.dart';
import 'package:Sonare/services/settings.dart';
import 'package:Sonare/services/common_functions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../models/Fauna.dart';

class BackgroundService {
  bool running = false;
  final Location _location = Location();

  final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  LatLng? _currentPosition;
  LatLng? _lastApiPosition;

  List<FaunaBackground> _faunas = [];

  bool _locationInitializationIsOk = false;

  Future<void> initialize() async {
    // Enable mode background
    await _location.enableBackgroundMode(enable: true);

    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      // interval: 10000, // en millisecondes
      // distanceFilter: 50 // en metres
    );

    // Initialisation notifications
    await _initializeNotifications();

    // Permissions
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationInitializationIsOk = true;
  }

  void start() async {
    running = true;

    _faunas = [];

    _lastApiPosition = null;

    _currentPosition = null;

    if (!Settings.locationPermission || !_locationInitializationIsOk) {
      return;
    }

    _streamLocation();
  }

  void stop() {
    running = false;
    _locationSubscription?.cancel();
  }

  StreamSubscription<LocationData>? _locationSubscription;
  void _streamLocation() {
    bool _faunaInited = false;

    _locationSubscription =
        _location.onLocationChanged.listen((LocationData location) {
      if (!running || Settings.appIsActive) {
        _locationSubscription?.cancel();
        return;
      }
      _currentPosition = LatLng(location.latitude!, location.longitude!);
      if (!_faunaInited) {
        _faunaInited = true;
        initFaunas();
      } else {
        updateBackground();
      }
    });
  }

  Future<void> initFaunas() async {
    if (_currentPosition == null) return;

    _lastApiPosition = _currentPosition;

    List<Fauna> faunas = await Common.getFaunaByRadius(_currentPosition!);
    for (var fauna in faunas) {
      if (Common.calculateDistance(_currentPosition!, fauna.position) <=
          Settings.furthestThreshold) {
        _faunas.add(FaunaBackground(
          type: fauna.type,
          position: fauna.position,
          level: Common.getFaunaLevel(_currentPosition!, fauna.position),
        ));
      }
    }

    // Notif eventuelle du fauna le plus proche si URGENT (level <= 2)
    int firstMaxLevel =
        Common.getMaxLevel(_faunas.map((fauna) => fauna.level).toList());
    print(firstMaxLevel);
    if (firstMaxLevel <= 2 &&
        Settings.notificationPermission &&
        Settings.notificationEnable) {
      notifyByLevel(firstMaxLevel);
    }
  }

  void updateBackground() async {
    if (_currentPosition == null) return;

    // Distance min avant nouvel appel API en m
    double apiCallDistanceThreshold = Settings.furthestThreshold / 10;

    // filtrage
    _faunas.removeWhere((fauna) =>
        Common.calculateDistance(_currentPosition!, fauna.position) >
        Settings.furthestThreshold);

    bool firstAnounced = false;

    List<int> levelsToAnnounce = [];

    // Update des levels existants
    for (var fauna in _faunas) {
      int newLevel = Common.getFaunaLevel(_currentPosition!, fauna.position);

      if (newLevel < fauna.level) {
        levelsToAnnounce.add(newLevel);
      }
      if (newLevel != fauna.level) {
        fauna.level = newLevel;
      }
    }
    // Annonce notif eventuelle du fauna le plus proche si changement
    int firstMaxLevelExisting = Common.getMaxLevel(levelsToAnnounce);
    if (firstMaxLevelExisting != -1 && Settings.soundEnable) {
      firstAnounced = true;
      notifyByLevel(firstMaxLevelExisting);
    }

    // return si pas assez bougé
    if (_lastApiPosition != null) {
      if (Common.calculateDistance(_lastApiPosition!, _currentPosition!) <
          apiCallDistanceThreshold) {
        return;
      }
    }

    // Sinon, fetch les nouveaux :

    _lastApiPosition = _currentPosition;

    List<int> tmpLevels = [];

    List<Fauna> faunas = await Common.getFaunaByRadius(_currentPosition!);

    for (var fauna in faunas) {
      if (!existPositionInFauna(fauna.position) &&
          Common.calculateDistance(_currentPosition!, fauna.position) <=
              Settings.furthestThreshold) {
        _faunas.add(FaunaBackground(
          position: fauna.position,
          type: fauna.type,
          level: Common.getFaunaLevel(_currentPosition!, fauna.position),
        ));

        tmpLevels.add(Common.getFaunaLevel(_currentPosition!, fauna.position));
      }
    }

    int firstMaxLevel = Common.getMaxLevel(tmpLevels);

    if (firstMaxLevel > 0 && !firstAnounced) {
      // Annonce eventuelle du fauna le plus proche
      if (Settings.notificationPermission && Settings.notificationEnable) {
        notifyByLevel(firstMaxLevel);
      }
    }
  }

  bool existPositionInFauna(LatLng position) {
    for (Fauna fauna in _faunas) {
      if (fauna.position.latitude == position.latitude &&
          fauna.position.longitude == position.longitude) {
        return true;
      }
    }
    return false;
  }

  Future<void> notifyByLevel(int level) async {
    if (level == 1) {
      await sendNotification("Présence détéctée à moins de 400 mètres !");
    } else if (level == 2) {
      await sendNotification("Présence détéctée à moins de 800 mètres !");
    } else if (level == 3) {
      await sendNotification("Présence détéctée à moins de 3 km.");
    }
  }

  Future<void> _initializeNotifications() async {
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
  }

  Future<void> sendNotification(String notifContent) async {
    if (!Settings.notificationPermission || !Settings.notificationEnable) {
      return;
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('channel_id', 'channel_name',
              channelDescription: 'channel_description',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('notification'));

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification.aiff',
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
    } catch (e) {}
  }
}
