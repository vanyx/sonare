import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';
import './signalisation_detail.dart';

class SignalisationPage extends StatefulWidget {
  @override
  _SignalisationPageState createState() => _SignalisationPageState();
}

class _SignalisationPageState extends State<SignalisationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    const double iconWidthPadding = 16.0;
    const double iconHeightPadding = 0.0;
    const double iconWidth = 30.0;

    const double dividerStart = iconWidthPadding * 2 + iconWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Signalisation',
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
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashFactory: NoSplash.splashFactory,
              highlightColor: AppColors.longPressed,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignalisationDetailPage(
                      type: 'police',
                      title: 'Police',
                      description:
                          "@TODO a refaire Mobile, le poisson sillonne les eaux en constante évolution. Toujours en mouvement, il peut apparaître là où on l’attend le moins.",
                    ),
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
                leading: Container(
                  width: iconWidth,
                  height: iconWidth,
                  decoration: BoxDecoration(
                    color: AppColors.iconBackgroundPolice,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.all(3.0), // taille de l'image a l'interieur
                    child: Image.asset(
                      'assets/images/police.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                title: Text(
                  'Police',
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
                    builder: (context) => SignalisationDetailPage(
                      type: 'controlZone',
                      title: 'Zone de contrôle',
                      description:
                          "@TODO a refaire Immobile, le coquillage veille en silence à son emplacement fixe. Il est une présence constante, marquant des lieux clés que l’on croise toujours au même endroit.",
                    ),
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
                leading: Container(
                  width: iconWidth,
                  height: iconWidth,
                  decoration: BoxDecoration(
                    color: AppColors.iconBackgroundControlZone,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.all(3.0), // taille de l'image a l'interieur
                    child: Image.asset(
                      'assets/images/radar.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                title: Text(
                  'Zone de contrôle',
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
      ),
    );
  }
}
