package com.sonare.spring.repository;

import com.sonare.spring.model.ControlZone;

import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ControlZoneRepository extends JpaRepository<ControlZone, Long> {

    /**
     * Recherche tous les ControlZones situés dans un rayon donné autour d'un point central.
     *
     * @param longitude        Longitude du point central.
     * @param latitude         Latitude du point central.
     * @param distanceInMeters Rayon en mètres autour du point central pour la recherche.
     * @return Liste des ControlZones sous forme d'objets contenant l'id et la position en GeoJSON.
     */
    @Query(value = """

            SELECT id, ST_AsGeoJSON(location)
        FROM control_zone 
        WHERE ST_DWithin(
            location::geography, 
            ST_SetSRID(ST_MakePoint(?1, ?2), 4326)::geography, 
            ?3
        )
        """, nativeQuery = true)
    List<Object[]> findWithinDistance(double longitude, double latitude, double distanceInMeters);

    /**
     * Recherche tous les ControlZones situés à l'intérieur d'un rectangle géographique défini par deux points opposés.
     *
     * @param east  Longitude minimale (bord gauche du rectangle).
     * @param south Latitude minimale (bord inférieur du rectangle).
     * @param west  Longitude maximale (bord droit du rectangle).
     * @param north Latitude maximale (bord supérieur du rectangle).
     * @return Liste des ControlZones sous forme d'objets contenant l'id et la position en GeoJSON.
     */
    @Query(value = """
    SELECT id, ST_AsGeoJSON(location)
    FROM control_zone 
    WHERE location && ST_MakeEnvelope(?1, ?2, ?3, ?4, 4326)
    """, nativeQuery = true)
    List<Object[]> findWithinWindow(double east, double south, double west, double north);

    /**
     * Regroupe les ControlZones dans une zone donnée en clusters selon l'algorithme DBSCAN et retourne leur centroïde.
     *
     * @param east    Longitude minimale (bord gauche du rectangle).
     * @param south   Latitude minimale (bord inférieur du rectangle).
     * @param west    Longitude maximale (bord droit du rectangle).
     * @param north   Latitude maximale (bord supérieur du rectangle).
     * @param epsilon Distance maximale (en degrés) entre deux points pour qu'ils soient dans le même cluster.
     * @return Liste des centroïdes des clusters sous forme d'objets contenant l'id du cluster et la position en GeoJSON.
     */
    @Query(value = """
    WITH clustered AS (
        SELECT id, 
               location, 
               ST_ClusterDBSCAN(location, ?5, 1) OVER () AS cluster_id
        FROM control_zone
        WHERE location && ST_MakeEnvelope(?1, ?2, ?3, ?4, 4326)
    )
    SELECT cluster_id, ST_AsGeoJSON(ST_Centroid(ST_Collect(location))) AS centroid
    FROM clustered
    WHERE cluster_id IS NOT NULL
    GROUP BY cluster_id
    """, nativeQuery = true)
    List<Object[]> findWithinWindowClusters(double east, double south, double west, double north, double epsilon);

    /**
     * Vérifie si un ControlZone existe déjà à une position donnée.
     *
     * @param location Objet Point représentant la position géographique à vérifier.
     * @return True si un ControlZone existe à cette position, sinon False.
     */
    @Query(value = "SELECT EXISTS (SELECT 1 FROM control_zone WHERE ST_Equals(location, ?1))", nativeQuery = true)
    boolean existsByLocation(Point location);
  }
