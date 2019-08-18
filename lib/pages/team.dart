import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/widgets/trufi_drawer.dart';

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
    final attributions = Map<String, List<dynamic>>
      .from(GlobalConfiguration().get("attributions"));
    setState(() {
      _representatives = attributions["representatives"].join(joinSep);
      _team = attributions["team"].join(joinSep);
      _translations = attributions["translations"].join(joinSep);
      _routes = attributions["routes"].join(joinSep);
      _osm = attributions["osm"].join(joinSep);
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
    return AppBar(title: Text(localizations.menuTeam));
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final emailInfo = GlobalConfiguration().getString("emailInfo");
    final launchUrl = "mailto:$emailInfo?subject=Contribution";
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
                        text: localizations.teamContent,
                        style: theme.textTheme.body2,
                      ),
                      TextSpan(
                        text: emailInfo,
                        style: theme.textTheme.body2.copyWith(
                          color: theme.accentColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch(launchUrl);
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
                  "${localizations.teamSectionRepresentativesTitle}: $_representatives",
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  "${localizations.teamSectionTeamTitle}: $_team",
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  "${localizations.teamSectionTranslationsTitle}: $_translations",
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  "${localizations.teamSectionRoutesTitle}: $_routes${localizations.teamSectionRotuesOsmAddition(_osm)}",
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
