import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../models/models.dart';
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

  List<AlertSonareWrapper> _alerts = [];

  late VoidCallback _alertSonareListener;

  static const double alertCircleMinSize = 10.0;
  static const double alertCircleMaxSize = 30.0;
  static const double alertCircleDefaultSize = 15.0;

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
    initAlerts();
    _listenToCompass();

    // si les permissions d'affichage des alertes changent, on reload
    _alertSonareListener = () {
      if (mounted)
        setState(() {
          _alerts = [];
        });
      ();
      fetchAlertsAndIntegrate();
      updateAlertsParams();
    };
    Common.alertNotifier.addListener(_alertSonareListener);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    Common.alertNotifier.removeListener(_alertSonareListener);
    super.dispose();
  }

  Future<void> _initializeLocationServices() async {
    await _getCurrentLocation();
    updateAlertsParams();
    _listeningToLocationChanges();
  }

  Future<void> _getCurrentLocation() async {
    if (!Settings.locationPermission) {
      await Geolocator.openLocationSettings();
      return;
    }

    if (mounted && widget.initPosition != null) {
      setState(() {
        // @TODO _currentPosition = widget.initPosition;
        _currentPosition = LatLng(48.09821300824947, -1.6753622078601924);
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
              // @TODO
              // _animateMarker(_currentPosition!,
              //     LatLng(position.latitude, position.longitude));

              updateAlerts();
            }
          } else {
            // @TODO _currentPosition = LatLng(position.latitude, position.longitude);
            _currentPosition = LatLng(48.09821300824947, -1.6753622078601924);
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
            updateAlertsParams();
            _mapController.rotate(-_heading!);
          }
        }
      });
    } catch (e) {}
  }

  Future<void> initAlerts() async {
    if (_currentPosition == null) return;

    if (mounted) {
      setState(() {
        _lastApiPosition = _currentPosition;
      });
    }

    List<Alert> alerts = await Common.getAlertByRadius(_currentPosition!);

    for (var item in alerts) {
      if (Common.calculateDistance(_currentPosition!, item.position) <=
          Settings.policeThreshold3) {
        int level;
        if (item is ControlZone) {
          level = Common.getControlZoneLevel(
              _currentPosition!, item.position, item.radius);
        } else if (item is Police) {
          level = Common.getPoliceLevel(_currentPosition!, item.position);
        } else {
          continue; // Ignore les types inconnus
        }

        _alerts.add(AlertSonareWrapper(
            alert: item, level: level, size: alertCircleDefaultSize));
      }
    }

    updateAlertsParams();

    /********* Avertissement sonore - POLICE *********/
    var policeAlerts = _alerts.where((item) => item.alert is Police).toList();

    int policesMinLevel =
        Common.getMinLevel(policeAlerts.map((item) => item.level).toList());
    if (policesMinLevel != -1 && Settings.soundEnable) {
      Common.playPoliceByLevel(policesMinLevel);
    }

    /********* Avertissement sonore - CONTROL ZONE *********/

    var controlZoneAlerts =
        _alerts.where((item) => item.alert is ControlZone).toList();

    int controlZonesMinLevel = Common.getMinLevel(
        controlZoneAlerts.map((item) => item.level).toList());

    if (controlZonesMinLevel != -1 &&
        Settings.soundEnable &&
        // check que le son de police n'a pas deja ete joué
        policesMinLevel == -1) {
      Common.PlayControlZoneByLevel(controlZonesMinLevel);
    }
  }

  Future<void> updateAlerts() async {
    if (_currentPosition == null) return;

    // Distance min avant nouvel appel API en m
    double apiCallDistanceThreshold = Settings.policeThreshold3 / 10;

    // filtrage
    _alerts.removeWhere((item) =>
        Common.calculateDistance(_currentPosition!, item.alert.position) >
        Settings.policeThreshold3);

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
    fetchAlertsAndIntegrate();
    updateAlertsParams();
  }

  Future<void> fetchAlertsAndIntegrate() async {
    List<Alert> alerts = await Common.getAlertByRadius(_currentPosition!);

    List<Map<String, dynamic>> levelsToAnnounce = [];

    for (var item in alerts) {
      if (!existPositionInAlerts(item.position) &&
          Common.calculateDistance(_currentPosition!, item.position) <=
              Settings.policeThreshold3) {
        _alerts.add(AlertSonareWrapper(
            alert: item,
            level: item is ControlZone
                ? Common.getControlZoneLevel(
                    _currentPosition!, item.position, item.radius)
                : Common.getPoliceLevel(_currentPosition!, item.position),
            size: alertCircleDefaultSize));

        // Ajoute le niveau et le type à la liste des niveaux à annoncer
        levelsToAnnounce.add({
          "level": item is ControlZone
              ? Common.getControlZoneLevel(
                  _currentPosition!, item.position, item.radius)
              : Common.getPoliceLevel(_currentPosition!, item.position),
          "type": item is ControlZone ? "ControlZone" : "Police"
        });
      }
    }

    // anonce sonore des nouvelles alertes
    if (levelsToAnnounce.isNotEmpty) {
      var minAlert =
          levelsToAnnounce.reduce((a, b) => a["level"] < b["level"] ? a : b);

      if (Settings.soundEnable) {
        if (minAlert["type"] == "Police") {
          Common.playPoliceByLevel(minAlert["level"]);
        } else if (minAlert["type"] == "ControlZone") {
          Common.PlayControlZoneByLevel(minAlert["level"]);
        }
      }
    }

    updateAlertsParams();
  }

  bool existPositionInAlerts(LatLng position) {
    for (var item in _alerts) {
      if (item.alert.position.latitude == position.latitude &&
          item.alert.position.longitude == position.longitude) {
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

        updateAlertsParams();

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
        updateAlertsParams();
        _mapController.rotate(-interpolatedBearing);
      });
    }
  }

  void updateAlertsParams() {
    if (_currentPosition == null || _center == null || _blueRadius == null) {
      return;
    }

    List<Map<String, dynamic>> levelsToAnnounce = [];

    if (mounted) {
      setState(() {
        for (var item in _alerts) {
          /********* VISIBILITE *********/
          if (item.alert is ControlZone) {
            item.visible = checkControlZoneVisibility(
                item.alert.position, (item.alert as ControlZone).radius);
          } else {
            item.visible = checkPoliceVisibility(item.alert.position);
          }

          /********* ANGLE *********/
          item.angle = Common.azimutBetweenCenterAndPointRadian(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  item.alert.position.latitude,
                  item.alert.position.longitude) -
              Common.degreesToRadians(_bearing != null ? _bearing! : 0);

          double x = ((_screenSize!.width) / 2) +
              _blueRadius! * cos(item.angle) -
              item.size / 2;
          double y = ((_screenSize!.width) / 2) +
              _blueRadius! * sin(item.angle) -
              item.size / 2;
          item.circlePosition = Offset(x, y);

          /********* DISTANCE *********/
          double distance = 0;
          if (item.alert is ControlZone) {
            distance = Common.calculateDistance(
                    _currentPosition!, item.alert.position) -
                (item.alert as ControlZone).radius;
          } else {
            distance = Common.calculateDistance(
                _currentPosition!, item.alert.position);
          }

          if (distance >= Settings.policeThreshold3) {
            item.size = alertCircleMinSize;
          } else if (distance <= Settings.policeThreshold3 / 5) {
            item.size = alertCircleMaxSize;
          } else {
            double normalizedDistance = 1 -
                (distance - (Settings.policeThreshold3 / 5)) /
                    (Settings.policeThreshold3 -
                        (Settings.policeThreshold3 / 5));

            item.size = alertCircleMinSize +
                (alertCircleMaxSize - alertCircleMinSize) *
                    pow(normalizedDistance, 4);
          }

          /********* LEVEL + ANNONCE SONORE *********/

          int newLevel;
          String alertType;

          if (item.alert is ControlZone) {
            newLevel = Common.getControlZoneLevel(_currentPosition!,
                item.alert.position, (item.alert as ControlZone).radius);
            alertType = "ControlZone";
          } else {
            newLevel =
                Common.getPoliceLevel(_currentPosition!, item.alert.position);
            alertType = "Police";
          }

          // Si le niveau a changé, on le maj + ajoute à la liste des niveaux à annoncer
          if (newLevel != item.level) {
            levelsToAnnounce.add({"level": newLevel, "type": alertType});
            item.level = newLevel;
          }
        }

        /********* TRI (utile pour l'affichage des cercles) *********/
        _alerts.sort((a, b) => a.size.compareTo(b.size));
      });
    }
    /********* ANNONCE SONORE *********/

    if (levelsToAnnounce.isNotEmpty) {
      // Trouve l'alerte avec le niveau le plus bas
      var minAlert =
          levelsToAnnounce.reduce((a, b) => a["level"] < b["level"] ? a : b);

      // Joue le son selon le type de l'alerte
      if (Settings.soundEnable) {
        if (minAlert["type"] == "Police") {
          Common.playPoliceByLevel(minAlert["level"]);
        } else if (minAlert["type"] == "ControlZone") {
          Common.PlayControlZoneByLevel(minAlert["level"]);
        }
      }
    }
  }

  bool checkPoliceVisibility(LatLng toCheck) {
    // rayon de la carte affichee en pixel
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

  bool checkControlZoneVisibility(LatLng zoneCenter, double radiusInMeter) {
    // rayon de la carte affichee en pixel
    final double mapRadiusInPixels =
        (MediaQuery.of(context).size.width * _sizeScreenCoef) / 2;

    // distance geographique entre currentPosition et le centre de la zone de controle
    final distanceCenterToZoneMeters = const Distance().as(
      LengthUnit.Meter,
      _currentPosition!,
      zoneCenter,
    );

    // converti de la distance en pixel
    final distanceCenterToZonePixel = distanceCenterToZoneMeters /
        (156543.03392 *
            cos(_currentPosition!.latitude * pi / 180) /
            pow(2, _zoomLevel));

    // rayon de la zone de controle en pixel
    final radiusZonePixel = radiusInMeter /
        (156543.03392 *
            cos(_currentPosition!.latitude * pi / 180) /
            pow(2, _zoomLevel));

    return distanceCenterToZonePixel - radiusZonePixel <= mapRadiusInPixels;
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

                          // CONTROL ZONE - CIRCLELAYERS
                          CircleLayer(
                            circles: [
                              for (var item in _alerts)
                                if (item.alert is ControlZone)
                                  if (item.visible)
                                    CircleMarker(
                                      point: item.alert.position,
                                      color: AppColors.iconBackgroundControlZone
                                          .withValues(alpha: 0.5),
                                      borderColor:
                                          AppColors.iconBackgroundControlZone,
                                      borderStrokeWidth: 2,
                                      radius:
                                          (item.alert as ControlZone).radius,
                                      useRadiusInMeter: true,
                                    ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              // POLICE - MARKERS
                              for (var item in _alerts)
                                if (item.alert is Police)
                                  if (item.visible)
                                    Marker(
                                      width: alertCircleMaxSize,
                                      height: alertCircleMaxSize,
                                      point: item.alert.position,
                                      child: Transform.rotate(
                                        angle: _bearing != null
                                            ? _bearing! * (pi / 180)
                                            : 0.0, // rotation inverse
                                        child: CustomMarker(
                                          size: alertCircleMaxSize,
                                          type: "police",
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

                  // ALERTS - POINTS
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
                        for (var item in _alerts)
                          if (!item.visible)
                            Positioned(
                              left: item.circlePosition.dx,
                              top: item.circlePosition.dy,
                              child: Container(
                                width: item.size,
                                height: item.size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  // Choix couleur
                                  color: item.alert is Police
                                      ? AppColors.iconBackgroundPolice
                                      : AppColors.iconBackgroundControlZone,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: item.size / 9,
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
                                      updateAlertsParams();
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
                                      updateAlertsParams();
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
