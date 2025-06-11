import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../styles/AppColors.dart';
import '../../styles/AppFonts.dart';
import '../../services/settings.dart';

class TermsPage extends StatefulWidget {
  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Permet le JavaScript
      ..loadRequest(Uri.parse(Settings.termsUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Termes et conditions',
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
      body:
          WebViewWidget(controller: _webViewController), // WebView pleine page
    );
  }
}
