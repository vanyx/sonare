import 'package:Sonare/models/faunaExplorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import '../styles/AppColors.dart';
import '../services/common_functions.dart';
import '../services/settings.dart';
import '../widgets/explorerExpandableMarker.dart';
import '../models/models.dart';

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

  /// ----------- Sizes -----------

  double _zoomThreshold = 12.5;
  double _markerSize = 37;
  double _miniMarkerSize = 12;

  /// -----------------------------

  bool _mapReady = false;

  LatLng? _currentPosition;
  List<FaunaExplorer> _faunas = [];

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

  void _onMapReady() {
    _startListeningToLocationChanges();
    setState(() {
      _mapReady = true;
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!Settings.locationPermission) {
      await Geolocator.openLocationSettings();
      // Si permission de position refusee, on ouvre la carte sur Paris
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(48.8566, 2.3522);
        });
      }
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {}
  }

  void _startListeningToLocationChanges() {
    if (!Settings.locationPermission) {
      return;
    }
    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).listen((Position position) {
        // Ne fait rien si l'app est en arriere plan
        if (Settings.appIsActive) {
          if (mounted) {
            animateMarker(_currentPosition!,
                LatLng(position.latitude, position.longitude));

            // Check automatiquement les fauna si l'user se deplace
            if (_lastPosition == null ||
                Common.calculateDistance(_lastPosition!, _currentPosition!) >
                    distanceThreshold) {
              if (mounted) {
                setState(() {
                  _lastPosition = _currentPosition;
                });
              }

              _onMapChanged(_mapController.camera, false);
            }
          }
        }
      });
    } catch (e) {}
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

      Common.getWishByWindows(northEast.latitude, southWest.latitude,
              southWest.longitude, northEast.longitude)
          .then((newFish) {
        if (mounted) {
          setState(() {
            _faunas = newFish
                .map((pos) => FaunaExplorer(position: pos, type: "fish"))
                .toList();
          });
        }
      });
    });
  }

  void animateMarker(LatLng from, LatLng to) {
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
        LatLng interpolatedPosition = Common.lerp(from, to, t);
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
                onMapReady: _onMapReady,
                onTap: (tapPosition, point) {},
                onLongPress: (tapPosition, point) {},
              ),
              children: [
                TileLayer(urlTemplate: Settings.mapUrl),
                MarkerLayer(
                  markers: [
                    if (_mapReady)

                      // MARKERs
                      for (var item in _faunas)
                        Marker(
                          width: _currentZoom > _zoomThreshold
                              ? _markerSize
                              : _miniMarkerSize,
                          height: _currentZoom > _zoomThreshold
                              ? _markerSize
                              : _miniMarkerSize,
                          point: item.position,
                          child: ExplorerExpandableMarker(
                            zoom: _currentZoom,
                            type: item.type,
                            color: item.type == "fish"
                                ? AppColors.iconBackgroundFish
                                : AppColors.iconBackgroundShell,
                            position: item.position,
                            rotationAngle: _mapController.camera.rotation,
                            markerSize: _markerSize,
                            miniMarkerSize: _miniMarkerSize,
                            zoomThreshold: _zoomThreshold,
                          ),
                        ),

                    // ME
                    if (Settings.locationPermission)
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
                                color: Colors.black.withValues(alpha: 0.15),
                                spreadRadius: 2,
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
