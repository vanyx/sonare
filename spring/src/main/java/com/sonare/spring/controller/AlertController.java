package com.sonare.spring.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.sonare.spring.service.AlertService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

@RestController
public class AlertController {

    @Autowired
    private AlertService alertService;
    
    @GetMapping("/api/alerts/radius")
    public Map<String, List<Map<String, Object>>> getAlertsByRadius(
            @RequestParam double longitude,
            @RequestParam double latitude) {
        return alertService.getAlertsByRadius(longitude, latitude);
    }

    @GetMapping("/api/alerts/window")
    public Map<String, List<Map<String, Object>>> getAlertsByWindow(
            @RequestParam double east,
            @RequestParam double south,
            @RequestParam double west,
            @RequestParam double north) {
        return alertService.getAlertsByWindow(east, south, west, north);
    }

    @PostMapping("/api/alerts/police")
    public ResponseEntity<String> addPolice(@RequestBody JsonNode requestBody) {
        double longitude = requestBody.get("longitude").asDouble();
        double latitude = requestBody.get("latitude").asDouble();

        alertService.addPolice(longitude, latitude);
        return ResponseEntity
                .status(HttpStatus.CREATED)  // 201 Created
                .body("Police added successfully.");
    }

    @PostMapping("/api/alerts/control-zone")
    public ResponseEntity<String> addControlZone(@RequestBody JsonNode requestBody) {

            double longitude = requestBody.get("longitude").asDouble();
            double latitude = requestBody.get("latitude").asDouble();

            alertService.addControlZone(longitude, latitude);
            return ResponseEntity
                    .status(HttpStatus.CREATED)  // 201 Created
                    .body("ControlZone added successfully.");
    }
}
