import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Test2Page extends StatefulWidget {
  @override
  _Test2PageState createState() => _Test2PageState();
}

class _Test2PageState extends State<Test2Page> {
  // Position initiale et état de chargement
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Récupérer la position actuelle
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si la localisation est activée
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Localisation désactivée
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Demander les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions refusées
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte avec ma position'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? Center(child: Text("Impossible d'obtenir la position"))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 15,
                    interactionOptions: InteractionOptions(
                      flags: 0,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://a.tiles.mapbox.com/styles/v1/strava/clvman4pm01ga01qr5te2fpma/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3RyYXZhIiwiYSI6ImNtMWp3M2UyZDAydzIyam9zaTh6OTNiZm0ifQ.AOpRu_eeNKWg6r-4GS52Kw',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 25.0,
                          height: 25.0,
                          point: _currentPosition!,
                          child: Icon(
                            Icons.navigation,
                            color: const Color.fromARGB(255, 197, 14, 14),
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
