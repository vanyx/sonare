# Sonare

## Seuils

- Avertissement **le plus loin** : 3 km
- Avertissement **median** : 800m
- Avertissement **urgent** : 400m

## Avantage PREMIUM

- Carte stylé
- Possibilité de connecter un boitier

# TODO


- mettre en pause l'app (exporer et sonare) si passage en background ?

- modifier son notifications

- ajouter des try catch : api, notif/background, etc ?

- Background service
        - Changer son par defaut notif
        - Tenir compte des params
        - fRREQUETE API: filtrer distance avant de les annoncer dans BCKG
        - Dans bckg re check les distances des fishs juste apres api

- changer icons / images : poisson, coquillage et images de selection

## Quand j'aurais l'api
- activer/desactiver des options à distance
- url wish + desactiver ou non à distance l'utilisation de wish ?
- report fishs
- integration sonare radars, puis regrouper l'appel des 2 api en une seule fonction
- ajouter termes et conditions les memes que dans radar bot (attention dans certains pays c'est interdit dcp c'est votre faute, à la premiere requete de l'api on considere que vous acceptez les conditions, si ous mourrez c'est pas de notre faute, on fait ca seulement à but de securité routiere, etc.)


## A tester sur android :
- textes des autorisations
- notif, sons, boussole, vibrations, webview qui fonctionnement correctement
