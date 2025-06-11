# Spring API


## Description
Cette API permet de gérer des alertes (positions) géographiques : des zones de contrôle (*ControlZone*) et des polices (*Police*).


## Run

Executer :
```bash
docker-compose up -d
```

Cela démarre :
- L'API, disponible sur le port **8080**
- La base de données PostgreSQL/PostGIS


## Dev

1. **Démarrer la base de données** :
```bash
docker-compose up db
```

2. **Lancer l'API** :
```bash
mvn clean install
mvn spring-boot:run
```

=> L'API est accessible sur le port **8080**
