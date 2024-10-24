import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Pour utiliser LatLng
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  LatLng? _currentPosition;

  MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSubscription;

  double _zoomLevel = 15.0;

  double _sizeScreenCoef = 0.9; //min 0.0 et max 1.0

  double _redAngle = 0; // angle du cercle rouge en degre

  double _blueThickness = 10; //epaisseur cercle bleu

  double _redThickness = 20; //diametre cercle rouge

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapReady() {
    _listeningToLocationChanges();
    updateRedCircleAngle();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel(); // Annuler le stream de géolocalisation
    super.dispose();
  }

  /**
   * Trouve depuis le package Flutter 'flutter_map_math'
   * https://github.com/Ujjwalsharma2210/flutter_map_math/blob/main/lib/flutter_geo_math.dart
   */
  double azimutBetweenCenterAndPointRadian(
      double lat1, double lon1, double lat2, double lon2) {
    var dLon = degreesToRadians(lon2 - lon1);
    var y = sin(dLon) * cos(degreesToRadians(lat2));
    var x = cos(degreesToRadians(lat1)) * sin(degreesToRadians(lat2)) -
        sin(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * cos(dLon);
    var angle = atan2(y, x);
    return angle - pi / 2;
  }

  /// Convert degrees to radians
  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
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

  void _listeningToLocationChanges() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position position) {
      if (mounted) {
        LatLng newPosition = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = newPosition;
        });
      }
    });
  }

  void updateRedCircleAngle() {
    LatLng targetPosition = LatLng(47.75884822618481, -3.1212000252345042);

    if (_currentPosition != null) {
      final double newAngle = azimutBetweenCenterAndPointRadian(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          targetPosition.latitude,
          targetPosition.longitude);

      if (mounted) {
        setState(() {
          _redAngle = newAngle;
        });
      }
    }
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
                          minZoom: _zoomLevel, // empeche de zoomer
                          maxZoom: _zoomLevel, // empeche de zoomer
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
                            2), // position du cercle (moins le rayon)
                    top: redCirclePosition.dy -
                        (_redThickness /
                            2), // position du cercle (moins le rayon)
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
