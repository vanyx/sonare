import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import '../widgets/customMarker.dart';
import '../styles/AppColors.dart';
import '../services/common_functions.dart';
import '../services/settings.dart';

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
  double _markerSize = 30;

  LatLng? _currentPosition;
  List<LatLng> _shell = [];
  List<LatLng> _fish = [];
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

        _animateMarker(_currentPosition!, newPosition);

        // Check automatiquement les fish si l'user se deplace
        if (_lastPosition == null ||
            calculateDistance(_lastPosition!, _currentPosition!) >
                distanceThreshold) {
          if (mounted) {
            setState(() {
              _lastPosition = _currentPosition;
            });
          }

          _onMapChanged(_mapController.camera, false);
        }
      }
    });
  }

  void _onMapChanged(MapCamera camera, bool? hasGesture) {
    if (mounted) {
      setState(() {
        _currentZoom = camera.zoom;
      });
    }

    if (hasGesture!) {
      if (hasGesture) {
        if (mounted) {
          setState(() {
            widget.userMovedCamera(true);
          });
        }
      }
    }

    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      var bounds = camera.visibleBounds;
      var northEast = bounds.northEast;
      var southWest = bounds.southWest;

      // Call Wish
      Common.fetchWish(northEast.latitude, southWest.latitude,
              southWest.longitude, northEast.longitude, Common.maxRetry)
          .then((newFish) {
        if (mounted) {
          setState(() {
            _fish = newFish;
          });
        }
      });
    });
  }

  void _animateMarker(LatLng from, LatLng to) {
    DateTime now = DateTime.now();

    if (_lastUpdateTime == null) {
      _lastUpdateTime = now;
      if (mounted) {
        setState(() {
          _currentPosition = to;
        });
        return;
      }
    }

    double animationDuration = 1000;

    const int steps = 30;
    double stepDuration = animationDuration / steps; // Duree par étape

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (stepDuration * i).toInt()), () {
        double t = i / steps;
        LatLng interpolatedPosition = lerp(from, to, t);
        if (mounted) {
          setState(() {
            _currentPosition = interpolatedPosition;
          });
        }

        if (!widget.explorerUserMovedCamera) {
          _mapController.move(interpolatedPosition, _currentZoom);
        }
      });
    }

    _lastUpdateTime = now;
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

        // Interpolation pour le centre
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
    double lat1 = start.latitude * (pi / 180.0);
    double lat2 = end.latitude * (pi / 180.0);
    double deltaLat = (end.latitude - start.latitude) * (pi / 180.0);
    double deltaLon = (end.longitude - start.longitude) * (pi / 180.0);

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
                TileLayer(urlTemplate: Settings.mapUrl),
                MarkerLayer(
                  markers: [
                    for (var fishPosition in _fish)
                      Marker(
                        width: _currentZoom > 12.5 ? _markerSize : 10.0,
                        height: _currentZoom > 12.5 ? _markerSize : 10.0,
                        point: fishPosition,
                        child: _currentZoom > 12.5
                            ? Transform.rotate(
                                angle: -_mapController.camera.rotation *
                                    (pi / 180),
                                child: CustomMarker(
                                  size: _markerSize,
                                  type: "fish",
                                ))
                            : Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.iconBackgroundFish,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                      ),
                    for (var fishPosition in _shell)
                      Marker(
                        width: _currentZoom > 12.5 ? _markerSize : 10.0,
                        height: _currentZoom > 12.5 ? _markerSize : 10.0,
                        point: fishPosition,
                        child: _currentZoom > 13
                            ? Transform.rotate(
                                angle: -_mapController.camera.rotation *
                                    (pi / 180),
                                child: CustomMarker(
                                  size: _markerSize,
                                  type: "shell",
                                ))
                            : Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.iconBackgroundFish,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                      ),
                    Marker(
                      width: 25,
                      height: 25,
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              spreadRadius: 2, // taille de l'ombre
                              blurRadius: 8,
                            ),
                          ],
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
