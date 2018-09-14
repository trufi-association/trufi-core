import 'package:flutter/material.dart';
import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/utils/file_utils.dart';

class TeamPage extends StatefulWidget {
  static const String route = "team";
  final FileUtils fileUtils = FileUtils();

  @override
  State<StatefulWidget> createState() => new TeamPageState();
}

class TeamPageState extends State<TeamPage> {
  static const String PATH_TEAM_FILE = 'assets/data/team.txt';
  String _teamString = '';
  TrufiLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    localizations = TrufiLocalizations.of(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(title: Text(localizations.menuTeam));
  }

  Widget _buildBody(BuildContext context) {
    ThemeData theme = Theme.of(context);

    widget.fileUtils.readFile(PATH_TEAM_FILE).then((String value) {
      setState(() {
        _teamString = value;
      });
    });

    return Container(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              localizations.teamContent,
              style: theme.textTheme.title,
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                _teamString,
                style: theme.textTheme.subhead,
                textAlign: TextAlign.center,
              ),
            )

          ],
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
