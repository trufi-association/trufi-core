import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/widgets/trufi_drawer.dart';

class TeamPage extends StatefulWidget {
  static const String route = "team";

  @override
  State<StatefulWidget> createState() => new TeamPageState();
}

class TeamPageState extends State<TeamPage> {
  String _teamString = '';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() async {
    rootBundle.loadString('assets/data/team.txt').then((value) {
      setState(() {
        _teamString = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return AppBar(title: Text(localizations.menuTeam));
  }

  Widget _buildBody(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                localizations.teamContent,
                style: theme.textTheme.title,
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  _teamString,
                  style: theme.textTheme.body1,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return TrufiDrawer(
      TeamPage.route,
      onLanguageChangedCallback: () => setState(() {}),
    );
  }
}
