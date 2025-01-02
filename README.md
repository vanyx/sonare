# Sonare

## Seuils

- Avertissement **le plus loin** : 3 km
- Avertissement **median** : 500m
- Avertissement **urgent** : 100m

## Avantage PREMIUM

- Carte stylé
- Possibilité de connecter un boitier

# TODO


////////// BUGGGGGG ////////////

- quand je roule pas de radars, et quand il y en a un qui spawn il n'y a pas d'annonce pour le 3km
- => Attentition, ne pas annoncer chaque radar car si il y en a 4 cote à cote ça va tous les annoncer, faire comme un peu à l'init

- le son du 500m est pas bon

- seuil nuls : essayer 3km/1km/400m ?

- Modifier les voix, et anoncer plus tôt les distances dedans

///////////////////////////////

- Background service
        - Est ce que les notifis par defaut font un son ? Remplacer par le mien ?
        - Tenir compte des params

- changer icons / images : poisson, coquillage et images de selection

## Quand j'aurais l'api
- activer/desactiver des options à distance
- url map ?
- url wish + desactiver ou non à distance l'utilisation de wish ?
- report fishs
- integration sonare radars, puis regrouper l'appel des 2 api en une seule fonction
- ajouter termes et conditions les memes que dans radar bot (attention dans certains pays c'est interdit dcp c'est votre faute, à la premiere requete de l'api on considere que vous acceptez les conditions, si ous mourrez c'est pas de notre faute, on fait ca seulement à but de securité routiere, etc.)


## A tester sur android :
- textes des autorisations
- notif, sons, boussole, vibrations, webview qui fonctionnement correctement
