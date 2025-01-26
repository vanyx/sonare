# Sonare

## Seuils

- Avertissement **le plus loin** : 3 km
- Avertissement **median** : 800m
- Avertissement **urgent** : 400m

## Avantage PREMIUM

- Carte stylé
- Possibilité de connecter un boitier

## Ajouter son de notification

1. Dans Xcode :
Faire glisser le fichier audio (custom_sound.aiff) depuis le finder vers le dossier Runner dans la section Project Navigator (sur la gauche).
Une boîte de dialogue s'affiche : cliquer sur OK.

2. Ajouter le son dans le code :
const DarwinNotificationDetails iosPlatformChannelSpecifics =
  DarwinNotificationDetails(
  ...
  sound: 'custom_sound.aiff', // Nom du fichier sans chemin.
);

# TODO

=> utiliser background service : Fais quelque chose que si Setting.isActive est true
à tester...

voir :
https://medium.com/flutter/executing-dart-in-the-background-with-flutter-plugins-and-geofencing-2b3e40a1a124
https://stackoverflow.com/questions/53450029/flutter-cross-platform-way-to-keep-application-running-in-the-background
(peut etre trop vieux)

- changer icons / images : poisson, coquillage et images de selection

## Quand j'aurais l'api
- activer/desactiver des options à distance
- url wish + desactiver ou non à distance l'utilisation de wish ?
- report fishs
- integration sonare radars, puis regrouper l'appel des 2 api en une seule fonction ?
- ajouter termes et conditions les memes que dans radar bot (attention dans certains pays c'est interdit dcp c'est votre faute, à la premiere requete de l'api on considere que vous acceptez les conditions, si ous mourrez c'est pas de notre faute, on fait ca seulement à but de securité routiere, etc.) regarder aussi ceux de "signalRat"


## A tester sur android :
- textes des autorisations
- notif, sons, boussole, vibrations, webview qui fonctionnement correctement, son des notifs


