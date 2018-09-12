import 'package:flutter/material.dart';

import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';

Drawer buildDrawer(BuildContext context, String currentRoute) {
  TrufiLocalizations localizations = TrufiLocalizations.of(context);
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          padding: EdgeInsets.only(top: 35.0),
          child: Column(
            children: <Widget>[
              Text(
                localizations.title,
                style: TextStyle(fontSize: 20.0),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  localizations.description,
                  textAlign: TextAlign.center,
                ),
              )
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
          selected: currentRoute == TeamPage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, TeamPage.route);
          },
        ),
      ],
    ),
  );
}
