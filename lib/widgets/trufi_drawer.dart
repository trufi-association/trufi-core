import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_material_localizations.dart';

class TrufiDrawer extends StatefulWidget {
  TrufiDrawer(this.currentRoute, {this.onLanguageChangedCallback});

  final String currentRoute;
  final Function onLanguageChangedCallback;

  @override
  TrufiDrawerState createState() => TrufiDrawerState();
}

class TrufiDrawerState extends State<TrufiDrawer> {
  SharedPreferences _sharedPreferences;

  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      _sharedPreferences = prefs;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
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
                  style: theme.textTheme.title,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    localizations.description,
                    style: theme.textTheme.subhead,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          _buildListItem(
            Icons.linear_scale,
            localizations.menuConnections,
            HomePage.route,
          ),
          _buildListItem(
            Icons.info,
            localizations.menuAbout,
            AboutPage.route,
          ),
          _buildListItem(
            Icons.create,
            localizations.menuFeedback,
            FeedbackPage.route,
          ),
          _buildListItem(
            Icons.people,
            localizations.menuTeam,
            TeamPage.route,
          ),
          _buildDropdownButton(context),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData iconData, String title, String route) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      selected: widget.currentRoute == route,
      onTap: () {
        Navigator.popAndPushNamed(context, route);
      },
    );
  }

  Widget _buildDropdownButton(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    TrufiMaterialLocalizations materialLocalizations =
        TrufiMaterialLocalizations.of(context);
    return ListTile(
      leading: Icon(Icons.language),
      title: DropdownButton<String>(
        style: theme.textTheme.body2,
        value: localizations.getLanguageString(
          localizations.locale.languageCode,
        ),
        onChanged: (String newValue) {
          SharedPreferences.getInstance().then((prefs) {
            String languageCode = localizations.getLanguageCode(newValue);
            _sharedPreferences.setString(
              TrufiLocalizations.savedLanguageCode,
              languageCode,
            );
            localizations.switchToLanguage(languageCode);
            materialLocalizations.switchToLanguage(languageCode);
            setState(() {
              if (widget.onLanguageChangedCallback != null) {
                widget.onLanguageChangedCallback();
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
            child: Text(
              value,
              style: theme.textTheme.body2,
            ),
          );
        }).toList(),
      ),
    );
  }
}