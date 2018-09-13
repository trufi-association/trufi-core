import 'package:flutter/material.dart';

import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TeamPage extends StatelessWidget {
  static const String route = "team";

  @override
  Widget build(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.menuTeam)),
      body: Center(
        child: Text('Team!'),
      ),
      drawer: TrufiDrawer(route),
    );
  }
}
