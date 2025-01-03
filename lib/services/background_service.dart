import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';

class Fauna {
  final String type;
  final LatLng position;

  Fauna({required this.type, required this.position});
}

/*

TODO: à l'init, aller chercher les faunas et les annoncer
*/

class BackgroundService {
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;

  List<Fauna> _faunas = [];

  final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  bool _notificationsAllowed = true;

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    initLocation();
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

  bool _onIosBackground(ServiceInstance service) {
    return true;
  }

  Future<void> initLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    _currentPosition = LatLng(position.latitude, position.longitude);
  }

  void _onStart(ServiceInstance service) async {
    // @TODO : à supprimer ?
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Service Actif",
        content: "Suivi de localisation en cours...",
      );
    }

    await _initializeNotifications();
    _startListeningToLocationChanges();
  }

  void _startListeningToLocationChanges() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      updateBackground();
    });
  }

  void updateBackground() {
    /**
        * 
        TODO :
        - Supprimer les wishs existants si plus dans le seuil de distance
        - anoncer le plus proche si il y a un changement de seuil
        - call api si seuilApi depassé
        - les ajouter à faunas
         */
  }

  /// Test d'envoi de notifications toutes les 5 secondes
  void _functionTest() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _sendNotification("test poli");
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

  Future<void> _sendNotification(String notifContent) async {
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
