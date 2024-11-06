import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/closeButton.dart';
import '../styles/AppColors.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButtonWidget(
                onClose: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            title: Text(
              'Toto',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.fifteen_mp,
              color: Colors.white,
            ),
            title: Text(
              'Aazeazeazer',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
