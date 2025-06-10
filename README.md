# Sonare

## 1. Seuils

- Avertissement **le plus loin** : 3 km
- Avertissement **median** : 800m
- Avertissement **urgent** : 400m

## 2. Dev : help & tips

### 2.1 Build Xcode failed

```
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
flutter clean
flutter pub get
flutter build ios
```

### 2.2 Modifier son de notification

1. Dans Xcode :
Faire glisser le fichier audio (<sound_name>.aiff) depuis le finder vers le dossier Runner dans la section Project Navigator (sur la gauche).
Une boîte de dialogue s'affiche : cliquer sur OK.

2. Ajouter le son dans le code :
const DarwinNotificationDetails iosPlatformChannelSpecifics =
  DarwinNotificationDetails(
  ...
  sound: '<sound_name>.aiff', // Nom du fichier (sans son path)
);


# @TODO

Quand report la police :
BUG :
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Null check operator used on a null value
#0      StatefulElement.state (package:flutter/src/widgets/framework.dart:5848:44)
framework.dart:5848
#1      Navigator.of (package:flutter/src/widgets/navigator.dart:2875:38)
navigator.dart:2875
#2      _MainPageState._showReportSheet.<anonymous closure>.<anonymous closure> (package:Sonare/pages/main_page.dart:175:23)
main_page.dart:175
#3      _ReportSheetState.report.<anonymous closure> (package:Sonare/widgets/reportSheet.dart:60:21)