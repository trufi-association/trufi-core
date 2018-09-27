import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_material_localizations.dart';

class TrufiDrawer extends StatefulWidget {
  TrufiDrawer(this.currentRoute);

  final String currentRoute;

  @override
  TrufiDrawerState createState() => TrufiDrawerState();
}

class TrufiDrawerState extends State<TrufiDrawer> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  localizations.title,
                  style: theme.textTheme.title,
                ),
                Container(
                  padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    localizations.tagLine,
                    style: theme.textTheme.subhead,
                  ),
                ),
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
    bool isSelected = widget.currentRoute == route;
    return Container(
      color: isSelected ? Colors.grey[300] : null,
      child: ListTile(
        leading: Icon(iconData, color: isSelected ? Colors.black : Colors.grey),
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        selected: isSelected,
        onTap: () {
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }

  Widget _buildDropdownButton(BuildContext context) {
    PreferencesBloc preferencesBloc = BlocProvider.of<PreferencesBloc>(context);
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
          String languageCode = localizations.getLanguageCode(newValue);
          localizations.switchToLanguage(languageCode);
          materialLocalizations.switchToLanguage(languageCode);
          preferencesBloc.inChangeLanguageCode.add(languageCode);
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
