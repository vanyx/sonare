// import 'dart:async';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:latlong2/latlong.dart';

// class BackgroundService {
//   LatLng? _currentPosition;
//   StreamSubscription<Position>? _positionSubscription;

//   final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
//       FlutterLocalNotificationsPlugin();

//   bool _notificationsAllowed = true;

//   final FlutterBackgroundService _service = FlutterBackgroundService();

//   Future<void> initialize() async {
//     initLocation();
//     await _service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: _onStart,
//         isForegroundMode: true,
//       ),
//       iosConfiguration: IosConfiguration(
//         onForeground: _onStart,
//         onBackground: _onIosBackground,
//       ),
//     );
//     _service.startService();
//   }

//   Future<bool> _onIosBackground(ServiceInstance service) async {
//     print("onIosbackground");
//     if (service is AndroidServiceInstance) {
//       service.setForegroundNotificationInfo(
//         title: "@TODO",
//         content: "c quoi ce truc",
//       );
//     }

//     await _initializeNotifications();
//     await Future.delayed(Duration(
//         seconds: 2)); //necessite un delai avant l'envoi des premieres notif
//     _sendNotification("toto");
//     _startListeningToLocationChanges();

//     return true;
//   }

//   Future<void> initLocation() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       return;
//     }
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation);

//     _currentPosition = LatLng(position.latitude, position.longitude);
//   }

//   Future<void> _onStart(ServiceInstance service) async {
//     print("onStart");
//     if (service is AndroidServiceInstance) {
//       service.setForegroundNotificationInfo(
//         title: "@TODO",
//         content: "c quoi ce truc",
//       );
//     }

//     await _initializeNotifications();
//     await Future.delayed(Duration(
//         seconds: 2)); //necessite un delai avant l'envoi des premieres notif
//     _sendNotification("toto");
//     _startListeningToLocationChanges();
//   }

//   void _startListeningToLocationChanges() {
//     _positionSubscription = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//       ),
//     ).listen((Position position) {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//       print(_currentPosition);
//     });
//   }

//   Future<void> _initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');

//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings();

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await _flutterLocalNotifications.initialize(initializationSettings);

//     // Permissions pour IOS
//     final bool? granted = await _flutterLocalNotifications
//         .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//     if (granted == false || granted == null) {
//       _notificationsAllowed = false;
//     } else {
//       _notificationsAllowed = true;
//     }
//   }

//   Future<void> _sendNotification(String notifContent) async {
//     if (!_notificationsAllowed) {
//       return;
//     }

//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       channelDescription: 'channel_description',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const DarwinNotificationDetails iosPlatformChannelSpecifics =
//         DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iosPlatformChannelSpecifics,
//     );

//     await _flutterLocalNotifications.show(
//       0,
//       'Sonare',
//       notifContent,
//       platformChannelSpecifics,
//     );
//   }
// }
