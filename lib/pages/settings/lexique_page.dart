import 'package:flutter/material.dart';

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
      backgroundColor: const Color.fromARGB(255, 223, 116, 116),
      appBar: AppBar(
        title: Text('Lexique'),
        backgroundColor: const Color.fromARGB(255, 255, 170, 170),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        item['description'] ?? '',
                        style: TextStyle(fontSize: 16),
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
