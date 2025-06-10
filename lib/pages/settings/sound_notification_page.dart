import 'package:Sonare/services/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../styles/AppColors.dart';
import '../../widgets/IosSwitch.dart';
import '../../styles/AppFonts.dart';
import '../../services/common_functions.dart';

class SoundNotificationPage extends StatefulWidget {
  @override
  _SoundNotificationPageState createState() => _SoundNotificationPageState();
}

class _SoundNotificationPageState extends State<SoundNotificationPage> {
  @override
  void initState() {
    super.initState();
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
                      isActive: Settings.soundEnable,
                      onChanged: (v) {
                        Common.setSoundEnabled(v);
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
                "Emettre un signal sonore lorsque vous approchez d'un signalement.",
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
                      isActive: Settings.notificationEnable,
                      onChanged: (v) {
                        Common.setNotificationsEnabled(v);
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
                "Recevez des notifications en arrière-plan lorsque vous approchez d'un signalement.",
                style: AppFonts.settingsNotifSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
