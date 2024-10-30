import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  double _blueThickness = 10; //epaisseur cercle bleu

  double _redThickness = 20; //diametre cercle rouge

  DateTime? _lastUpdateTime;

  bool _isMovingForSure = false;

  int _movingCount = 0;

  int _stoppedCount = 0;

  final int _transitionThreshold =
      3; // nombre de confirmations necessaires pour le cap

  Size? screenSize;

  double? _blueRadius;

  Offset? center;

  int _maxRetry = 3;

  List<Map<String, dynamic>> _fishs = [
    {
      'position': LatLng(48.10688316410168, -1.6744401134774303),
      'visible': false,
      'angle': 0.0,
      'circlePosition': Offset(0, 0),
    },
    {
      'position': LatLng(48.10468320660706, -1.6736865173993232),
      'visible': false,
      'angle': 0.0,
      'circlePosition': Offset(0, 0),
    },
    {
      'position': LatLng(48.10908089627052, -1.6767927553609934),
      'visible': false,
      'angle': 0.0,
      'circlePosition': Offset(0, 0),
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenSize = MediaQuery.of(context).size;

        _blueRadius =
            (screenSize!.width * _sizeScreenCoef) / 2; //rayon du cercle bleu

        center = Offset(screenSize!.width / 2,
            screenSize!.height / 2); //coord. centre de l'ecran
      });
    });

    _getCurrentLocation();
  }

  void _onMapReady() {
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

  void updateFish() {
    if (_currentPosition == null) return;

    const double fishDistanceThreshold =
        5000; // Distance max de garder les fishs dans la zone en m
    const double apiCallDistanceThreshold =
        500; // Distance min à parcourir avant un nouvel appel API en m

    // Filtrer les radars existants pour n'afficher que ceux dans le seuil
    _fishs.removeWhere((fish) =>
        calculateDistance(_currentPosition!, fish['position']) >
        fishDistanceThreshold);

    // @TODO
    /// - Créer un deuxieme seuil de distance, qui correspond à la distance de laquelle il faut suffisament se deplacer
    ///  pour faire un call à Waze.
    /// => l'api de waze prend en param pas une position et un rayon, mais une tuile
    /// Donc il faut calculer selon la distance voulu (à fixer egalement) la tuile
    ///
    /// Quand on recoit une reponse, on ajoute ces positions dans _fishs et on leur ajoute les valeurs par defaut
    /// 'visible': false,
    ///  'angle': 0.0,
    ///'circlePosition': Offset(0, 0),
    ///
    ///
  }

  Future<List<LatLng>> _fetchWaze(
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
        return newFish; // Retourner directement le tableau de positions
      } else {
        if (retries > 0) {
          await Future.delayed(Duration(milliseconds: 200));
          return await _fetchWaze(north, south, west, east, retries - 1);
        } else {
          return []; // Retourne une liste vide si la requête échoue
        }
      }
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(Duration(milliseconds: 200));
        return await _fetchWaze(north, south, west, east, retries - 1);
      } else {
        return []; // Retourne une liste vide en cas d'erreur
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

    //@TODO: à ajuster/ameliorer
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
    bool result = pixelDistance <= mapRadiusInPixels;
    return result;
  }

  void updateFishParams() {
    if (_currentPosition == null ||
        _bearing == null ||
        center == null ||
        _blueRadius == null) {
      return;
    }
    if (mounted) {
      setState(() {
        for (var fish in _fishs) {
          //visibility
          fish['visible'] = checkTargetVisibility(fish['position']);

          // Calcul angle
          fish['angle'] = azimutBetweenCenterAndPointRadian(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  fish['position'].latitude,
                  fish['position'].longitude) -
              degreesToRadians(_bearing!);

          // position sur le cercle
          fish['circlePosition'] = Offset(
            center!.dx + _blueRadius! * cos(fish['angle']),
            center!.dy + _blueRadius! * sin(fish['angle']),
          );
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
      backgroundColor: const Color.fromARGB(255, 242, 242, 246),
      body: Center(
        child: _currentPosition == null
            ? CircularProgressIndicator()
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
                              Marker(
                                width: 25.0,
                                height: 25.0,
                                point: _currentPosition!,
                                child: Transform.rotate(
                                  angle: _bearing != null
                                      ? _bearing! * (pi / 180)
                                      : 0.0, // rotation inverse pour la fleche
                                  child: Icon(
                                    Icons.navigation,
                                    color:
                                        const Color.fromARGB(255, 197, 14, 14),
                                    size: 30.0,
                                  ),
                                ),
                              ),
                              // Marqueurs pour chaque poisson visible
                              for (var fish in _fishs)
                                if (fish['visible'])
                                  Marker(
                                    width: 25.0,
                                    height: 25.0,
                                    point: fish['position'],
                                    child: Transform.rotate(
                                      angle: _bearing != null
                                          ? _bearing! * (pi / 180)
                                          : 0.0, // rotation inverse pour la fleche
                                      child: Icon(
                                        Icons.point_of_sale_outlined,
                                        color: const Color.fromARGB(
                                            255, 232, 23, 23),
                                        size: 25.0,
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
                    size: Size(screenSize!.width, screenSize!.height),
                    painter:
                        CirclePainter(center!, _blueRadius!, _blueThickness),
                  ),

                  // Cercle rouge pour chaque poisson invisible
                  for (var fish in _fishs)
                    if (!fish['visible'])
                      Positioned(
                        left: fish['circlePosition'].dx - (_redThickness / 2),
                        top: fish['circlePosition'].dy - (_redThickness / 2),
                        child: Container(
                          width: _redThickness,
                          height: _redThickness,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 232, 23, 23),
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
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // pas besoin de redessiner constamment
  }
}
