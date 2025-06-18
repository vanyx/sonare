# Dev

### 1. Run en mode release

```bash
flutter run --release
```

### 2. Build Xcode failed

```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
flutter clean
flutter pub get
flutter build ios
```

### 3. Modifier son de notification

1. Dans Xcode :
Faire glisser le fichier audio (*<sound_name>.aiff*) depuis le finder vers le dossier Runner dans la section Project Navigator (sur la gauche).
Une boîte de dialogue s'affiche : cliquer sur OK.

2. Ajouter le son dans le code :
```dart
const DarwinNotificationDetails iosPlatformChannelSpecifics =
  DarwinNotificationDetails(
  ...
  sound: '<sound_name>.aiff', // Nom du fichier (sans son path)
);
```