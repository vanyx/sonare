# Sonare

## Seuils

- Avertissement **le plus loin** : 3 km
- Avertissement **median** : 500m
- Avertissement **urgent** : 100m

## Avantage PREMIUM

- Carte stylé
- Possibilité de connecter un boitier

# TODO

- Background service
        - Est ce que les notifis par defaut font un son ? Remplacer par le mien ?
        - Tenir compte des params
        
- Ajout des sons d'avertissement
        - Tenir compte des params
        
```
Zones de Distance : Les radars sont classés en trois zones, en fonction de leur distance par rapport à l'utilisateur :

Urgent (0 à 100m) : Son le plus grave et urgent.
Médian (101 à 500m) : Son d'avertissement modéré.
Lointain (501m à 3000m) : Son plus léger, indiquant une distance lointaine.
Priorité des Sons :

Si plusieurs radars sont détectés à des distances différentes, seul le son correspondant au radar le plus proche (la zone urgente) sera joué. Cela garantit que l'utilisateur est averti rapidement en cas de danger immédiat.
Si un radar change de zone (par exemple, il passe de la zone lointaine à la zone urgente), un nouveau son correspondant à sa nouvelle zone sera joué.
Annonce des Radars :

Lorsqu'un radar est détecté pour la première fois, un son est émis en fonction de sa distance (zone urgente, médiane, ou lointaine).
Un radar ne déclenche qu'un seul son par détection, sauf s'il change de zone.
Fonctionnement de l'Application
Initialisation des Radars : Lors du lancement de l'application, l'application va détecter les radars dans la zone et déterminer pour chaque radar la distance à l'utilisateur. Selon cette distance, le son correspondant sera joué.

Gestion Dynamique des Zones : L'application suit en temps réel les positions des radars. Si un radar se déplace et change de zone (par exemple, d'une zone lointaine à une zone médiane), le son correspondant à la nouvelle zone sera joué. Cela permet d'ajuster l'alerte en fonction des changements de proximité.

Logique de Détection :

Si plusieurs radars sont détectés simultanément dans des zones différentes, c'est toujours le radar le plus proche (urgent) qui déclenchera l'alerte sonore.
Lorsqu'un radar est détecté pour la première fois ou change de zone, le son associé à la zone est joué, et ce radar est suivi dans l'application jusqu'à ce qu'il dépasse un seuil ou quitte la zone.
```


- changer icons / images : poisson, coquillage et images de selection

## Quand j'aurais l'api
- activer/desactiver des options à distance
- url map
- url wish
- report fishs
- integration sonare radars
- ajouter termes et conditions les memes que dans radar bot (attention dans certains pays c'est interdit dcp c'est votre faute, à la premiere requete de l'api on considere que vous acceptez les conditions, si ous mourrez c'est pas de notre faute, on fait ca seulement à but de securité routiere, etc.)


## A tester sur android :
- textes des autorisation
- notif, sons, boussole, vibrations qui fonctionnement correctement
