import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/main_page.dart';
import 'services/background_service.dart';
import 'services/settings.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.initialize();
  initializeService();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
