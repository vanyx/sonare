import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../styles/AppColors.dart';
import '../../widgets/IosSwitch.dart';
import '../../styles/AppFonts.dart';
import '../../services/common_functions.dart';
import '../../services/settings.dart';

class SignalisationDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String type;

  const SignalisationDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.type,
  })  : assert(type == "police" || type == "controlZone",
            'Type must be "police" or "controlZone"'),
        super(key: key);

  @override
  _SignalisationDetailPageState createState() =>
      _SignalisationDetailPageState();
}

class _SignalisationDetailPageState extends State<SignalisationDetailPage> {
  late bool isToggled;

  @override
  void initState() {
    super.initState();
    isToggled = widget.type == "police"
        ? Settings.policeEnable
        : Settings.controlZoneEnable;
  }

  void _handleToggle(bool value) {
    setState(() {
      isToggled = value;
    });

    if (widget.type == "police") {
      Common.setPoliceEnabled(value);
    } else {
      Common.setControlZoneEnabled(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
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
                    'Afficher et alerter',
                    style: AppFonts.settingsNotif,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IosSwitch(
                      isActive: isToggled,
                      onChanged: _handleToggle,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.description,
                style: AppFonts.settingsNotifSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
