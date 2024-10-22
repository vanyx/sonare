import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class SonarePage extends StatefulWidget {
  @override
  SonarePageState createState() => SonarePageState();
}

class SonarePageState extends State<SonarePage> {
  LatLng? _currentPosition;

  MapController _mapController = MapController();

  double _zoomLevel = 15.0;

  double _sizeScreenCoef = 0.9; //min 0.0 et max 1.0

  double? _heading; // direction de la boussole

  double _redAngle = 0; // angle du cercle rouge

  double _blueThickness = 10; //epaisseur cercle bleu

  double _redThickness = 20; //diametre cercle rouge

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  StreamSubscription<Position>? _positionSubscription;

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
      }
    });
  }

  LatLng lerp(LatLng start, LatLng end, double t) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * t,
      start.longitude + (end.longitude - start.longitude) * t,
    );
  }

  DateTime? _lastUpdateTime;

  void _animateMarker(LatLng from, LatLng to) {
    DateTime now = DateTime.now();

    if (_lastUpdateTime == null) {
      _lastUpdateTime = now;
      setState(() {
        _currentPosition = to;
      });
      return;
    }

    int timeElapsed = now.difference(_lastUpdateTime!).inMilliseconds;

    double distance = calculateDistance(from, to); // En m

    double speed = distance / (timeElapsed / 1000); // vitesse en m/s

    print(speed * 3.6);

    // double animationDuration =
    //     (timeElapsed * 0.8).toDouble(); // Animation à 80% du temps écoulé
    // // Limite la durée de l'animation pour éviter des animations trop longues ou trop courtes
    // animationDuration =
    //     animationDuration.clamp(500, 1500);

    double animationDuration = 1000;

    const int steps = 30;
    double stepDuration = animationDuration / steps; // Durée par étape

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (stepDuration * i).toInt()), () {
        double t = i / steps;
        LatLng interpolatedPosition = lerp(from, to, t);
        setState(() {
          _currentPosition = interpolatedPosition;
        });

        _mapController.move(interpolatedPosition, _zoomLevel);
      });
    }

    _lastUpdateTime = now;
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double R = 6371000; // Rayon de la Terre en mètres
    double lat1 = start.latitude * (3.141592653589793 / 180.0);
    double lat2 = end.latitude * (3.141592653589793 / 180.0);
    double deltaLat =
        (end.latitude - start.latitude) * (3.141592653589793 / 180.0);
    double deltaLon =
        (end.longitude - start.longitude) * (3.141592653589793 / 180.0);

    double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(deltaLon / 2) * sin(deltaLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance en mètres
  }

  // Ecoute les changements de direction de la boussole
  void _listenToCompass() {
    FlutterCompass.events!.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _heading = event.heading;
        });
        _mapController.rotate(-_heading!);
      }
    });
  }

  void _onMapReady() {
    _startListeningToLocationChanges();
    _listenToCompass();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final double _blueRadius =
        (screenSize.width * _sizeScreenCoef) / 2; //rayon du cercle bleu

    final Offset center = Offset(
        screenSize.width / 2, screenSize.height / 2); //coord. centre de l'ecran

    // calcul de la position actuelle du cercle rouge
    final Offset redCirclePosition = Offset(
      center.dx + _blueRadius * cos(_redAngle),
      center.dy + _blueRadius * sin(_redAngle),
    );

    return Scaffold(
      body: Center(
        child: _currentPosition == null
            ? CircularProgressIndicator()
            : Stack(
                alignment: Alignment.center,
                children: [
                  // carte
                  Container(
                    width: screenSize.width * _sizeScreenCoef,
                    height: screenSize.width * _sizeScreenCoef,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: ClipOval(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition!,
                          initialZoom: _zoomLevel,
                          minZoom: _zoomLevel, // Empêche de zoomer
                          maxZoom: _zoomLevel, // Empêche de zoomer
                          onMapReady: _onMapReady,
                          interactionOptions: InteractionOptions(
                            flags: 0,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.vanyx.sonare',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 25.0,
                                height: 25.0,
                                point: _currentPosition!,
                                child: Transform.rotate(
                                  angle: _heading != null
                                      ? _heading! * (pi / 180)
                                      : 0.0, // Rotation inverse pour la flèche
                                  child: Icon(
                                    Icons.navigation, // Icône de flèche
                                    color: Colors.blue,
                                    size: 40.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // cercle bleu
                  CustomPaint(
                    size: Size(screenSize.width, screenSize.height),
                    painter: CirclePainter(center, _blueRadius, _blueThickness),
                  ),
                  // cercle rouge
                  Positioned(
                    left: redCirclePosition.dx -
                        (_redThickness /
                            2), // Position du cercle (moins le rayon)
                    top: redCirclePosition.dy -
                        (_redThickness /
                            2), // Position du cercle (moins le rayon)
                    child: Container(
                      width: _redThickness,
                      height: _redThickness,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double thickness; //epaisseur bordure

  CirclePainter(this.center, this.radius, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 21, 66, 180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // pas besoin de redessiner constamment
  }
}
