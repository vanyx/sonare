import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../styles/AppColors.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/customMarker.dart';

class SonarePage extends StatefulWidget {
  @override
  SonarePageState createState() => SonarePageState();
}

class SonarePageState extends State<SonarePage> {
  LatLng? _currentPosition;

  MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSubscription;

  double _zoomLevel = 15.7;

  double _sizeScreenCoef = 0.9; //min 0.0 et max 1.0

  double? _heading; // direction de la boussole

  /**
   * _bearing donne l'angle de l'orientation de la carte
   * il est fourni par le calcul du cap si l'user est en mouvement
   * si non, il est donné par la boussole
   */
  double? _bearing;

  double _blueThickness = 0; //epaisseur cercle bleu

  DateTime? _lastUpdateTime;

  bool _isMovingForSure = false;

  int _movingCount = 0;

  int _stoppedCount = 0;

  final int _transitionThreshold =
      3; // nombre de confirmations necessaires pour le cap

  // Size moyenne, pour eviter erreur null
  Size? screenSize = Size(414.0, 896.0);

  double? _blueRadius;

  Offset? _center;

  int _maxRetry = 3;

  LatLng? _lastApiPosition;

  List<Fish> _fishs = [
    Fish(
        position: LatLng(47.68098199871603, -3.0032001740167646),
        type: "shell"),
  ];

  bool _errorWishRequest = false;

  double _fishDistanceThreshold =
      3000; // Distance max à laquelle on garde les fishs en m

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenSize = MediaQuery.of(context).size;

        _blueRadius =
            (screenSize!.width * _sizeScreenCoef) / 2; //rayon du cercle bleu

