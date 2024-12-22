# TODO

- adapter le cacul de la taille des fishs avec la nouvelle logique de zoom/dezoom en mode sonare

SON :
- reperé à + de _fishDistanceThreshold
- quand ça passe sous le seuil
- definir clairement les seuils => 3km et 500m ?

- bug : des fois à l'arret la boussole ne marche pas car sonare a l'impression d'etre en mouvement (mais à l'arret) (car le calcul de l'arret se fait au bout de 3 positions, qui elles arrivent quand on se deplace)

Est ce que les notifis par defaut font un son ?
=> Si oui changer par le mien ?

- faire background service
- son/notif
- voix IA pour signaler un danger à X km
- changer icons / images (poisson, shell, icon de navigation, et images de select mode)

- ajouter termes et conditions les memes que dans radar bot (attention dans certains pays c'est interdit dcp c'est votre faute, à la premiere requete de l'api on considere que vous acceptez les conditions, si ous mourrez c'est pas de notre faute, on fait ca seulement à but de securité routiere, etc.)


## A tester sur android :
- textes des autorisation
- notif, sons, vibrations qui fonctionnement correctement

## Que j'arrive pas sur flutter :
- supprimer le cercle painter