import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _notificationsAllowed = true;

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
    _service.startService();
  }

  static bool _onIosBackground(ServiceInstance service) {
    return true;
  }

  static void _onStart(ServiceInstance service) async {
    // @TODO : à supprimer ?
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Service Actif",
        content: "Suivi de localisation en cours...",
      );
    }

    await _initializeNotifications();

    _functionTest();
  }

  /// listenToLocationChanges, qui appel updateFish
  /// updateFish annonce les fauna si detecté
  /// si sueil de deplacement ok fait un call api
  /// => annonce eventuelle des nouveaux sfauna
  ///
  ///
  ///

  /// Test d'envoi de notifications toutes les 5 secondes
  static void _functionTest() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _sendNotification("test poli");
    });
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
