import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import '../models/models.dart';
import '../styles/AppColors.dart';
import '../services/common_functions.dart';
import '../services/settings.dart';
import '../widgets/customMarker.dart';

class ExplorerPage extends StatefulWidget {
  final Function(bool) userMovedCamera;
  final bool explorerUserMovedCamera;
  final Stream<Position> positionStream;
  final LatLng? initPosition;

  ExplorerPage(
      {Key? key,
      required this.userMovedCamera,
      required this.explorerUserMovedCamera,
      required this.positionStream,
      required this.initPosition})
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

  List<Alert> _alerts = [];

  double distanceThreshold = 200.0; // Seuil en m

  MapController _mapController = MapController();
  Timer? _debounceTimer;

  LatLng? _lastPosition;
  DateTime? _lastUpdateTime;

  late VoidCallback _alertExplorerListener;

  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocationServices();
    ();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _positionSubscription?.cancel();
    Common.alertNotifier.removeListener(_alertExplorerListener);
    super.dispose();
  }

  void _onMapReady() {
    setState(() {
      _mapReady = true;
    });
    initAlerts();

    // si les permissions d'affichage des alerts changent, on reload
    _alertExplorerListener = () {
      if (mounted)
        setState(() {
          _alerts = [];
        });
      refreshAlerts();
    };

    Common.alertNotifier.addListener(_alertExplorerListener);
  }

  Future<void> _initializeLocationServices() async {
    await _getCurrentLocation();
    _listeningToLocationChanges();
  }

  Future<void> _getCurrentLocation() async {
    if (!Settings.locationPermission) {
      await Geolocator.openLocationSettings();
      return;
    }

    if (mounted && widget.initPosition != null) {
      setState(() {
        _currentPosition = widget.initPosition;
      });
    }
  }

  void _listeningToLocationChanges() {
    if (!Settings.locationPermission) {
      return;
    }
    try {
      _positionSubscription = widget.positionStream.listen((Position position) {
        // Ne fait rien si l'app est en arriere plan
        if (Settings.appIsActive) {
          if (_mapReady) {
            if (mounted) {
              animateMarker(_currentPosition!,
                  LatLng(position.latitude, position.longitude));

              // Check automatiquement les alerts si l'user se deplace
              if (_lastPosition == null ||
                  Common.calculateDistance(_lastPosition!, _currentPosition!) >
                      distanceThreshold) {
                if (!widget.explorerUserMovedCamera) {
                  if (mounted) {
                    setState(() {
                      _lastPosition = _currentPosition;
                    });
                  }
                  refreshAlerts();
                }
              }
            }
          } else {
            setState(() {
              _currentPosition = LatLng(position.latitude, position.longitude);
            });
          }
        }
      });
    } catch (e) {}
  }

  Future<void> initAlerts() async {
    if (_currentPosition == null) return;
    refreshAlerts();
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
      refreshAlerts();
    });
  }

  void refreshAlerts() async {
    List<Alert> newAlerts = await Common.getAlertByWindow(
        _mapController.camera.visibleBounds.east,
        _mapController.camera.visibleBounds.south,
        _mapController.camera.visibleBounds.west,
        _mapController.camera.visibleBounds.north);

    if (mounted) {
      setState(() {
        _alerts = newAlerts;
      });
    }
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
                CircleLayer(
                  circles: [
                    for (var item in _alerts)
                      if (item is ControlZone)
                        if (!item.centroid)
                          CircleMarker(
                            point: item.position,
                            color: AppColors.iconBackgroundControlZone
                                .withValues(alpha: 0.5),
                            borderColor: AppColors.iconBackgroundControlZone,
                            borderStrokeWidth: 2,
                            radius: item.radius,
                            useRadiusInMeter: true,
                          ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (_mapReady)
                      for (var item in _alerts)
                        if (item is Police)
                          Marker(
                              width: _currentZoom > _zoomThreshold
                                  ? _markerSize
                                  : _miniMarkerSize,
                              height: _currentZoom > _zoomThreshold
                                  ? _markerSize
                                  : _miniMarkerSize,
                              point: item.position,
                              child: _currentZoom > _zoomThreshold
                                  ? Transform.rotate(
                                      angle: -_mapController.camera.rotation *
                                          (pi / 180),
                                      child: CustomMarker(
                                        size: _markerSize,
                                        type: 'police',
                                      ),
                                    )
                                  : Container(
                                      width: _miniMarkerSize,
                                      height: _miniMarkerSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.iconBackgroundPolice,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.3),
                                            blurRadius: 3.0,
                                            spreadRadius: 0.0,
                                          ),
                                        ],
                                      ),
                                    ))
                        else if (item is ControlZone)
                          if (item.centroid)
                            Marker(
                              width: _miniMarkerSize,
                              height: _miniMarkerSize,
                              point: item.position,
                              child: Container(
                                width: _miniMarkerSize,
                                height: _miniMarkerSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.iconBackgroundControlZone,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.15),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
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
