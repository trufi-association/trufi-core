import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TrufiDrawer extends StatefulWidget {
  final String currentRoute;
  final Function onLanguageChangedCallback;

  TrufiDrawer(this.currentRoute, {this.onLanguageChangedCallback});

  @override
  State<StatefulWidget> createState() {
    return DrawerState(currentRoute, onLanguageChangedCallback);
  }
}

class DrawerState extends State<TrufiDrawer> {
  String currentRoute;
  Function onLanguageChangedCallback;
  SharedPreferences sharedPreferences;
  TrufiLocalizations localizations;

  DrawerState(this.currentRoute, this.onLanguageChangedCallback);

  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      sharedPreferences = prefs;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    localizations = TrufiLocalizations.of(context);
    return buildDrawer(context, currentRoute, sharedPreferences);
  }

  Drawer buildDrawer(
    BuildContext context,
    String currentRoute,
    SharedPreferences prefs,
  ) {
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
          buildDropdownButton(context, prefs)
        ],
      ),
    );
  }

  Widget buildDropdownButton(BuildContext context, SharedPreferences prefs) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations trufiLocalizations = TrufiLocalizations.of(context);
    return new ListTile(
      leading: Icon(Icons.language),
      title: new DropdownButton<String>(
        style: theme.textTheme.body2,
        value: localizations.getLanguageString(
          localizations.locale.languageCode,
        ),
        onChanged: (String newValue) {
          SharedPreferences.getInstance().then((prefs) {
            String languageCode = trufiLocalizations.getLanguageCode(newValue);
            prefs.setString(
              TrufiLocalizations.SavedLanguageCode,
              languageCode,
            );
            trufiLocalizations.switchToLanguage(languageCode);
            setState(() {
              if (onLanguageChangedCallback != null) {
                onLanguageChangedCallback();
              }
            });
          });
        },
        items: <String>[
          localizations.spanish,
          localizations.quechua,
          localizations.english,
          localizations.german
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
