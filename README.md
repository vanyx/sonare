# \\\_|\_/ SONARE

## 1. Seuils

- Avertissement **le plus loin** : 3 km
- Avertissement **median** : 800m
- Avertissement **urgent** : 400m

## 2. Avantage PREMIUM

- Carte stylé
- Possibilité de connecter un boitier

## 3. Dev

### 3.1 Modifier son de notification

1. Dans Xcode :
Faire glisser le fichier audio (<sound_name>.aiff) depuis le finder vers le dossier Runner dans la section Project Navigator (sur la gauche).
Une boîte de dialogue s'affiche : cliquer sur OK.

2. Ajouter le son dans le code :
const DarwinNotificationDetails iosPlatformChannelSpecifics =
  DarwinNotificationDetails(
  ...
  sound: '<sound_name>.aiff', // Nom du fichier sans chemin
);

### A tester sur android :
- textes des autorisations
- notif, sons, musique en arriere plan et que apres un son la musique reprenne,
 boussole, vibrations, webview qui fonctionnement correctement, son des notifs, background