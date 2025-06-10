import 'dart:async';
import 'package:Sonare/services/settings.dart';
import 'package:Sonare/services/common_functions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../models/models.dart';

class BackgroundService {
  bool running = false;
  final Location _location = Location();

  final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  LatLng? _currentPosition;
  LatLng? _lastApiPosition;

  List<AlertSonareWrapper> _alerts = [];

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

    _alerts = [];

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
    bool alertsInitialized = false;

    _locationSubscription =
        _location.onLocationChanged.listen((LocationData location) {
      if (!running || Settings.appIsActive) {
        _locationSubscription?.cancel();
        return;
      }
      _currentPosition = LatLng(location.latitude!, location.longitude!);
      if (!alertsInitialized) {
        alertsInitialized = true;
        initAlerts();
      } else {
        updateBackground();
      }
    });
  }

  Future<void> initAlerts() async {
    if (_currentPosition == null) return;

    _lastApiPosition = _currentPosition;

    List<Alert> alerts = await Common.getAlertByRadius(_currentPosition!);

    List<Map<String, dynamic>> levelsToAnnounce = [];

    for (var item in alerts) {
      if (Common.calculateDistance(_currentPosition!, item.position) <=
          Settings.policeThreshold3) {
        int level;
        String type;

        if (item is ControlZone) {
          level = Common.getControlZoneLevel(
              _currentPosition!, item.position, item.radius);
          type = "ControlZone";
        } else if (item is Police) {
          level = Common.getPoliceLevel(_currentPosition!, item.position);
          type = "Police";
        } else {
          continue; // Ignore les types inconnus
        }

        _alerts.add(AlertSonareWrapper(alert: item, level: level, size: 1));
        levelsToAnnounce.add({"level": level, "type": type});
      }
    }

    // Notification pour l'alerte la plus prioritaire
    if (levelsToAnnounce.isNotEmpty) {
      var minAlert = levelsToAnnounce.reduce((a, b) {
        if (a["level"] == b["level"]) {
          // Priorité à la Police si les niveaux sont égaux
          return a["type"] == "Police" ? a : b;
        }
        return a["level"] < b["level"] ? a : b;
      });

      if (Settings.notificationPermission && Settings.notificationEnable) {
        notifyByLevel(minAlert["level"], minAlert["type"]);
      }
    }
  }

  void updateBackground() async {
    if (_currentPosition == null) return;

    // Distance minimale avant un nouvel appel API en mètres
    double apiCallDistanceThreshold = Settings.policeThreshold3 / 10;

    // Filtrage des alertes existantes
    _alerts.removeWhere((item) =>
        Common.calculateDistance(_currentPosition!, item.alert.position) >
        Settings.policeThreshold3);

    List<Map<String, dynamic>> levelsToAnnounce = [];

    // Mise à jour des niveaux des alertes existantes
    for (var item in _alerts) {
      int newLevel;
      if (item.alert is ControlZone) {
        newLevel = Common.getControlZoneLevel(_currentPosition!,
            item.alert.position, (item.alert as ControlZone).radius);
      } else if (item.alert is Police) {
        newLevel =
            Common.getPoliceLevel(_currentPosition!, item.alert.position);
      } else {
        continue; // Ignore les types inconnus
      }

      if (newLevel < item.level) {
        levelsToAnnounce.add(
            {"level": newLevel, "type": item.alert.runtimeType.toString()});
      }
      if (newLevel != item.level) {
        item.level = newLevel; // Met à jour le niveau
      }
    }

    // Notification pour l'alerte la plus prioritaire
    if (levelsToAnnounce.isNotEmpty) {
      var minAlert = levelsToAnnounce.reduce((a, b) {
        if (a["level"] == b["level"]) {
          // Priorité à la Police si les niveaux sont égaux
          return a["type"] == "Police" ? a : b;
        }
        return a["level"] < b["level"] ? a : b;
      });

      if (Settings.notificationPermission && Settings.notificationEnable) {
        notifyByLevel(minAlert["level"], minAlert["type"]);
      }
    }

    // Vérifie si la position a suffisamment changé avant de faire un nouvel appel API
    if (_lastApiPosition != null) {
      if (Common.calculateDistance(_lastApiPosition!, _currentPosition!) <
          apiCallDistanceThreshold) {
        return;
      }
    }

    // Sinon, fetch les nouvelles alertes
    _lastApiPosition = _currentPosition;

    List<Map<String, dynamic>> newLevelsToAnnounce = [];
    List<Alert> alerts = await Common.getAlertByRadius(_currentPosition!);

    for (var item in alerts) {
      if (!existPositionInAlerts(item.position) &&
          Common.calculateDistance(_currentPosition!, item.position) <=
              Settings.policeThreshold3) {
        int level;
        String type;
        if (item is ControlZone) {
          level = Common.getControlZoneLevel(
              _currentPosition!, item.position, item.radius);
          type = "ControlZone";
        } else if (item is Police) {
          level = Common.getPoliceLevel(_currentPosition!, item.position);
          type = "Police";
        } else {
          continue; // Ignore les types inconnus
        }

        _alerts.add(AlertSonareWrapper(alert: item, level: level, size: 1));
        newLevelsToAnnounce.add({"level": level, "type": type});
      }
    }

    // Notification pour les nouvelles alertes
    if (newLevelsToAnnounce.isNotEmpty) {
      var minNewAlert = newLevelsToAnnounce.reduce((a, b) {
        if (a["level"] == b["level"]) {
          // Priorité à la Police si les niveaux sont égaux
          return a["type"] == "Police" ? a : b;
        }
        return a["level"] < b["level"] ? a : b;
      });

      if (Settings.notificationPermission && Settings.notificationEnable) {
        notifyByLevel(minNewAlert["level"], minNewAlert["type"]);
      }
    }
  }

  bool existPositionInAlerts(LatLng position) {
    for (var item in _alerts) {
      if (item.alert.position.latitude == position.latitude &&
          item.alert.position.longitude == position.longitude) {
        return true;
      }
    }
    return false;
  }

  Future<void> notifyByLevel(int level, String type) async {
    String alertType = type == "Police" ? "Police" : "Zone de contrôle";
    String message;

    if (level == 1) {
      message = "$alertType à moins de 400 mètres !";
    } else if (level == 2) {
      message = "$alertType à moins de 800 mètres !";
    } else if (level == 3) {
      message = "$alertType à moins de 3 km.";
    } else {
      return; // Niveau inconnu
    }

    await sendNotification(message);
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
