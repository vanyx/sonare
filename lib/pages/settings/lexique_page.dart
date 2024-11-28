import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../../styles/AppColors.dart';

class LexiquePage extends StatelessWidget {
  final List<Map<String, String>> lexiqueItems = [
    {
      'title': 'Poisson',
      'description':
          'azeazeazezaeazeazeaeazeazeazeazeazeaezazeazeazeazeaeazeazeazeazeazeazeazeazezaeae',
      'image': 'assets/fish.png',
      'backgroundColor': 'iconBackgroundFish'
    },
    {
      'title': 'Coquillage',
      'description':
          'azeazeazezaeazeazeaeazeazeazeazeazeaezazeazeazeazeaeazeazeazeazeazeazeazeazezaeae',
      'image': 'assets/shell.png',
      'backgroundColor': 'iconBackgroundShell'
    }
  ];
  Color getColor(String? colorName) {
    switch (colorName) {
      case 'iconBackgroundFish':
        return AppColors.iconBackgroundFish;
      case 'iconBackgroundShell':
        return AppColors.iconBackgroundShell;
      default:
        return AppColors.greyButton;
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Lexique',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_back,
            color: const Color.fromARGB(255, 255, 255, 255),
            size: 25.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          children: lexiqueItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: horizontalPadding),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                color: AppColors.greyButton,
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: getColor(item['backgroundColor']),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 30 * 0.65,
                                height: 30 * 0.65,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Image.asset(item['image'] ?? ''),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            item['title'] ?? '',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        item['description'] ?? '',
                        style: TextStyle(fontSize: 16, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
