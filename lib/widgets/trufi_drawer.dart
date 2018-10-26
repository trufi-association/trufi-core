import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/widgets/alerts.dart';

class TrufiDrawer extends StatefulWidget {
  TrufiDrawer(this.currentRoute);

  final String currentRoute;

  @override
  TrufiDrawerState createState() => TrufiDrawerState();
}

class TrufiDrawerState extends State<TrufiDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
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
          Divider(),
          _buildOfflineModeToggle(context),
          _buildLanguageDropdownButton(context),
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
          Navigator.popUntil(context, ModalRoute.withName(HomePage.route));
          if (route != HomePage.route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildLanguageDropdownButton(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final languageCode = localizations.locale.languageCode;
    final values = <LanguageDropdownValue>[
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

  Widget _buildOfflineModeToggle(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    return StreamBuilder(
      stream: preferencesBloc.outChangeOfflineMode,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool isOfflineModeOn = snapshot.data == true;
        return SwitchListTile(
          title: Text(localizations.menuOffline),
          value: isOfflineModeOn,
          onChanged: (isOfflineOn) => _checkAndroidVersionAndActivateOffline(
                preferencesBloc,
                isOfflineOn,
              ),
          activeColor: theme.primaryColor,
          secondary: Icon(Icons.cloud_off),
        );
      },
    );
  }

  Future<Null> _checkAndroidVersionAndActivateOffline(
      PreferencesBloc preferencesBloc, bool isOfflineOn) async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        await deviceInfoPlugin.androidInfo.then((deviceInfo) {
          if (deviceInfo.version.sdkInt > 25) {
            preferencesBloc.inChangeOfflineMode.add(isOfflineOn);
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return buildOnAndOfflineErrorAlert(
                  context: context,
                  title: TrufiLocalizations.of(context).commonError,
                  content:
                      TrufiLocalizations.of(context).errorDeviceNotSupported,
                );
              },
            );
          }
        });
      } else if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (context) {
            return buildOnAndOfflineErrorAlert(
              context: context,
              title: TrufiLocalizations.of(context).commonError,
              content: TrufiLocalizations.of(context).errorDeviceNotSupported,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return buildOnAndOfflineErrorAlert(
              context: context,
              title: TrufiLocalizations.of(context).commonError,
              content: TrufiLocalizations.of(context).errorDeviceNotSupported,
            );
          },
        );
      }
    } on Exception {
      print("Platform not found");
    }
  }
}

class TrufiDrawerRoute<T> extends MaterialPageRoute<T> {
  TrufiDrawerRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class LanguageDropdownValue {
  LanguageDropdownValue(this.languageCode, this.languageString);

  final String languageCode;
  final String languageString;
}
