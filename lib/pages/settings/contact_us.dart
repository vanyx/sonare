import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  void sendReport() {
    String message = _controller.text.trim();

    if (message.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    /**
     * @TODO : Call api pour envoyer le message
     */

    _controller.clear();

    setState(() {
      _isFocused = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            'Message envoyé !',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Nous contacter',
          style: AppFonts.settingsTitle,
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
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Un bug à signaler ? Une amélioration ? Contactez-nous !',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 20.0),
            Focus(
              // Detection du focus
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                });
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre message ici...',
                  hintStyle: TextStyle(color: AppColors.sonareFlashi),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: AppColors.sonareFlashi,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: AppColors.sonareFlashi,
                      width: 2.0,
                    ),
                  ),
                ),
                style: TextStyle(color: AppColors.white),
              ),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  sendReport();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sonareFlashi,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'Envoyer',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
