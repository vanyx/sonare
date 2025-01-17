import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/main_page.dart';
import 'services/background_service.dart';
import 'services/settings.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Settings.initialize();
  runApp(Sonare());
}

class Sonare extends StatefulWidget {
  @override
  _SonareState createState() => _SonareState();
}

class _SonareState extends State<Sonare> with WidgetsBindingObserver {
  final BackService _backService = BackService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backService.stopService();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Settings.appIsActive = false;
      _backService.onStart();
    } else if (state == AppLifecycleState.resumed) {
      Settings.appIsActive = true;
      _backService.stopService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
