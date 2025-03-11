import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../models/models.dart';
import '../styles/AppColors.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/customMarker.dart';
import '../services/common_functions.dart';
import '../services/settings.dart';

class SonarePage extends StatefulWidget {
  final Stream<Position> positionStream;
  final LatLng? initPosition;
  final double speed;

  SonarePage(
      {Key? key,
      required this.positionStream,
      required this.initPosition,
      required this.speed})
      : super(key: key);

  @override
  SonarePageState createState() => SonarePageState();
}

class SonarePageState extends State<SonarePage> {
  bool _mapReady = false;

  LatLng? _currentPosition;

  MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSubscription;

  double _zoomLevel = 17;

  double _sizeScreenCoef = 0.9; //min 0.0 et max 1.0

  double? _heading; // direction de la boussole

  /**
   * _bearing donne l'angle de l'orientation de la carte
   * il est fourni par le calcul du cap si l'user est en mouvement
   * si non, il est donné par la boussole
   */
  double? _bearing;

  DateTime? _lastUpdateTime;

  bool _isMovingForSure = false;

  int _movingCount = 0;

  int _stoppedCount = 0;

  final int _transitionThreshold =
      3; // nombre de confirmations necessaires pour le cap

  // Size moyenne à l'initialisation, pour eviter erreur null
  Size? _screenSize = Size(414.0, 896.0);

  double? _blueRadius = (414.0 * 0.9) / 2;

  Offset? _center = Offset(414.0 / 2, 896.0 / 2);

  LatLng? _lastApiPosition;

  List<FaunaSonare> _faunas = [];

  late VoidCallback _faunaSonareListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _screenSize = MediaQuery.of(context).size;

        _blueRadius =
            (_screenSize!.width * _sizeScreenCoef) / 2; //rayon du cercle bleu

