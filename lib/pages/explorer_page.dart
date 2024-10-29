import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'dart:math';

class ExplorerPage extends StatefulWidget {
  final Function(bool) userMovedCamera;
  final bool explorerUserMovedCamera;

  ExplorerPage(
      {Key? key,
      required this.userMovedCamera,
      required this.explorerUserMovedCamera})
      : super(key: key);

  @override
  ExplorerPageState createState() => ExplorerPageState();
}

class ExplorerPageState extends State<ExplorerPage> {
  double _baseZoom = 15.0;
  double _currentZoom = 15.0;

  LatLng? _currentPosition;
  List<LatLng> _sonare = [];
  List<LatLng> _waze = [];
  int _maxRetry = 3;
  double distanceThreshold = 200.0; // Seuil en m

  MapController _mapController = MapController();
  Timer? _debounceTimer;

  LatLng? _lastPosition;
  DateTime? _lastUpdateTime;

  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _startListeningToLocationChanges() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position position) {
      if (mounted) {
        LatLng newPosition = LatLng(position.latitude, position.longitude);

        // fils de pute de fonction
        _animateMarker(_currentPosition!, newPosition);

        // Check automatiquement les fish si l'user se deplace
        if (_lastPosition == null ||
            calculateDistance(_lastPosition!, _currentPosition!) >
                distanceThreshold) {
          setState(() {
            _lastPosition = _currentPosition;
          });

          var camera = _mapController.camera;
          _onMapChanged(camera, false);
        }
      }
    });
  }

  void _animateMarker(LatLng from, LatLng to) {
    DateTime now = DateTime.now();

    if (_lastUpdateTime == null) {
      _lastUpdateTime = now;
      setState(() {
        _currentPosition = to;
      });
      return;
    }

    // double animationDuration =
    //     (timeElapsed * 0.8).toDouble(); // Animation à 80% du temps écoulé
    // // Limite la durée de l'animation pour éviter des animations trop longues ou trop courtes
    // animationDuration =
    //     animationDuration.clamp(500, 1500);

    double animationDuration = 1000;

    const int steps = 30;
    double stepDuration = animationDuration / steps; // Duree par étape

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (stepDuration * i).toInt()), () {
        double t = i / steps;
        LatLng interpolatedPosition = lerp(from, to, t);
        setState(() {
          _currentPosition = interpolatedPosition;
        });

        if (!widget.explorerUserMovedCamera) {
          _mapController.move(interpolatedPosition, _currentZoom);
        }
      });
    }

    _lastUpdateTime = now;
  }

  void _onMapChanged(MapCamera camera, bool? hasGesture) {
    setState(() {
      _currentZoom = camera.zoom;
    });

    if (hasGesture!) {
      if (hasGesture) {
        setState(() {
          widget.userMovedCamera(true);
        });
      }
    }

    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      var bounds = camera.visibleBounds;
      var northEast = bounds.northEast;
      var southWest = bounds.southWest;

      // _fetchSonare(northEast.latitude, southWest.latitude,
      //     southWest.longitude, northEast.longitude, _maxRetry);

      _fetchWaze(northEast.latitude, southWest.latitude, southWest.longitude,
          northEast.longitude, _maxRetry);
    });
  }

  Future<void> _fetchSonare(
      double north, double south, double west, double east, int retries) async {
    String url =
        'http://192.168.1.40:8000/sonare/all/${north}/${south}/${west}/${east}';

    try {
      Uri uri = Uri.parse(url);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        List<LatLng> newFish = [];

        for (var item in data) {
          double latitude = item['latitude'];
          double longitude = item['longitude'];
          LatLng fishPosition = LatLng(latitude, longitude);
          newFish.add(fishPosition);
        }

        if (mounted) {
          setState(() {
            _sonare = newFish;
          });
        }
      } else {
        if (retries > 0) {
          await Future.delayed(Duration(milliseconds: 200));
          _fetchSonare(north, south, west, east, retries - 1);
        }
      }
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(Duration(milliseconds: 200));
        _fetchSonare(north, south, west, east, retries - 1);
      }
    }
  }

  Future<void> _fetchWaze(
      double north, double south, double west, double east, int retries) async {
    String url = 'https://www.waze.com/live-map/api/georss';

    Map<String, String> queryParams = {
      "top": north.toString(),
      "bottom": south.toString(),
      "left": west.toString(),
      "right": east.toString(),
      "env": "row",
      "types": "alerts"
    };

    try {
      Uri uri = Uri.parse(url);
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(finalUri);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<LatLng> newFish = [];

        if (data['alerts'] != null) {
          for (var alert in data['alerts']) {
            var location = alert['location'];
            if (location != null && alert['type'] == 'POLICE') {
              LatLng fishPosition = LatLng(location['y'], location['x']);
              newFish.add(fishPosition);
            }
          }
        }
        if (mounted) {
          setState(() {
            _waze = newFish;
          });
        }
      } else {
        if (retries > 0) {
          await Future.delayed(Duration(milliseconds: 200));
          _fetchWaze(north, south, west, east, retries - 1);
        }
      }
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(Duration(milliseconds: 200));
        _fetchWaze(north, south, west, east, retries - 1);
      }
    }
  }

  Future<void> animateToCurrentPosition() async {
    if (_currentPosition != null) {
      final LatLng targetPosition = _currentPosition!;
      final double targetZoom = _baseZoom;

      const int duration = 500;
      const int steps = 30;
      double stepDuration = duration / steps;

      LatLng currentCenter = _mapController.camera.center;
      double currentZoom = _mapController.camera.zoom;
      double currentRotation = _mapController.camera.rotation;

      double targetRotation = 0.0;

      for (int i = 0; i <= steps; i++) {
        double t = i / steps;

        // Interpolation linéaire pour le centre
        double interpolatedLat = currentCenter.latitude +
            (targetPosition.latitude - currentCenter.latitude) * t;
        double interpolatedLng = currentCenter.longitude +
            (targetPosition.longitude - currentCenter.longitude) * t;

        // Interpolation pour le zoom
        double interpolatedZoom = currentZoom + (targetZoom - currentZoom) * t;

        // Interpolation pour la rotation
        double interpolatedRotation =
            currentRotation + (targetRotation - currentRotation) * t;

        _mapController.move(
            LatLng(interpolatedLat, interpolatedLng), interpolatedZoom);

        _mapController.rotate(interpolatedRotation);

        await Future.delayed(Duration(milliseconds: stepDuration.toInt()));
      }
    }
    widget.userMovedCamera(false);
  }

  LatLng lerp(LatLng start, LatLng end, double t) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * t,
      start.longitude + (end.longitude - start.longitude) * t,
    );
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double R = 6371000; // Rayon de la Terre en m
    double lat1 = start.latitude * (3.141592653589793 / 180.0);
    double lat2 = end.latitude * (3.141592653589793 / 180.0);
    double deltaLat =
        (end.latitude - start.latitude) * (3.141592653589793 / 180.0);
    double deltaLon =
        (end.longitude - start.longitude) * (3.141592653589793 / 180.0);

    double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(deltaLon / 2) * sin(deltaLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance en m
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _currentPosition == null
          ? Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                ),
              ),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 15.0,
                minZoom: 7.0,
                maxZoom: 18.0,
                onPositionChanged: _onMapChanged,
                onMapReady: _startListeningToLocationChanges,
                onTap: (tapPosition, point) {},
                onLongPress: (tapPosition, point) {},
              ),
              children: [
                // TileLayer(
                //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                //   userAgentPackageName: 'com.vanyx.sonare',
                // ),
                TileLayer(
                    urlTemplate:
                        'https://a.tiles.mapbox.com/styles/v1/strava/clvman4pm01ga01qr5te2fpma/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3RyYXZhIiwiYSI6ImNtMWp3M2UyZDAydzIyam9zaTh6OTNiZm0ifQ.AOpRu_eeNKWg6r-4GS52Kw'),
                MarkerLayer(
                  markers: [
                    for (var fishPosition in _waze)
                      Marker(
                        width: _currentZoom > 13 ? 30.0 : 10.0,
                        height: _currentZoom > 13 ? 30.0 : 10.0,
                        point: fishPosition,
                        child: _currentZoom > 13
                            ? Image.asset(
                                'assets/waze_police.png',
                                width: 30.0,
                                height: 30.0,
                              )
                            : Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 98, 190, 239),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                      ),
                    for (var fishPosition in _sonare)
                      Marker(
                        width: _currentZoom > 13 ? 30.0 : 10.0,
                        height: _currentZoom > 13 ? 30.0 : 10.0,
                        point: fishPosition,
                        child: _currentZoom > 13
                            ? Image.asset(
                                'assets/waze_police.png',
                                width: 30.0,
                                height: 30.0,
                              )
                            : Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 214, 44, 25),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                      ),
                    Marker(
                      width: 25.0,
                      height: 25.0,
                      point: _currentPosition!,
                      child: Container(
                        width: 30.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 37, 90, 254),
                          border: Border.all(
                            color: Colors.white,
                            width: 3.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
