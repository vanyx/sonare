import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/closeButton.dart';
import '../styles/AppColors.dart';
import '../styles/AppFonts.dart';
import './settings/lexique_page.dart';
import './settings/sound_notification_page.dart';
import './settings/terms_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    const double iconWidthPadding = 16.0;
    const double iconHeightPadding = 0.0;
    const double iconWidth = 22.0;

    const double dividerStart = iconWidthPadding * 2 + iconWidth;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 50.0),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CloseButtonWidget(
                  onClose: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          InkWell(
            splashFactory: NoSplash.splashFactory,
            highlightColor: AppColors.longPressed,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SoundNotificationPage(),
                ),
              );
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: iconWidthPadding,
                vertical: iconHeightPadding,
              ),
              horizontalTitleGap: horizontalPadding,
              leading: Icon(
                CupertinoIcons.bell,
                color: AppColors.buttonMain,
                size: iconWidth,
              ),
              title: Text(
                'Son et notifications',
                style: AppFonts.settingsList,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.buttonMain,
                size: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: dividerStart),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.divider,
            ),
          ),
          InkWell(
            splashFactory: NoSplash.splashFactory,
            highlightColor: AppColors.longPressed,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LexiquePage(),
                ),
              );
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: iconWidthPadding,
                vertical: iconHeightPadding,
              ),
              horizontalTitleGap: horizontalPadding,
              leading: Icon(
                CupertinoIcons.lightbulb,
                color: AppColors.buttonMain,
                size: iconWidth,
              ),
              title: Text(
                'Lexique',
                style: AppFonts.settingsList,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.buttonMain,
                size: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: dividerStart),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.divider,
            ),
          ),
          InkWell(
            splashFactory: NoSplash.splashFactory,
            highlightColor: AppColors.longPressed,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TermsPage(),
                ),
              );
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: iconWidthPadding,
                vertical: iconHeightPadding,
              ),
              horizontalTitleGap: horizontalPadding,
              leading: Icon(
                CupertinoIcons.doc,
                color: AppColors.buttonMain,
                size: iconWidth,
              ),
              title: Text(
                'Termes et conditions',
                style: AppFonts.settingsList,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.buttonMain,
                size: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: dividerStart),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.divider,
            ),
          ),
        ],
      ),
    );
  }
}
