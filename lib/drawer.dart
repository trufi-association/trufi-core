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
          child: Center(
            child: Text(localizations.title),
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
        ListTile(
          leading: Icon(Icons.linear_scale),
          title: Text(localizations.connections),
          selected: currentRoute == HomePage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, HomePage.route);
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text(localizations.about),
          selected: currentRoute == AboutPage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, AboutPage.route);
          },
        ),
        ListTile(
          leading: Icon(Icons.create),
          title: Text(localizations.feedback),
          selected: currentRoute == FeedbackPage.route,
          onTap: () {
            Navigator.popAndPushNamed(context, FeedbackPage.route);
          },
        ),
      ],
    ),
  );
}
