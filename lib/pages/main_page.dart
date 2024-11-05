import 'package:flutter/material.dart';
import 'explorer_page.dart';
import 'sonare_page.dart';
import 'test_page.dart';
import 'test2.dart';
import './menu_page.dart';
import '../widgets/selectedBottomSheet.dart';
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
      backgroundColor: AppColors.greyButton,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  top: marginTop,
                  right: marginRight,
                  child: isBottomSheetOpen
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                minimumSize: const Size(40, 40),
                                padding: EdgeInsets.all(0),
                                backgroundColor: AppColors.greyButton,
                              ),
                              child: Icon(
                                Icons.map_outlined,
                                color: AppColors.white,
                                size: 25.0,
                              ),
                            ),

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
                                  minimumSize: const Size(40, 40),
                                  padding: EdgeInsets.all(0),
                                  backgroundColor: AppColors.greyButton,
                                ),
                                child: Transform.rotate(
                                  angle: 45 * 3.14159 / 180,
                                  child: Icon(
                                    _explorerUserMovedCamera
                                        ? Icons.navigation_outlined
                                        : Icons.navigation,
                                    color: AppColors.white,
                                    size: 25.0,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                // MENU
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
                              builder: (BuildContext context) {
                                return DraggableScrollableSheet(
                                  initialChildSize: 1.0,
                                  minChildSize: 1.0,
                                  maxChildSize: 1.0,
                                  builder: (BuildContext context,
                                      ScrollController scrollController) {
                                    return SingleChildScrollView(
                                      controller: scrollController,
                                      child: MenuPage(),
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
                              backgroundColor: AppColors.greyButton),
                          child: Image.asset(
                            'assets/menu.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),

                // REPORT
                Positioned(
                  bottom: marginTop,
                  right: marginRight,
                  child: ElevatedButton(
                    onPressed: _showReportSheet,
                    style: ElevatedButton.styleFrom(
                      elevation: _selectedMode == 2 ? 0 : 2,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                      backgroundColor: AppColors.greyButton,
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.white,
                      size: 32.0,
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
