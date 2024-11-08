import 'package:flutter/material.dart';
import '../../styles/AppColors.dart';

class LexiquePage extends StatelessWidget {
  final List<Map<String, String>> lexiqueItems = [
    {
      'title': 'Poisson',
      'description':
          'azeazeazezaeazeazeaeazeazeazeazeazeaezazeazeazeazeaeazeazeazeazeazeazeazeazezaeae',
    },
    {
      'title': 'Coquillage',
      'description':
          'azeazeazezaeazeazeaeazeazeazeazeazeaezazeazeazeazeaeazeazeazeazeazeazeazeazezaeae',
    }
  ];

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
            Icons.chevron_left,
            color: AppColors.white,
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
                              shape: BoxShape.circle,
                              color: Colors.blue,
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