        _center = Offset(_screenSize!.width / 2,
            _screenSize!.height / 2); //coord. centre de l'ecran
      });
    });

    _initializeLocationServices();
  }

  void _onMapReady() {
    setState(() {
      _mapReady = true;
    });
    initFauna();
    _listenToCompass();

    // si les permissions d'affichage des fauna changent, on reload
    _faunaSonareListener = () {
      if (mounted)
        setState(() {
          _faunas = [];
        });
      ();
      fetchFaunaAndIntegrate();
    };
    Common.faunaNotifier.addListener(_faunaSonareListener);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    Common.faunaNotifier.removeListener(_faunaSonareListener);
    super.dispose();
  }

  Future<void> _initializeLocationServices() async {
    await _getCurrentLocation();
    updateFaunaParams();
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
              _animateMarker(_currentPosition!,
                  LatLng(position.latitude, position.longitude));

              updateFauna();
            }
          } else {
            _currentPosition = LatLng(position.latitude, position.longitude);
          }
        }
      });
    } catch (e) {}
  }

  void _listenToCompass() {
    if (!Settings.locationPermission) {
      return;
    }
    try {
      FlutterCompass.events!.listen((CompassEvent event) {
        if (mounted && event.heading != null) {
          setState(() {
            _heading = event.heading;
          });
          if (!_isMovingForSure && _heading != null) {
            setState(() {
              _bearing = _heading;
            });
            updateFaunaParams();
            _mapController.rotate(-_heading!);
          }
        }
      });
    } catch (e) {}
  }

  Future<void> initFauna() async {
    if (_currentPosition == null) return;

    if (mounted) {
      setState(() {
        _lastApiPosition = _currentPosition;
      });
    }

    List<Fauna> faunas = await Common.getFaunaByRadius(_currentPosition!);

    for (var fauna in faunas) {
      if (Common.calculateDistance(_currentPosition!, fauna.position) <=
          Settings.furthestThreshold) {
        _faunas.add(FaunaSonare(
          position: fauna.position,
          visible: false,
          angle: 0.0,
          circlePosition: Offset.zero,
          type: fauna.type,
          level: Common.getFaunaLevel(_currentPosition!, fauna.position),
        ));
      }
    }

    updateFaunaParams();

    // Annonce sonore eventuelle du fauna le plus proche
    int firstMaxLevel =
        Common.getMaxLevel(_faunas.map((fauna) => fauna.level).toList());
    if (firstMaxLevel != -1 && Settings.soundEnable) {
      Common.playWarningByLevel(firstMaxLevel);
    }
  }

  Future<void> updateFauna() async {
    if (_currentPosition == null) return;

    // Distance min avant nouvel appel API en m
    double apiCallDistanceThreshold = Settings.furthestThreshold / 10;

    // filtrage
    _faunas.removeWhere((fauna) =>
        Common.calculateDistance(_currentPosition!, fauna.position) >
        Settings.furthestThreshold);

    if (_lastApiPosition != null) {
      if (Common.calculateDistance(_lastApiPosition!, _currentPosition!) <
          apiCallDistanceThreshold) {
        return;
      }
    }

    if (mounted) {
      setState(() {
        _lastApiPosition = _currentPosition;
      });
    }
    updateFaunaParams();
    fetchFaunaAndIntegrate();
  }

  Future<void> fetchFaunaAndIntegrate() async {
    List<Fauna> faunas = await Common.getFaunaByRadius(_currentPosition!);

    List<int> tmpLevels = [];

    for (var fauna in faunas) {
      if (!existPositionInFauna(fauna.position) &&
          Common.calculateDistance(_currentPosition!, fauna.position) <=
              Settings.furthestThreshold) {
        int level = Common.getFaunaLevel(_currentPosition!, fauna.position);

        _faunas.add(FaunaSonare(
          position: fauna.position,
          visible: false,
          angle: 0.0,
          circlePosition: Offset.zero,
          type: fauna.type,
          level: level,
        ));

        // Util pour les sons
        tmpLevels.add(level);
      }
    }

    // Annonce sonore eventuelle du nouveau fauna le plus proche
    int firstMaxLevel = Common.getMaxLevel(tmpLevels);
    if (firstMaxLevel != -1 && Settings.soundEnable) {
      Common.playWarningByLevel(firstMaxLevel);
    }

    updateFaunaParams();
  }

  bool existPositionInFauna(LatLng position) {
    for (var fauna in _faunas) {
      if (fauna.position.latitude == position.latitude &&
          fauna.position.longitude == position.longitude) {
        return true;
      }
    }
    return false;
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

    if (widget.speed >= 15) {
      setState(() {
        _stoppedCount = 0;
        _movingCount++;
      });

      // l'user se deplace
      if (_movingCount >= _transitionThreshold && !_isMovingForSure) {
        if (mounted) {
          setState(() {
            _isMovingForSure = true;
            _movingCount = 0;
            _stoppedCount = 0;
          });
        }
      }
    } else {
      setState(() {
        _stoppedCount++;
        _movingCount = 0;
      });

      //l'user est arreté
      if (_stoppedCount >= _transitionThreshold && _isMovingForSure) {
        if (mounted) {
          setState(() {
            _isMovingForSure = false;
            _stoppedCount = 0;
            _movingCount = 0;
          });
        }
      }
    }

    if (_isMovingForSure) {
      _animateBearing(_bearing ?? 0, Common.calculateBearing(from, to));
    }

    double animationDuration = 1000;

    const int steps = 30;
    double stepDuration = animationDuration / steps;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (stepDuration * i).toInt()), () {
        double t = i / steps;
        LatLng interpolatedPosition = Common.lerp(from, to, t);
        if (mounted) {
          setState(() {
            _currentPosition = interpolatedPosition;
          });
        }

        updateFaunaParams();

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
        double interpolatedBearing = Common.lerpAngle(from, to, t);
        if (mounted) {
          setState(() {
            _bearing = interpolatedBearing;
          });
        }
        updateFaunaParams();
        _mapController.rotate(-interpolatedBearing);
      });
    }
  }

  void updateFaunaParams() {
    if (_currentPosition == null || _center == null || _blueRadius == null) {
      return;
    }

    List<int> levelsToAnnounce = [];

    if (mounted) {
      setState(() {
        for (var fauna in _faunas) {
          // Visibilite
          fauna.visible = checkTargetVisibility(fauna.position);

          // Calcul de l'angle
          fauna.angle = Common.azimutBetweenCenterAndPointRadian(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  fauna.position.latitude,
                  fauna.position.longitude) -
              Common.degreesToRadians(_bearing != null ? _bearing! : 0);

          double x = ((_screenSize!.width) / 2) +
              _blueRadius! * cos(fauna.angle) -
              fauna.size / 2;
          double y = ((_screenSize!.width) / 2) +
              _blueRadius! * sin(fauna.angle) -
              fauna.size / 2;
          fauna.circlePosition = Offset(x, y);

          // Calcul de la taille en fonction de la distance
          /**
           * Settings.furthestThreshold : distance la plus loin
           * .
           * .
           * .
           * Seuil median : Settings.furthestThreshold / 5
           * .
           * Moi
           */
          double distance =
              Common.calculateDistance(_currentPosition!, fauna.position);

          if (distance >= Settings.furthestThreshold) {
            fauna.size = FaunaSonare.minSizeValue;
          } else if (distance <= Settings.furthestThreshold / 5) {
            fauna.size = FaunaSonare.maxSizeValue;
          } else {
            double normalizedDistance = 1 -
                (distance - (Settings.furthestThreshold / 5)) /
                    (Settings.furthestThreshold -
                        (Settings.furthestThreshold / 5));

            fauna.size = FaunaSonare.minSizeValue +
                (FaunaSonare.maxSizeValue - FaunaSonare.minSizeValue) *
                    pow(normalizedDistance, 4);
          }

          // Calcul level + sons a eventuellement annoncer
          int newLevel =
              Common.getFaunaLevel(_currentPosition!, fauna.position);

          if (newLevel < fauna.level) {
            levelsToAnnounce.add(newLevel);
          }
          if (newLevel != fauna.level) {
            fauna.level = newLevel;
          }
        }

        // Tri les fauna du plus petit au plus grand (utile pour l'affichage des ronds autour de la carte)
        _faunas.sort((a, b) => a.size.compareTo(b.size));
      });
    }

    // Annonce eventuelle d'un level
    if (levelsToAnnounce.isNotEmpty && Settings.soundEnable) {
      Common.playWarningByLevel(
          levelsToAnnounce.reduce((a, b) => a < b ? a : b));
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

    // Converti de la distance en pixels
    final pixelDistance = distanceInMeters /
        (156543.03392 *
            cos(_currentPosition!.latitude * pi / 180) /
            pow(2, _zoomLevel));

    // Compare la distance en pixels avec le rayon du cercle
    return pixelDistance <= mapRadiusInPixels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: !Settings.locationPermission || _currentPosition == null
            ? Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: _screenSize!.width * _sizeScreenCoef,
                    height: _screenSize!.width * _sizeScreenCoef,
                    decoration: BoxDecoration(
                      color: AppColors.sonareFlashi,
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
                    width: _screenSize!.width * _sizeScreenCoef,
                    height: _screenSize!.width * _sizeScreenCoef,
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
                          onMapReady: _onMapReady,
                          interactionOptions: InteractionOptions(
                            flags: 0, // desactive le zoom
                          ),
                        ),
                        children: [
                          TileLayer(urlTemplate: Settings.mapUrl),
                          MarkerLayer(
                            markers: [
                              // FAUNAS - MARKERS
                              for (var fauna in _faunas)
                                if (fauna.visible)
                                  Marker(
                                    width: FaunaSonare.maxSizeValue,
                                    height: FaunaSonare.maxSizeValue,
                                    point: fauna.position,
                                    child: Transform.rotate(
                                      angle: _bearing != null
                                          ? _bearing! * (pi / 180)
                                          : 0.0, // rotation inverse
                                      child: CustomMarker(
                                        size: FaunaSonare.maxSizeValue,
                                        type: fauna.type == "fish"
                                            ? "fish"
                                            : "shell",
                                      ),
                                    ),
                                  ),

                              // Icon navigation
                              Marker(
                                width: 35.0,
                                height: 35.0,
                                point: _currentPosition!,
                                child: Transform.rotate(
                                  angle: _bearing != null
                                      ? _bearing! * (pi / 180)
                                      : 0.0,
                                  child: Container(
                                    width: 35.0,
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color: AppColors.sonareFlashi,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.3),
                                          offset: Offset(0, 2),
                                          blurRadius: 3.0,
                                          spreadRadius: 0.0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.location_north_fill,
                                        color: Colors.white,
                                        size: 22.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // FAUNAS - POINTS
                  Container(
                    /*
                    - Le container joue le role de repere, dans lequel on positionne les points
                      Pour trouver son centre, on utilise sa (taille / 2) en x et y
                      Il est donc necessaire de garder la meme taille utilisee pour la taille du container (repere)
                      que pour le calcul du centre d'ou se baser pour calculer son centre

                    - C'est ensuite le rayon qui defini la distance du centre a laquelle on veut mettre les points
                    */
                    width: (_screenSize!.width),
                    height: (_screenSize!.width),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        for (var fauna in _faunas)
                          if (!fauna.visible)
                            Positioned(
                              left: fauna.circlePosition.dx,
                              top: fauna.circlePosition.dy,
                              child: Container(
                                width: fauna.size,
                                height: fauna.size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: fauna.type == "fish"
                                      ? AppColors.iconBackgroundFish
                                      : (fauna.type == "shell"
                                          ? AppColors.iconBackgroundShell
                                          : Colors
                                              .transparent // Couleur par défaut si aucune condition
                                      ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: fauna.size / 9,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 3.0,
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),

                  // boutons zoom / dezoom
                  Container(
                    width: _screenSize!.width,
                    // Valeurs pour le calcul de la taille du calque a placer par dessus la carte,
                    // qui va contenir les boutons + et -
                    // 10 pour l'espace entre la carte et la row
                    // 30 pour la hauteur de la row
                    height: _screenSize!.width + 10 * 2 + 30 * 2,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(CupertinoIcons.minus,
                                      color: Colors.white),
                                  onPressed: () {
                                    if (_zoomLevel > 13.5) {
                                      setState(() {
                                        _zoomLevel -= 0.5;
                                      });
                                      _mapController.move(
                                          _currentPosition!, _zoomLevel);
                                      updateFaunaParams();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(CupertinoIcons.plus,
                                      color: Colors.white),
                                  onPressed: () {
                                    if (_zoomLevel < 18) {
                                      setState(() {
                                        _zoomLevel += 0.5;
                                      });
                                      _mapController.move(
                                          _currentPosition!, _zoomLevel);
                                      updateFaunaParams();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
