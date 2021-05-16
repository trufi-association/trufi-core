import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/definition_feedback.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/trufi_drawer.dart';

class FeedbackPage extends StatelessWidget {
  static const String route = "/feedback";

  const FeedbackPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final feedBack =
        context.read<ConfigurationCubit>().state.feedbackDefinition;
    return Scaffold(
      appBar: AppBar(title: Text(localization.menuFeedback)),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  localization.feedbackTitle,
                  style: theme.textTheme.headline6.copyWith(
                    color: theme.textTheme.bodyText1.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    localization.feedbackContent,
                    style: theme.textTheme.bodyText1,
                  ),
                )
              ],
            ),
          )
        ],
      ),
      drawer: const TrufiDrawer(FeedbackPage.route),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () async {
          String url = '';
          if (feedBack.type == FeedBackType.email) {
            url = "mailto:${feedBack.body}?subject=Feedback";
          } else {
            url = feedBack.body;
          }
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(
                    localization.errorEmailFeedback,
                    style: theme.textTheme.bodyText1,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(localization.commonOK),
                    )
                  ],
                );
              },
            );
          }
        },
        heroTag: null,
        child: Icon(
          feedBack.type == FeedBackType.email ? Icons.email : Icons.feedback,
          color: theme.primaryIconTheme.color,
        ),
      ),
    );
  }
}
