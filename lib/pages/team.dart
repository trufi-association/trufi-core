import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trufi_configuration.dart';
import '../trufi_localizations.dart';
import '../widgets/trufi_drawer.dart';

class TeamPage extends StatefulWidget {
  static const String route = "/team";

  @override
  State<StatefulWidget> createState() => new TeamPageState();
}

class TeamPageState extends State<TeamPage> {
  String _representatives;
  String _team;
  String _translations;
  String _routes;
  String _osm;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() async {
    const joinSep = ", ";
    final attribution = TrufiConfiguration().attribution;
    setState(() {
      _representatives = attribution.representatives.join(joinSep);
      _team = attribution.team.join(joinSep);
      _translations = attribution.translations.join(joinSep);
      _routes = attribution.routes.join(joinSep);
      _osm = attribution.osm.join(joinSep);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: TrufiDrawer(TeamPage.route),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final localizations = TrufiLocalizations.of(context);
    return AppBar(title: Text(localizations.menuTeam()));
  }

  Widget _buildBody(BuildContext context) {
    final cfg = TrufiConfiguration();
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: localizations.teamContent() + " ",
                        style: theme.textTheme.body2,
                      ),
                      TextSpan(
                        text: cfg.email.info,
                        style: theme.textTheme.body2.copyWith(
                          color: theme.accentColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch(
                              "mailto:${cfg.email.info}?subject=Contribution",
                            );
                          },
                      ),
                      TextSpan(
                        text: ".",
                        style: theme.textTheme.body2,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localizations.teamSectionRepresentatives(_representatives),
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localizations.teamSectionTeam(_team),
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localizations.teamSectionTranslations(_translations),
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localizations.teamSectionRoutes(_routes, _osm),
                  style: theme.textTheme.body2,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
