import 'package:flutter/material.dart';
import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TeamPage extends StatefulWidget {
  static const String route = "team";

  @override
  State<StatefulWidget> createState() => new TeamPageState();
}

class TeamPageState extends State<TeamPage> {
  @override
  Widget build(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.menuTeam)),
      body: Center(
        child: Text('Team!'),
      ),
      drawer:
          TrufiDrawer(TeamPage.route, onLanguageChangedCallback: () => setState(() {})),
    );
  }
}
