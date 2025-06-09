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


## TODO

- Apres signaler un bail, refresh

- modifier assets son police par "police à moins de x distance (changer presence et detecté)"

- notifications
