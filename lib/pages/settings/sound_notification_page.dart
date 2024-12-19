import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../../styles/AppColors.dart';
import '../../widgets/IosSwitch.dart';
import '../../styles/AppFonts.dart';

class SoundNotificationPage extends StatelessWidget {
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
                borderRadius: BorderRadius.circular(13),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding * 0.8,
                vertical: horizontalPadding * 0.5,
              ),
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
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: horizontalPadding * 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                "Emettre une alerte lorsque vous approchez d'un danger et que l'application est active.",
                style: AppFonts.settingsNotifSubtitle,
              ),
            ),
            SizedBox(height: horizontalPadding * 1.2),
            Container(
              decoration: BoxDecoration(
                color: AppColors.overBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding * 0.8,
                  vertical: horizontalPadding * 0.5),
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
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: horizontalPadding * 0.5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                "Recevez des notifications en arrière-plan lorsque vous approchez d'un danger.",
                style: AppFonts.settingsNotifSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
