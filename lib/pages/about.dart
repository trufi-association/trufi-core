import 'package:flutter/material.dart';

import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';

class AboutPage extends StatelessWidget {
  static const String route = "about";

  @override
  Widget build(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.menuAbout)),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                localizations.title,
                style: TextStyle(fontSize: 28.0),
              ),
            ),
            Container(
              child: Text(
                localizations.tagLine,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                localizations.aboutContent,
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      drawer: TrufiDrawer(AboutPage.route),
    );
  }
}
