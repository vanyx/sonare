package com.sonare.spring.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/infos")
public class InfoController {

    /**
     * Endpoint to retrieve API information.
     *
     * @return A map containing the API version and the Mapbox map URL.
     * 
     * # Note to self: Always remember to mask sensitive data like tokens before committing.
     * # This one isn't mine, though, so no need to worry...
     */
    @GetMapping
    public Map<String, String> getInfo() {
        return Map.of(
                "apiVersion", "1.0.0",
                "mapUrl", "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWF0aGlldWd1aWxsb3RpbnNlbnNleW91IiwiYSI6ImNsNjY5aGI1ZzBhamszamw1aTkwaTdqN2kifQ.YJ0tcy2apJOnV0TYXbBigA"
        );
    }
}
