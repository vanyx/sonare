import 'package:flutter/material.dart';
import '../widgets/closeButton.dart';
import '../styles/AppColors.dart';
import './settings/lexique_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40.0),
          Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CloseButtonWidget(
                  onClose: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: AppColors.white,
            ),
            title: Text(
              'Son et notifications',
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.fifteen_mp,
              color: AppColors.white,
            ),
            title: Text(
              'Lexique',
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LexiquePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.download_done_rounded,
              color: AppColors.white,
            ),
            title: Text(
              'Nous contacter',
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.pending,
              color: AppColors.white,
            ),
            title: Text(
              'Termes et conditions',
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
