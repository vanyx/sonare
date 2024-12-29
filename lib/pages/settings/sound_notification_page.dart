import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/AppColors.dart';
import '../../widgets/IosSwitch.dart';
import '../../styles/AppFonts.dart';
import '../../services/settings.dart'; // Importation de Settings

class SoundNotificationPage extends StatefulWidget {
  @override
  _SoundNotificationPageState createState() => _SoundNotificationPageState();
}

class _SoundNotificationPageState extends State<SoundNotificationPage> {
  bool _isSoundEnabled = true;
  bool _isNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    bool sound = await Settings.getSoundEnabled();
    bool notif = await Settings.getNotificationsEnabled();

    setState(() {
      _isSoundEnabled = sound;
      _isNotificationsEnabled = notif;
    });
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Son et notification',
          style: AppFonts.settingsTitle,
        ),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_back,
            color: AppColors.sonareFlashi,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.overBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son',
                    style: AppFonts.settingsNotif,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IosSwitch(
                      isActive: _isSoundEnabled,
                      onChanged: (v) {
                        setState(() {
                          _isSoundEnabled = v;
                        });
                        Settings.setSoundEnabled(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Émettre un son lorsque vous approchez d'une présence.",
                style: AppFonts.settingsNotifSubtitle,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.overBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification',
                    style: AppFonts.settingsNotif,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IosSwitch(
                      isActive: _isNotificationsEnabled,
                      onChanged: (v) {
                        setState(() {
                          _isNotificationsEnabled = v;
                        });
                        Settings.setNotificationsEnabled(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Recevez des notifications en arrière-plan lorsque vous approchez d'une présence.",
                style: AppFonts.settingsNotifSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
