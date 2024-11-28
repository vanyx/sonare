import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../../styles/AppColors.dart';
import '../../widgets/IosSwitch.dart';

class SoundNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Son et notification',
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
        padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
            SizedBox(
                height: horizontalPadding), // Espacement entre les deux lignes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notification',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
          ],
        ),
      ),
    );
  }
}
