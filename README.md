# Sonare

## Seuils

- Avertissement **le plus loin** : 3 km
- Avertissement **median** : 800m
- Avertissement **urgent** : 400m

## Avantage PREMIUM

- Carte stylé
- Possibilité de connecter un boitier

# TODO

// Check dans sonare page et bckgservice si le param son change
// en mode sonare on recupere qu'au debut la valeur du param son donc si on joue avec l'option son ça suivra pas
=> Mettre en place un stream sur ca
=> Modifier et creer un param static pour la valeur des param, et en meme temps on modifie en dur dans la memoire ?

- modifier son notifications

ajouter des try catch : api, notif/background, etc ?

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
