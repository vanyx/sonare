import 'package:flutter/material.dart';
import 'explorer_page.dart';
import 'sonare_page.dart';
import 'test_page.dart';
import 'test2.dart';
import './menu_page.dart';

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

  void _changeMode(int mode) {
    setState(() {
      _selectedMode = mode;
    });
    if (mode == 1) {
      setState(() {
        _explorerUserMovedCamera = false;
      });
    }
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qu\'as tu vu ?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        isBottomSheetOpen = false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Poisson',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Corail',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        isBottomSheetOpen = false;
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
      backgroundColor: Color.fromARGB(255, 35, 35, 35),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Choisir un mode',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              isBottomSheetOpen = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(30, 30),
                            elevation: 0,
                            shape: CircleBorder(),
                            backgroundColor: Color.fromARGB(255, 53, 52, 57),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Color.fromARGB(255, 161, 162, 168),
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _changeMode(1);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: _selectedMode == 1
                                    ? Color.fromARGB(255, 0, 221, 255)
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    'assets/explorer.png',
                                    width: 150,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 8.0),
                                      color: Color.fromARGB(255, 53, 52, 57)
                                          .withOpacity(0.97),
                                      child: Text(
                                        'Explorer',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _changeMode(2);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: _selectedMode == 2
                                    ? Color.fromARGB(255, 0, 221, 255)
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    'assets/sonare.jpg',
                                    width: 150,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 8.0),
                                      color:
                                          const Color.fromARGB(255, 53, 52, 57)
                                              .withOpacity(0.97),
                                      child: Text(
                                        'Sonare',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w100,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      // currentPage = Test2Page();
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
                                backgroundColor:
                                    const Color.fromARGB(255, 35, 35, 35),
                              ),
                              child: Icon(
                                Icons.map_outlined,
                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                  backgroundColor:
                                      Color.fromARGB(255, 35, 35, 35),
                                ),
                                child: Transform.rotate(
                                  angle: 45 * 3.14159 / 180,
                                  child: Icon(
                                    _explorerUserMovedCamera
                                        ? Icons.navigation_outlined
                                        : Icons.navigation,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
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
                              backgroundColor: Color.fromARGB(255, 35, 35, 35)),
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
                      backgroundColor: Color.fromARGB(255, 35, 35, 35),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: const Color.fromARGB(255, 255, 255, 255),
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
