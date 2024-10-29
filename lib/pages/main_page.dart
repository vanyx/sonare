import 'package:flutter/material.dart';
import '../widgets/floating_menu_button.dart';
import 'explorer_page.dart';
import 'sonare_page.dart';
import 'test_page.dart';
import 'test2.dart';

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

  void _showBottomSheet() {
    setState(() {
      isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
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
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                                    ? Color.fromARGB(255, 64, 18, 181)
                                    : Colors.grey,
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
                                      color: Colors.white.withOpacity(0.95),
                                      child: Text(
                                        'Explorer',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
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
                                    ? Color.fromARGB(255, 64, 18, 181)
                                    : Colors.grey,
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
                                      color: Colors.white.withOpacity(0.95),
                                      child: Text(
                                        'Sonare',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
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
  void initState() {
    super.initState();
    // Calcul des marges initiales une seule fois
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        marginTop = screenSize.height * 0.06;
        marginRight = screenSize.width * 0.05;
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
                            ElevatedButton(
                              onPressed: () {
                                _showBottomSheet();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                minimumSize: const Size(40, 40),
                                padding: EdgeInsets.all(0),
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                elevation: 4,
                              ),
                              child: Icon(
                                Icons.map_outlined,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                size: 25.0,
                              ),
                            ),

                            // Dispo uniquement en mode explorer
                            if (_selectedMode == 1) ...[
                              ElevatedButton(
                                onPressed: () {
                                  _explorerKey.currentState
                                      ?.animateToCurrentPosition();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  minimumSize: const Size(40, 40),
                                  padding: EdgeInsets.all(0),
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  elevation: 4,
                                ),
                                child: Transform.rotate(
                                  angle: 45 * 3.14159 / 180,
                                  child: Icon(
                                    _explorerUserMovedCamera
                                        ? Icons.navigation_outlined
                                        : Icons.navigation,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    size: 25.0,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                Positioned(
                  top: marginTop,
                  left: marginRight,
                  child: isBottomSheetOpen
                      ? SizedBox.shrink()
                      : FloatingMenuButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
