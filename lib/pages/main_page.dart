import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'explorer_page.dart';
import 'sonare_page.dart';
import 'settings_page.dart';
import '../widgets/selectModeSheet.dart';
import '../widgets/reportSheet.dart';
import '../styles/AppColors.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedMode = 1; // 1 : Explorer, 2 : Sonare
  bool _explorerUserMovedCamera = false;
  bool isBottomSheetOpen = false;

  double marginTop = 0.0;
  double marginRight = 0.0;

  final GlobalKey<ExplorerPageState> _explorerKey =
      GlobalKey<ExplorerPageState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        marginTop = screenSize.height * 0.06;
        marginRight = screenSize.width * 0.05;
      });
    });
  }

  void _showSelectModeSheet() {
    setState(() {
      isBottomSheetOpen = true;
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
        isBottomSheetOpen = false;
      });
    });
  }

  void _showReportSheet() {
    setState(() {
      isBottomSheetOpen = true;
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
              isBottomSheetOpen = false;
            });
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        isBottomSheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? currentPage;

    if (_selectedMode == 1) {
      currentPage = ExplorerPage(
        key: _explorerKey,
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
                  bottom: marginTop,
                  right: marginRight,
                  child: isBottomSheetOpen
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
                            // FLECHE (Dispo uniquement en mode explorer)
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
                // SETTINGS
                Positioned(
                  top: marginTop,
                  left: marginRight,
                  child: isBottomSheetOpen
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
                              minimumSize: const Size(50, 50),
                              padding: EdgeInsets.all(0),
                              backgroundColor: AppColors.button),
                          child: Image.asset(
                            'assets/menu.png',
                            width: 28,
                            height: 28,
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