        _center = Offset(screenSize!.width / 2,
            screenSize!.height / 2); //coord. centre de l'ecran
      });
    });

    _getCurrentLocation();
  }

  void _onMapReady() {
    updateFish();
    _listeningToLocationChanges();
    _listenToCompass();
  }

  @override
  void dispose() {
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
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      updateFishParams();
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

        // fils de pute de fonction
        _animateMarker(_currentPosition!, newPosition);

        updateFish();
      }
    });
  }

  void _listenToCompass() {
    FlutterCompass.events!.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _heading = event.heading;
        });
        if (!_isMovingForSure && _heading != null) {
          setState(() {
            _bearing = _heading;
          });
          updateFishParams();
          _mapController.rotate(-_heading!);
        }
      }
    });
  }

  void updateFish() async {
    if (_currentPosition == null) return;

    // Distance min avant nouvel appel API en m
    double apiCallDistanceThreshold = _fishDistanceThreshold / 10;

    // filtrage
    _fishs.removeWhere((fish) =>
        calculateDistance(_currentPosition!, fish.position) >
        _fishDistanceThreshold);

    if (_lastApiPosition != null) {
      if (calculateDistance(_lastApiPosition!, _currentPosition!) <
              apiCallDistanceThreshold &&
          !_errorWishRequest) {
        return;
      }
    }

    if (mounted) {
      setState(() {
        _lastApiPosition = _currentPosition;
      });
    }

    double latitudeDelta =
        _fishDistanceThreshold / 111000; // Distance en degrés de latitude
    double longitudeDelta = _fishDistanceThreshold /
        (111000 * cos(_currentPosition!.latitude * pi / 180));

    double north = _currentPosition!.latitude + latitudeDelta;
    double south = _currentPosition!.latitude - latitudeDelta;
    double east = _currentPosition!.longitude + longitudeDelta;
    double west = _currentPosition!.longitude - longitudeDelta;
    List<LatLng> newFishPositions =
        await _fetchWish(north, south, west, east, _maxRetry);

    for (var position in newFishPositions) {
      _fishs.add(Fish(
        position: position,
        visible: false,
        angle: 0.0,
        circlePosition: Offset(0, 0),
        type: 'fish',
      ));
    }

    updateFishParams();
  }

  Future<List<LatLng>> _fetchWish(
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
        if (!_errorWishRequest) {
          if (mounted) {
            setState(() {
              _errorWishRequest = false;
            });
          }
        }

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
        return newFish;
      } else {
        if (retries > 0) {
          await Future.delayed(Duration(milliseconds: 200));
          return await _fetchWish(north, south, west, east, retries - 1);
        } else {
          if (mounted) {
            setState(() {
              _errorWishRequest = true;
            });
          }
          return [];
        }
      }
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(Duration(milliseconds: 200));
        return await _fetchWish(north, south, west, east, retries - 1);
      } else {
        if (mounted) {
          setState(() {
            _errorWishRequest = true;
          });
        }
        return [];
      }
    }
  }

  void _animateMarker(LatLng from, LatLng to) {
    DateTime now = DateTime.now();

    if (_lastUpdateTime == null) {
      _lastUpdateTime = now;
      if (mounted) {
        setState(() {
          _currentPosition = to;
        });
      }
      return;
    }

    int timeElapsed = now.difference(_lastUpdateTime!).inMilliseconds;

    double distance = calculateDistance(from, to); // en m

    double speed = distance / (timeElapsed / 1000); // vitesse en m/s
    double speedKmh = speed * 3.6; // en km/h

    // double animationDuration =
    //     (timeElapsed * 0.8).toDouble(); // Animation à 80% du temps écoulé
    // // Limite la durée de l'animation pour éviter des animations trop longues ou trop courtes
    // animationDuration =
    //     animationDuration.clamp(500, 1500);

    if (speedKmh >= 5) {
      _stoppedCount = 0;
      _movingCount++;

      // l'user se deplace
      if (_movingCount >= _transitionThreshold && !_isMovingForSure) {
        if (mounted) {
          setState(() {
            _isMovingForSure = true;
          });
        }
      }

      if (_isMovingForSure) {
        double newBearing = calculateBearing(from, to);
        _animateBearing(_bearing ?? 0, newBearing);
      }
    } else {
      _movingCount = 0;
      _stoppedCount++;

      //l'user est arreté
      if (_stoppedCount >= _transitionThreshold && _isMovingForSure) {
        if (mounted) {
          setState(() {
            _isMovingForSure = false;
          });
        }
      }
    }

    double animationDuration = 1000;

    const int steps = 30;
    double stepDuration = animationDuration / steps;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (stepDuration * i).toInt()), () {
        double t = i / steps;
        LatLng interpolatedPosition = lerp(from, to, t);
        if (mounted) {
          setState(() {
            _currentPosition = interpolatedPosition;
          });
        }

        updateFishParams();

        _mapController.move(interpolatedPosition, _zoomLevel);
      });
    }

    _lastUpdateTime = now;
  }

  Future<void> _animateBearing(double from, double to) async {
    const int steps = 30;
    double stepDuration = 1000 / steps;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (stepDuration * i).toInt()), () {
        if (!mounted) return;

        double t = i / steps;
        double interpolatedBearing = lerpAngle(from, to, t);
        if (mounted) {
          setState(() {
            _bearing = interpolatedBearing;
          });
        }
        updateFishParams();
        _mapController.rotate(-interpolatedBearing);
      });
    }
  }

  bool checkTargetVisibility(LatLng toCheck) {
    final double mapRadiusInPixels =
        (MediaQuery.of(context).size.width * _sizeScreenCoef) / 2;

    // Calcul la distance geographique entre currentPosition et la position cible
    final distanceInMeters = const Distance().as(
      LengthUnit.Meter,
      _currentPosition!,
      toCheck,
    );

    // Conversion de la distance en pixels
    final pixelDistance = distanceInMeters /
        (156543.03392 *
            cos(_currentPosition!.latitude * pi / 180) /
            pow(2, _zoomLevel));

    // Comparer la distance en pixels avec le rayon du cercle
    return pixelDistance <= mapRadiusInPixels;
  }

  void updateFishParams() {
    if (_currentPosition == null ||
        _bearing == null ||
        _center == null ||
        _blueRadius == null) {
      return;
    }
    if (mounted) {
      setState(() {
        for (var fish in _fishs) {
          // Visibilité
          fish.visible = checkTargetVisibility(fish.position);

          // Calcul de l'angle
          fish.angle = azimutBetweenCenterAndPointRadian(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  fish.position.latitude,
                  fish.position.longitude) -
              degreesToRadians(_bearing!);

          // Position sur le cercle
          fish.circlePosition = Offset(
            _center!.dx + _blueRadius! * cos(fish.angle),
            _center!.dy + _blueRadius! * sin(fish.angle),
          );

          // Calcul de la taille en fonction de la distance
          /**
           * _fishDistanceThreshold distance la plus loin
           * .
           * .
           * .
           * Seuil : _fishDistanceThreshold / 5
           * .
           * Moi
           */
          double distance = calculateDistance(_currentPosition!, fish.position);

          if (distance >= _fishDistanceThreshold) {
            fish.size = Fish.minSizeValue;
          } else if (distance <= _fishDistanceThreshold / 5) {
            fish.size = Fish.maxSizeValue;
          } else {
            double normalizedDistance = 1 -
                (distance - (_fishDistanceThreshold / 5)) /
                    (_fishDistanceThreshold - (_fishDistanceThreshold / 5));

            fish.size = Fish.minSizeValue +
                (Fish.maxSizeValue - Fish.minSizeValue) *
                    pow(normalizedDistance, 4);
          }
        }
      });
    }
  }

  /**
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

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  LatLng lerp(LatLng start, LatLng end, double t) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * t,
      start.longitude + (end.longitude - start.longitude) * t,
    );
  }

  double lerpAngle(double start, double end, double t) {
    double difference = end - start;
    if (difference.abs() > 180.0) {
      if (difference > 0) {
        start += 360.0;
      } else {
        end += 360.0;
      }
    }
    double result = start + (end - start) * t;
    return result % 360.0;
  }

  double calculateBearing(LatLng from, LatLng to) {
    double lat1 = from.latitude * (pi / 180.0);
    double lon1 = from.longitude * (pi / 180.0);
    double lat2 = to.latitude * (pi / 180.0);
    double lon2 = to.longitude * (pi / 180.0);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x);

    return (bearing * (180.0 / pi) + 360.0) %
        360.0; // converti en degres et ramene dans la plage [0, 360]
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double R = 6371000; // rayon de la Terre en m
    double lat1 = start.latitude * (3.141592653589793 / 180.0);
    double lat2 = end.latitude * (3.141592653589793 / 180.0);
    double deltaLat =
        (end.latitude - start.latitude) * (3.141592653589793 / 180.0);
    double deltaLon =
        (end.longitude - start.longitude) * (3.141592653589793 / 180.0);

    double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(deltaLon / 2) * sin(deltaLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // distance en m
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _currentPosition == null
            ? Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    // @TODO
                    //ERREUR ICI :
                    width: screenSize!.width * _sizeScreenCoef,
                    height: screenSize!.width * _sizeScreenCoef,
                    decoration: BoxDecoration(
                      color: AppColors.greyButton,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: screenSize!.width * _sizeScreenCoef,
                    height: screenSize!.width * _sizeScreenCoef,
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
                          // TileLayer(
                          //   urlTemplate:
                          //       'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          //   userAgentPackageName: 'com.vanyx.sonare',
                          // ),

                          TileLayer(
                              urlTemplate:
                                  'https://a.tiles.mapbox.com/styles/v1/strava/clvman4pm01ga01qr5te2fpma/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3RyYXZhIiwiYSI6ImNtMWp3M2UyZDAydzIyam9zaTh6OTNiZm0ifQ.AOpRu_eeNKWg6r-4GS52Kw'),

                          MarkerLayer(
                            markers: [
                              // Fishs - MARKERS
                              for (var fish in _fishs)
                                if (fish.visible)
                                  Marker(
                                    width: Fish.maxSizeValue,
                                    height: Fish.maxSizeValue,
                                    point: fish.position,
                                    child: Transform.rotate(
                                      angle: _bearing != null
                                          ? _bearing! * (pi / 180)
                                          : 0.0, // rotation inverse
                                      child: CustomMarker(
                                        size: Fish.maxSizeValue,
                                        type: fish.type == "fish"
                                            ? "fish"
                                            : "shell",
                                      ),
                                    ),
                                  ),

                              // Icon navigation
                              Marker(
                                width: 20.0,
                                height: 20.0,
                                point: _currentPosition!,
                                child: Transform.rotate(
                                  angle: _bearing != null
                                      ? _bearing! * (pi / 180)
                                      : 0.0, // rotation inverse
                                  child: Image.asset(
                                    'assets/navigation.png',
                                    width: 10.0,
                                    height: 10.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // cercle bleu (mdr)
                  CustomPaint(
                    size: Size(screenSize!.width, screenSize!.height),
                    painter:
                        CirclePainter(_center!, _blueRadius!, _blueThickness),
                  ),

                  // Fishs - CIRCLE
                  for (var fish in _fishs)
                    if (!fish.visible)
                      Positioned(
                        left: fish.circlePosition.dx - (fish.size / 2),
                        top: fish.circlePosition.dy - (fish.size / 2),
                        child: Container(
                          width: fish.size,
                          height: fish.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: fish.type == "fish"
                                ? AppColors.iconBackgroundFish
                                : (fish.type == "shell"
                                    ? AppColors.iconBackgroundShell
                                    : Colors
                                        .transparent // Couleur par défaut si aucune condition
                                ),
                            border: Border.all(
                              color: Colors.white,
                              width: fish.size / 9,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2, // taille de l'ombre
                                blurRadius: 8,
                              ),
                            ],
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
  final double thickness;

  CirclePainter(this.center, this.radius, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    // // Peinture pour l'ombre
    // final shadowPaint = Paint()
    //   ..color = Colors.black.withOpacity(0.05) // couleur de l'ombre
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = thickness
    //   ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15); // intensité du flou

    // // Dessine l'ombre
    // canvas.drawCircle(center, radius, shadowPaint);

    // // Peinture pour le cercle
    // final circlePaint = Paint()
    //   ..color = const Color.fromARGB(255, 255, 255, 255)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = thickness;

    // // Dessine le cercle principal par-dessus l'ombre
    // canvas.drawCircle(center, radius, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
