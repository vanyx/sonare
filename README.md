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


### Quand j'aurais l'api
- Version API, mapUrl
- configurer les routes dans Settings
- report fishs
- ajouter termes et conditions les memes que dans radar bot (attention dans certains pays c'est interdit dcp c'est votre faute, à la premiere requete de l'api on considere que vous acceptez les conditions, si ous mourrez c'est pas de notre faute, on fait ca seulement à but de securité routiere, etc., ADAPTER POUR LES CRITERES DANS LA LOI (app destiné à l'aide à la navigation etc.))


### A tester sur android :
- textes des autorisations
- notif, sons, boussole, vibrations, webview qui fonctionnement correctement, son des notifs, background


# 📌 Licence

Ce projet a été entièrement imaginé, conçu et développé par **Thomas Benalouane**.  

Copyright (c) 2025 Thomas Benalouane
