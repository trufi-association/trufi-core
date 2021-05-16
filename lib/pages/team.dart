import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

const joinSep = ", ";

class TeamPage extends StatelessWidget {
  static const String route = "/team";

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
    final cfg = context.read<ConfigurationCubit>().state;
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
                      text: cfg.teamInformationEmail,
                      style: theme.textTheme.bodyText1.copyWith(
                        color: theme.accentColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                            "mailto:${cfg.teamInformationEmail}?subject=Contribution",
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
                  localization.teamSectionRepresentatives(
                    cfg.attribution.representatives.join(joinSep),
                  ),
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.teamSectionTeam(
                    cfg.attribution.team.join(joinSep),
                  ),
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.teamSectionTranslations(
                    cfg.attribution.translators.join(joinSep),
                  ),
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.teamSectionRoutes(
                    cfg.attribution.routes.join(joinSep),
                    cfg.attribution.openStreetMap.join(joinSep),
                  ),
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
