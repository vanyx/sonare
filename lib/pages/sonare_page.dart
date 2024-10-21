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
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, _zoomLevel);
      }
    });
  }

  // Ecoute les changements de direction de la boussole
  void _listenToCompass() {
    FlutterCompass.events!.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _heading = event.heading;
        });
        print(_heading);
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
