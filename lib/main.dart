import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/main_page.dart';
import 'pages/tutorial_page.dart';
import 'services/background_service.dart';
import 'services/settings.dart';
import 'services/common_functions.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Settings.initialize();
  if (Settings.tutorialDone) await Common.requestPermissions();
  Common.initializeSonare();
  await Common.setTutorialDone(false);
  runApp(Sonare());
}

class Sonare extends StatefulWidget {
  @override
  _SonareState createState() => _SonareState();
}

class _SonareState extends State<Sonare> with WidgetsBindingObserver {
  final BackgroundService _backgroundService = BackgroundService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundService.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Settings.appIsActive = false;
      _backgroundService.start();
    } else if (state == AppLifecycleState.resumed) {
      Settings.appIsActive = true;
      _backgroundService.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TutorialChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TutorialChecker extends StatefulWidget {
  @override
  _TutorialCheckerState createState() => _TutorialCheckerState();
}

class _TutorialCheckerState extends State<TutorialChecker> {
  ValueNotifier<bool> _isTutorialDone = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeTutorialStatus();
  }

  Future<void> _initializeTutorialStatus() async {
    final tutorialDone = await Common.getTutorialDone();
    _isTutorialDone.value = tutorialDone;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isTutorialDone,
      builder: (context, isTutorialDone, child) {
        return isTutorialDone
            ? MainPage()
            : TutorialPage(onTutorialCompleted: _onTutorialCompleted);
      },
    );
  }

  // callback appelé par TutorialPage quand le tuto est terminé
  void _onTutorialCompleted() async {
    await Common.setTutorialDone(true);
    await Common.requestPermissions();
    _isTutorialDone.value = true;
  }
}
