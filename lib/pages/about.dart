import 'package:flutter/material.dart';
import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';

class AboutPage extends StatefulWidget {
  static const String route = "about";

  @override
  State<StatefulWidget> createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(title: Text(TrufiLocalizations.of(context).menuAbout));
  }

  Widget _buildBody(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            localizations.title,
            style: theme.textTheme.title,
          ),
          Container(height: 8.0),
          Text(
            localizations.tagLine,
            textAlign: TextAlign.center,
            style: theme.textTheme.subhead,
          ),
          Container(height: 16.0),
          Text(
            localizations.aboutContent,
            style: theme.textTheme.body2,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return TrufiDrawer(
      AboutPage.route,
      onLanguageChangedCallback: () => setState(() {}),
    );
  }
}
