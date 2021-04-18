import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trufi_configuration.dart';
import '../widgets/trufi_drawer.dart';

class TeamPage extends StatefulWidget {
  static const String route = "/team";

  const TeamPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TeamPageState();
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

  void _loadState() {
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
      drawer: const TrufiDrawer(TeamPage.route),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return AppBar(title: Text(localization.menuTeam));
  }

  Widget _buildBody(BuildContext context) {
    final cfg = TrufiConfiguration();
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${localization.teamContent} ",
                      style: theme.textTheme.bodyText1,
                    ),
                    TextSpan(
                      text: cfg.email.info,
                      style: theme.textTheme.bodyText1.copyWith(
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
                      style: theme.textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.teamSectionRepresentatives(_representatives),
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.teamSectionTeam(_team),
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.teamSectionTranslations(_translations),
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.teamSectionRoutes(_routes, _osm),
                  style: theme.textTheme.bodyText1,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
