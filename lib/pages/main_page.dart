import 'package:Sonare/services/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'explorer_page.dart';
import 'sonare_page.dart';
import 'settings_page.dart';
import '../widgets/selectModeSheet.dart';
import '../widgets/reportSheet.dart';
import '../widgets/updateDialog.dart';
import '../styles/AppColors.dart';
import '../widgets/speedometer.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedMode = 1; // 1 : Explorer, 2 : Sonare
  bool _explorerUserMovedCamera = false;
  bool _isBottomSheetOpen = false;
  double _marginTop = 40;
  double _marginRight = 20;

  double _speed = 0;
  static const double _minSpeedometerLimit = 0;

  LatLng? _currentPosition;

  final GlobalKey<ExplorerPageState> _explorerKey =
      GlobalKey<ExplorerPageState>();

  final StreamController<Position> _positionStreamController =
      StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startListeningPosition();
    _checkAppVersion();
  }

  @override
  void dispose() {
    _positionStreamController.close();
    super.dispose();
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

  void _startListeningPosition() {
    if (!Settings.locationPermission) {
      return;
    }
    try {
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 1),
      ).listen((Position position) {
        // Stream de position
        _positionStreamController.add(position);

        setState(() {
          _speed = position.speed;
        });
      });
    } catch (e) {}
  }

  Future<void> _checkAppVersion() async {
    if (Settings.version != Settings.apiVersion) {
      // Differer l'execution de l'affichage du dialogue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog();
      });
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // empêche la fermeture en cliquant en dehors du dialog
      builder: (BuildContext context) {
        return UpdateDialog();
      },
    );
  }

  void _showSelectModeSheet() {
    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SelectModeSheet(
              selectedMode: _selectedMode,
              onModeSelected: (int mode) {
                setState(() {
                  _selectedMode = mode;
                });
                setModalState(() {}); // refresh la bottom sheet
                if (mode == 1) {
                  setState(() {
                    _explorerUserMovedCamera = false;
                  });
                }
              },
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

  void _showReportSheet() {
    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return ReportSheet(
          onClose: () {
            Navigator.of(context).pop();
            setState(() {
              _isBottomSheetOpen = false;
            });
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? currentPage;

    if (_selectedMode == 1) {
      currentPage = ExplorerPage(
        key: _explorerKey,
        positionStream: _positionStreamController.stream,
        explorerUserMovedCamera: _explorerUserMovedCamera,
        userMovedCamera: (hasMoved) {
          setState(() {
            _explorerUserMovedCamera = hasMoved;
          });
        },
      );
    } else {
      currentPage = SonarePage();
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                currentPage,
                Positioned(
                  bottom: _marginTop,
                  right: _marginRight,
                  child: _isBottomSheetOpen
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //REPORT
                            ElevatedButton(
                              onPressed: () {
                                _showReportSheet();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: _selectedMode == 2 ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                minimumSize: const Size(45, 45),
                                padding: EdgeInsets.all(0),
                                backgroundColor: AppColors.button,
                              ),
                              child: Icon(
                                CupertinoIcons.plus,
                                color: AppColors.white,
                                size: 25.0,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // CHOIX MODE
                            ElevatedButton(
                              onPressed: () {
                                _showSelectModeSheet();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: _selectedMode == 2 ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                minimumSize: const Size(45, 45),
                                padding: EdgeInsets.all(0),
                                backgroundColor: AppColors.button,
                              ),
                              child: Icon(
                                CupertinoIcons.map,
                                color: AppColors.white,
                                size: 25.0,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // FLECHE (dispo uniquement en mode explorer)
                            if (_selectedMode == 1) ...[
                              ElevatedButton(
                                onPressed: () {
                                  _explorerKey.currentState
                                      ?.animateToCurrentPosition();
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: _selectedMode == 2 ? 0 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  minimumSize: const Size(45, 45),
                                  padding: EdgeInsets.all(0),
                                  backgroundColor: AppColors.button,
                                ),
                                child: Icon(
                                  _explorerUserMovedCamera
                                      ? CupertinoIcons.location
                                      : CupertinoIcons.location_fill,
                                  color: AppColors.white,
                                  size: 25.0,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                // SPEED
                if (_speed >= _minSpeedometerLimit)
                  Positioned(
                      bottom: _marginTop,
                      left: _marginRight,
                      child: _isBottomSheetOpen
                          ? Container()
                          : Speedometer(
                              speed: _speed * 3.6,
                              mode: _selectedMode,
                            )),
                // SETTINGS
                Positioned(
                  top: _marginTop * 1.3,
                  left: _marginRight,
                  child: _isBottomSheetOpen
                      ? SizedBox.shrink()
                      : ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.background,
                              builder: (BuildContext context) {
                                return DraggableScrollableSheet(
                                  initialChildSize: 1.0,
                                  minChildSize: 1.0,
                                  maxChildSize: 1.0,
                                  builder: (BuildContext context,
                                      ScrollController scrollController) {
                                    return SingleChildScrollView(
                                      controller: scrollController,
                                      child: SettingsPage(),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: _selectedMode == 2 ? 0 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              minimumSize: const Size(45, 45),
                              padding: EdgeInsets.all(0),
                              backgroundColor: AppColors.button),
                          child: Image.asset(
                            'assets/images/icons/burgermenu.png',
                            color: const Color.fromARGB(255, 255, 255, 255),
                            width: 25,
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
