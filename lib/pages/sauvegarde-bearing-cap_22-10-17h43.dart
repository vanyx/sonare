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

class SonarePageState extends State<SonarePage>
    with SingleTickerProviderStateMixin {
  LatLng? _currentPosition;
  LatLng?
      _previousPosition; // Stocke la position précédente pour calculer le cap

  MapController _mapController = MapController();

  double _zoomLevel = 15.0;

  double _sizeScreenCoef = 0.9; //min 0.0 et max 1.0

  double? _heading; // direction de la boussole

  double? _bearing; // direction du déplacement (cap)

  double _redAngle = 0; // angle du cercle rouge

  double _blueThickness = 10; // epaisseur cercle bleu

  double _redThickness = 20; // diametre cercle rouge

  StreamSubscription<Position>? _positionSubscription;

  AnimationController? _animationController;
  Tween<double>?
      _bearingTween; // Interpolation entre l'ancienne et la nouvelle orientation
  Animation<double>? _bearingAnimation;

  double _bearingSmoothingFactor =
      0.85; // Facteur de lissage pour le cap (entre 0 et 1)

  Timer? _updateTimer; // Timer pour mettre à jour la position

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Initialise l'AnimationController pour la rotation fluide
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Durée de l'animation
    );

    _updateTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        print(_currentPosition);
      });
    }
  }

  void _startListeningToLocationChanges() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 1),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _previousPosition = _currentPosition;
          _currentPosition = LatLng(position.latitude, position.longitude);

          if (_previousPosition != null && _currentPosition != null) {
            // Calcul du cap
            double newBearing =
                _calculateBearing(_previousPosition!, _currentPosition!);

            // Appliquer un lissage sur le cap
            _applyBearingSmoothing(newBearing);
          }
        });
        // Bouge la carte avec la nouvelle position
        _mapController.move(_currentPosition!, _zoomLevel);
      }
    });
  }

  // Méthode pour lisser le cap (gestion d'erreur)
  void _applyBearingSmoothing(double newBearing) {
    if (_bearing == null) {
      // Si c'est la première fois qu'on définit le cap
      _bearing = newBearing;
      _animateBearingChange(_bearing!);
    } else {
      // Calcule la différence entre l'ancien cap et le nouveau
      double bearingDifference =
          _calculateBearingDifference(_bearing!, newBearing);

      // Si la différence est trop importante, on applique un lissage
      if (bearingDifference > 20.0) {
        // Appliquer une pondération pour lisser le cap
        _bearing = _bearing! * _bearingSmoothingFactor +
            newBearing * (1 - _bearingSmoothingFactor);
      } else {
        // Si la différence est petite, on change directement le cap
        _bearing = newBearing;
      }

      // Animer la transition fluide entre les caps
      _animateBearingChange(_bearing!);
    }
  }

  // Calcul du cap (bearing) entre deux positions GPS
  double _calculateBearing(LatLng start, LatLng end) {
    double startLat = _degreesToRadians(start.latitude);
    double startLng = _degreesToRadians(start.longitude);
    double endLat = _degreesToRadians(end.latitude);
    double endLng = _degreesToRadians(end.longitude);

    double dLng = endLng - startLng;
    double y = sin(dLng) * cos(endLat);
    double x =
        cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);
    double bearing = atan2(y, x);
    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  // Calcul de la différence de cap entre deux angles
  double _calculateBearingDifference(double oldBearing, double newBearing) {
    double diff = (newBearing - oldBearing + 360) % 360;
    if (diff > 180) {
      diff = 360 - diff;
    }
    return diff;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double _radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }

  // Méthode pour gérer la transition fluide du cap
  void _animateBearingChange(double newBearing) {
    // Interpolation entre l'ancien et le nouveau cap
    _bearingTween = Tween<double>(
      begin: _bearingAnimation?.value ?? _bearing!,
      end: newBearing,
    );

    // Crée une animation entre l'ancien et le nouveau cap
    _bearingAnimation = _bearingTween!.animate(_animationController!)
      ..addListener(() {
        // Met à jour la carte avec la valeur interpolée
        _mapController.rotate(-_bearingAnimation!.value);
      });

    // Démarre l'animation
    _animationController!.forward(from: 0.0);
  }

  // Ecoute les changements de direction de la boussole
  void _listenToCompass() {
    FlutterCompass.events!.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _heading = event.heading;
        });
        if (_bearing == null) {
          // Si le cap n'est pas encore calculé, on utilise la boussole
          _mapController.rotate(-_heading!);
        }
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
    _animationController
        ?.dispose(); // On s'assure de bien libérer l'AnimationController
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
                                  angle: _bearing != null
                                      ? _bearing! * (pi / 180)
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
  final double thickness; // epaisseur bordure

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
