import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';

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
          _buildLanguageDropdownButton(context),
          _buildOfflineToggle(context),
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

  Widget _buildLanguageDropdownButton(BuildContext context) {
    PreferencesBloc preferencesBloc = BlocProvider.of<PreferencesBloc>(context);
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    String languageCode = localizations.locale.languageCode;
    List<LanguageDropdownValue> values = <LanguageDropdownValue>[
      LanguageDropdownValue(languageCodeSpanish, localizations.spanish),
      LanguageDropdownValue(languageCodeQuechua, localizations.quechua),
      LanguageDropdownValue(languageCodeEnglish, localizations.english),
      LanguageDropdownValue(languageCodeGerman, localizations.german),
    ];
    return ListTile(
      leading: Icon(Icons.language),
      title: DropdownButton<LanguageDropdownValue>(
        style: theme.textTheme.body2,
        value: values.firstWhere((value) => value.languageCode == languageCode),
        onChanged: (LanguageDropdownValue value) {
          preferencesBloc.inChangeLanguageCode.add(value.languageCode);
        },
        items: values.map((LanguageDropdownValue value) {
          return DropdownMenuItem<LanguageDropdownValue>(
            value: value,
            child: Text(
              value.languageString,
              style: theme.textTheme.body2,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfflineToggle(BuildContext context) {
    PreferencesBloc preferencesBloc = BlocProvider.of<PreferencesBloc>(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return StreamBuilder(
      stream: preferencesBloc.outChangeOffline,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool isOffline = snapshot.data == true;
        return ListTile(
          leading: Icon(
            isOffline ? Icons.cloud_off : Icons.cloud,
          ),
          title: Text(
            isOffline ? localizations.menuOffline : localizations.menuOnline,
          ),
          onTap: () => preferencesBloc.inChangeOffline.add(!isOffline),
        );
      },
    );
  }
}

class LanguageDropdownValue {
  LanguageDropdownValue(this.languageCode, this.languageString);

  final String languageCode;
  final String languageString;
}
