import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class LexiquePage extends StatelessWidget {
  final List<Map<String, String>> lexiqueItems = [
    {
      'title': 'Poisson',
      'description':
          'Créature vive et mobile, le poisson sillonne les eaux en constante évolution. Toujours en mouvement, il peut apparaître là où on l’attend le moins.',
      'image': 'assets/fish.png',
      'backgroundColor': 'iconBackgroundFish'
    },
    {
      'title': 'Coquillage',
      'description':
          'Immobile et ancré, le coquillage veille en silence à son emplacement fixe. Il est une présence constante, marquant des lieux clés que l’on croise toujours au même endroit.',
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
        return AppColors.sonareFlashi;
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
          style: AppFonts.settingsTitle,
        ),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_back,
            color: AppColors.sonareFlashi,
            size: 30,
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
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                color: AppColors.overBackground,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
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
                            style: AppFonts.settingsLexiqueTitle,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        item['description'] ?? '',
                        style: AppFonts.settingsLexiqueText,
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
