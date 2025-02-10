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
  if (Settings.tutorialDone) {
    await Common.requestPermissions();
  }
  Common.initializeSonare();
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
    // _backgroundService.initialize(); // initialize background
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
      if (Settings.tutorialDone) {
        _backgroundService
            .start(); // Ne fonctionne que si le tuto a deja ete fait
      }
    } else if (state == AppLifecycleState.resumed) {
      Settings.appIsActive = true;
      _backgroundService.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TutorialChecker(backgroundService: _backgroundService),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TutorialChecker extends StatefulWidget {
  final BackgroundService backgroundService;

  TutorialChecker({required this.backgroundService});

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
    if (tutorialDone) {
      widget.backgroundService
          .initialize(); // Initialisation du background si le tuto a deja ete fait
    }
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
  Future<void> _onTutorialCompleted() async {
    await Common.setTutorialDone(true);
    await Common.requestPermissions();
    widget.backgroundService
        .initialize(); // initialise le background une fois le tuto fini
    _isTutorialDone.value = true;
  }
}
