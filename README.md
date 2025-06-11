# Sonare - Navigation communautaire & affichage immersif (sonar sous-marin/GTA IV)

<p align="center">
  <img src="flutter/assets/images/logo/icon_and_background.png" alt="logo" width="150"/>
</p>

# ⚠️ Disclaimer

Ce projet est strictement destiné à un usage éducatif et technique.  
  
Sonare est une expérimentation personnelle en développement mobile, design d’interface et systèmes de géolocalisation.
Il a été imaginé, conçu et développé dans le seul but de réaliser un projet complet de A à Z, en explorant toutes les étapes : de l’idée initiale à la mise en œuvre technique.  
Ce projet n’a aucune vocation à être utilisé dans un contexte réel, ni à être publié ou diffusé.  
  
L'application ne doit en aucun cas être utilisée en situation de conduite, ni servir à contourner la loi, à éviter des contrôles routiers ou à détecter la présence des forces de l’ordre.  
Tout usage détourné du code ou des concepts présentés est formellement déconseillé. L’auteur décline toute responsabilité en cas de mauvaise utilisation.  


# 1. Description

Sonare est une application mobile de navigation communautaire, conçue pour visualiser en temps réel les zones de contrôle routier et la présence policière.  
  
Inspirée de l’expérience utilisateur de Waze et de l’interface immersive des mini-cartes comme Grand Theft Auto (GTA), elle propose deux modes de visualisation complémentaires : une carte classique affichant toutes les informations géolocalisées, et une mini-carte circulaire centrée sur l’utilisateur.  
  
Cette mini-carte, affiche uniquement la zone autour du conducteur dans un cercle. Les zones de contrôle proches apparaissent sous forme de marqueurs directement sur la carte, tandis que celles plus éloignées sont indiquées sur le bord du cercle par des points dont la taille varie selon la distance, offrant ainsi une perception intuitive des alertes à proximité.  
  
L’objectif principal de Sonare est de démontrer une approche technique complète de développement mobile, mêlant géolocalisation, gestion de bases de données, interface utilisateur intuitive et affichage cartographique dynamique.  
Cette application sert avant tout d’exemple d’exploration technique et d’interface avancée, et n’est pas destinée à un usage réel.


# 2. Fonctionnalités

## Navigation et visualisation

**2 modes de carte distincts :**

- **Mode Explorer** : Carte classique, style Google Maps, offrant une vue ouverte et fluide.
  Affichage en temps réel des zones de contrôle et de la présence policière, signalées à la fois par la communauté et via une base de données intégrée.  
  Les alertes proches sont affichées sous forme de marqueurs précis. Lors du dézoom, ces marqueurs se regroupent en "centroids" pour éviter la surcharge visuelle.  
  Le déplacement de la carte suit de manière fluide la position de l’utilisateur sans à-coups.


- **Mode Sonare** : Interface inspirée d'un sonar sous-marin et de la mini-carte de GTA IV.
  Carte centrée sur la position de l’utilisateur, avec possibilité de zoomer mais sans déplacement manuel de la carte.  
  La rotation de la carte se fait via la boussole du telephone de l'utilisateur, et via le vecteur de direction de deplacement si il est en mouvement.  
  Les alertes à l’intérieur du cercle apparaissent sous forme de marqueurs comme dans le mode Explorer.  
  Les alertes hors du cercle sont affichées sur la bordure sous forme de points dynamiques, qui tournent avec la rotation de la carte et dont la taille varie en fonction de la distance.

## Système d’alerte et notifications

Seuils de distance pour les alertes :
- Avertissement le plus loin : 3 km
- Avertissement médian : 800 m
- Avertissement urgent : 400 m

Avertissements :
- Alertes sonores déclenchées dès qu’une zone de contrôle ou présence policière approche selon ces seuils.
- Notifications en arrière-plan : L’application envoie des notifications même lorsque l’utilisateur n’est pas actif dans l’application, à chaque franchissement d’un seuil de distance pour une alerte, ou pour chaque nouvelle alerte détectée.

## Interface utilisateur intuitive :

**Tutoriel initial :** un court guide est présenté au premier lancement pour expliquer rapidement les fonctionnalités et l’objectif de l’application.  
  
**Compteur de vitesse** flottant, affichant la vitesse de l’utilisateur en temps réel, présent dans les deux modes de navigation.
  
Plusieurs boutons :
- Paramètres (burger menu)
- Centre la caméra sur la position utilisateur (caméra qui suit les déplacements)
- Ouvre un panneau bas (bottom sheet) pour signaler une zone de contrôle ou présence policière
- Change de mode de visualisation

## Menu paramètres

- Activation/désactivation des alertes sonores
- Activation/désactivation des notifications push
- Activation/désactivation de l'affichage et alertes spécifiques pour les zones de contrôle ou pour la présence policière
- Accès aux termes et conditions


# 3. Installation

## Prerequis

- Docker
- Flutter

## Run

### 1. API

Dans le dossier de l'API **"spring"**, lancez :
```bash
docker-compose up -d
```
L’API sera accessible sur le port 8080.

### 2. Flutter App

- Modifiez dans *settings.dart* la variable **apiUrl** pour y mettre l’IP de la machine où tourne l’API (ex : http://192.168.x.x:8080).

- Dans le dossier **"flutter"**, récuperez les dépendances :
```bash
flutter pub get
```
- Lancez l'app :
```bash
flutter run
```

# 4. Screenshots

@TODO
- refaire l'image de coquillage
- mettre des images/gif ici