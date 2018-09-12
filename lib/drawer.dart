import 'package:flutter/material.dart';

import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/trufi_localizations.dart';

Drawer buildDrawer(BuildContext context, String currentRoute) {
  TrufiLocalizations localizations = TrufiLocalizations.of(context);
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
              ),
              Text(
                localizations.title,
                style: TextStyle(fontSize: 20.0),
              ),
              Text(
                localizations.description,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
        ListTile(
          leading: Icon(Icons.linear_scale),
          title: Text(localizations.menuConnections),
          selected: currentRoute == HomePage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, HomePage.route);
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text(localizations.menuAbout),
          selected: currentRoute == AboutPage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, AboutPage.route);
          },
        ),
        ListTile(
          leading: Icon(Icons.create),
          title: Text(localizations.menuFeedback),
          selected: currentRoute == FeedbackPage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, FeedbackPage.route);
          },
        ),
        ListTile(
          leading: Icon(Icons.people),
          title: Text(localizations.menuTeam),
          selected: currentRoute == FeedbackPage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, FeedbackPage.route);
          },
        ),
      ],
    ),
  );
}
