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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(title: Text(TrufiLocalizations.of(context).menuTeam));
  }

  Widget _buildBody(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Text(
          "People and companies involved: Andreas Helms, Annika Bock, Christian Brückner, Christoph Hanser, Javier Rocha, Luz Choque, Malte Dölker, Marcel Köhler, Martin Kleppe, Michael Brückner, Natalya Blanco, Neyda Mili, Patrick Cuellar, QUIBIQ, Raimund Wege, Samuel Riotz, SIRcode.io, Ubilabs",
          style: theme.textTheme.title,
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return TrufiDrawer(
      TeamPage.route,
      onLanguageChangedCallback: () => setState(() {}),
    );
  }
}
