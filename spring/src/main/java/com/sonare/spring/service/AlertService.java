package com.sonare.spring.service;

import com.sonare.spring.model.Police;
import com.sonare.spring.model.ControlZone;
import com.sonare.spring.repository.PoliceRepository;
import com.sonare.spring.repository.ControlZoneRepository;
import com.sonare.spring.exception.AppExceptions;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class AlertService {

    // valeur par defaut du rayon (en m) pour getAlertsByRadius
    double DEFAULT_RADIUS = 10000;

    @Autowired
    private PoliceRepository policeRepository;

    @Autowired
    private ControlZoneRepository controlZoneRepository;

    private final GeometryFactory geometryFactory = new GeometryFactory();

    private final ObjectMapper objectMapper = new ObjectMapper();


    ////////////////////////////////////////////////////////////////////////////////
    //                                     GET                                    //
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Récupère les polices et ControlZones situés dans un rayon donné autour d'un point.
     *
     * @param longitude Longitude du centre de la zone de recherche.
     * @param latitude  Latitude du centre de la zone de recherche.
     * @return Une carte contenant deux listes : "polices" et "ControlZones", avec leurs positions.
     */
    public Map<String, List<Map<String, Object>>> getAlertsByRadius(double longitude, double latitude) {

        List<Object[]> policeResults = policeRepository.findWithinDistance(longitude, latitude, DEFAULT_RADIUS);
        List<Object[]> ControlZoneResults = controlZoneRepository.findWithinDistance(longitude, latitude, DEFAULT_RADIUS);

        List<Map<String, Object>> polices = parseGeoJsonResults(policeResults);
        List<Map<String, Object>> ControlZones = parseGeoJsonResults(ControlZoneResults);

        Map<String, List<Map<String, Object>>> response = new HashMap<>();
        response.put("polices", polices);
        response.put("control-zones", ControlZones);

        return response;
    }

    /**
     * Récupère les polices et ControlZones situés dans une zone rectangulaire spécifiée.
     * Si la zone est grande, applique un clustering pour réduire le nombre de points renvoyés.
     *
     * @param east  Longitude minimale (bord gauche du rectangle).
     * @param south Latitude minimale (bord inférieur du rectangle).
     * @param west  Longitude maximale (bord droit du rectangle).
     * @param north Latitude maximale (bord supérieur du rectangle).
     * @return Une carte contenant deux listes : "polices" et "ControlZones", avec leurs positions.
     */
    public Map<String, List<Map<String, Object>>> getAlertsByWindow(double east, double south, double west, double north) {

        // epsilon : la distance (en degre) entre les points pour former un cluster
        double epsilon = calculateEpsilonFromBoundingBox(east, south, west, north);

        List<Object[]> policeResults = policeRepository.findWithinWindowClusters(east, south, west, north, epsilon);
        List<Object[]> ControlZoneResults = controlZoneRepository.findWithinWindowClusters(east, south, west, north, epsilon);

        List<Map<String, Object>> polices = parseGeoJsonResults(policeResults);
        List<Map<String, Object>> ControlZones = parseControlZoneWithCentroidResults(ControlZoneResults, epsilon);

        Map<String, List<Map<String, Object>>> response = new HashMap<>();
        response.put("polices", polices);
        response.put("control-zones", ControlZones);

        return response;
    }


    ////////////////////////////////////////////////////////////////////////////////
    //                                   POST                                     //
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Ajoute un nouveau police à la base de données.
     *
     * @param longitude Longitude du police.
     * @param latitude  Latitude du police.
     * @return L'entité Police créée et sauvegardée.
     * @throws AppExceptions.AlertAlreadyExistsException si un police existe déjà à cet emplacement.
     */
    public Police addPolice(double longitude, double latitude) {

        Point point = geometryFactory.createPoint(new Coordinate(longitude, latitude));
        point.setSRID(4326);

        if (policeRepository.existsByLocation(point)) {
            throw new AppExceptions.AlertAlreadyExistsException("A police already exists at this position !");
        }

        Police police = new Police();
        police.setLocation(point);

        return policeRepository.save(police);
    }

    /**
     * Ajoute un nouveau ControlZone à la base de données.
     *
     * @param longitude Longitude du ControlZone.
     * @param latitude  Latitude du ControlZone.
     * @return L'entité ControlZone créée et sauvegardée.
     * @throws AppExceptions.AlertAlreadyExistsException si un ControlZone existe déjà à cet emplacement.
     */
    public ControlZone addControlZone(double longitude, double latitude) {

        Point point = geometryFactory.createPoint(new Coordinate(longitude, latitude));
        point.setSRID(4326);

        if (controlZoneRepository.existsByLocation(point)) {
            throw new AppExceptions.AlertAlreadyExistsException("A ControlZone already exists at this position !");
        }

        ControlZone ControlZone = new ControlZone();
        ControlZone.setLocation(point);

        return controlZoneRepository.save(ControlZone);
    }


    ////////////////////////////////////////////////////////////////////////////////
    //                                   UTILS                                    //
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Calcule la valeur d'epsilon pour le clustering en fonction de la taille de la zone demandée.
     *
     * @param east  Longitude minimale.
     * @param south Latitude minimale.
     * @param west  Longitude maximale.
     * @param north Latitude maximale.
     * @return Une valeur de distance en degrés pour regrouper les points dans des clusters.
     */
    private double calculateEpsilonFromBoundingBox(double east, double south, double west, double north) {
        double width = Math.abs(east - west);
        double height = Math.abs(north - south);

        double zoomLevel = Math.max(width, height);

        if (zoomLevel < 0.2) {
            return 0.0; // pas de clustering
        } else if (zoomLevel < 0.4) {
            return 0.015;
        } else if (zoomLevel < 1.0) {
            return 0.03;
        } else if (zoomLevel < 2.0) {
            return 0.05;
        }
        else if (zoomLevel < 3.0) {
            return 0.1;
        }
        else return 0.2;
    }

    /**
     * Convertit les résultats SQL contenant des coordonnées GeoJSON en une liste exploitable.
     *
     * @param results Liste brute de résultats SQL contenant des objets et des coordonnées GeoJSON.
     * @return Liste des coordonnées sous forme de Map<String, Object> avec latitude et longitude.
     */
    private List<Map<String, Object>> parseGeoJsonResults(List<Object[]> results) {
        List<Map<String, Object>> locations = new ArrayList<>();

        for (Object[] result : results) {
            try {
                String geoJson = (String) result[1]; // GeoJSON en String
                JsonNode node = objectMapper.readTree(geoJson); // Converti en JSON

                double lng = node.get("coordinates").get(0).asDouble();
                double lat = node.get("coordinates").get(1).asDouble();

                Map<String, Object> location = new HashMap<>();
                location.put("latitude", lat);
                location.put("longitude", lng);
                locations.add(location);

            } catch (Exception ignored) {
            }
        }
        return locations;
    }

    //@TODO: javadoc + fonction a check
    private List<Map<String, Object>> parseControlZoneWithCentroidResults(List<Object[]> results, double epsilon) {
        List<Map<String, Object>> ControlZoneList = new ArrayList<>();

        for (Object[] result : results) {
            try {
                // Récupération du GeoJSON pour chaque ControlZone
                String geoJson = (String) result[1];  // GeoJSON en String
                JsonNode node = objectMapper.readTree(geoJson);  // Converti en JSON

                // Extraction des coordonnées latitude et longitude
                double lng = node.get("coordinates").get(0).asDouble();
                double lat = node.get("coordinates").get(1).asDouble();

                // Déterminer si c'est un centroid ou non
                boolean isCentroid = epsilon > 0;  // Si epsilon > 0, alors c'est un centroid, sinon non

                // Création de la map avec les données du ControlZone, et l'attribut "centroid"
                Map<String, Object> ControlZoneData = new HashMap<>();
                ControlZoneData.put("latitude", lat);
                ControlZoneData.put("longitude", lng);
                ControlZoneData.put("centroid", isCentroid);  // Ajouter l'attribut centroid
                ControlZoneList.add(ControlZoneData);

            } catch (Exception ignored) {
            }
        }

        return ControlZoneList;
    }

}
