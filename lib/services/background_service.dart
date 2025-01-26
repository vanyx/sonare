import 'dart:async';
import 'package:Sonare/services/settings.dart';
import 'package:Sonare/services/common_functions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Fauna {
  String type;
  LatLng position;
  int level;

  Fauna({required this.type, required this.position, required this.level});
}

class BackService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  LatLng? _currentPosition;
  LatLng? _lastApiPosition;

  StreamSubscription<Position>? _positionSubscription;

  List<Fauna> _faunas = [];

  Future<void> onStart() async {
    if (!Settings.locationPermission) {
      return;
    }
    await _initializeNotifications();
    await Future.delayed(Duration(
        seconds: 2)); //necessite un delai avant l'envoi des premieres notif

    // @TODO
    sendNotification("init");

    await _getCurrentLocation();
    await initFaunas();

    _startListeningToLocationChanges();

    return;
  }

  void stopService() {
    _positionSubscription?.cancel();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {}
  }

  void _startListeningToLocationChanges() {
    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).listen((Position position) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        updateBackground();
      });
    } catch (e) {}
  }

  Future<void> initFaunas() async {
    if (_currentPosition == null) return;

    _lastApiPosition = _currentPosition;

    // fetch
    List<LatLng> wish = await Common.getWishByPosition(_currentPosition!);

    for (var position in wish) {
      if (Common.calculateDistance(_currentPosition!, position) <=
          Settings.furthestThreshold) {
        _faunas.add(Fauna(
            type: 'fish',
            position: position,
            level: Common.getFaunaLevel(_currentPosition!, position)));
      }
    }

    // Annonce sonore eventuelle du fauna le plus proche si URGENT (level = 2)
    int firstMaxLevel =
        Common.getMaxLevel(_faunas.map((fauna) => fauna.level).toList());

    // Envoi notif
    if (firstMaxLevel == 2 &&
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

    List<LatLng> wish = await Common.getWishByPosition(_currentPosition!);

    for (var position in wish) {
      if (!existPositionInFauna(position) &&
          Common.calculateDistance(_currentPosition!, position) <=
              Settings.furthestThreshold) {
        _faunas.add(Fauna(
            position: position,
            type: 'fish',
            level: Common.getFaunaLevel(_currentPosition!, position)));

        tmpLevels.add(Common.getFaunaLevel(_currentPosition!, position));
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
