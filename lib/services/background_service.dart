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

  StreamSubscription<Position>? _positionSubscription;

  bool _notificationPermission = false;

  bool _notificationEnable = false;

  bool _soundEnable = false;

  // Constructeur
  BackService() {
    _initializeNotifications();
  }

  void onStart() async {
    if (!Settings.locationPermission) {
      print(Settings.locationPermission);
      return;
    }

    _notificationPermission = Settings.notificationPermission;
    _notificationEnable = await Common.getNotificationsEnabled();
    _soundEnable = await Common.getSoundEnabled();

    await _getCurrentLocation();
    _startListeningToLocationChanges();

    return;
  }

  void stopService() {
    _positionSubscription?.cancel();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    _currentPosition = LatLng(position.latitude, position.longitude);
  }

  void _startListeningToLocationChanges() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      print(_currentPosition);
      //@TODO : continuer ici
    });
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

  Future<void> _sendNotification(String notifContent) async {
    if (!_notificationPermission || !_notificationEnable) {
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
