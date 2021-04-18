import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trufi_configuration.dart';
import '../widgets/trufi_drawer.dart';

class FeedbackPage extends StatefulWidget {
  static const String route = "/feedback";

  const FeedbackPage({Key key}) : super(key: key);

  @override
  FeedBackPageState createState() => FeedBackPageState();
}

class FeedBackPageState extends State<FeedbackPage> {
  Future<void> _launched;

  Future<void> _launch(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("Could not open mail app"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      drawer: const TrufiDrawer(FeedbackPage.route),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return AppBar(title: Text(localization.menuFeedback));
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return ListView(
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
              ),
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: FutureBuilder<void>(
                  future: _launched,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return Text(snapshot.hasError ? "${snapshot.error}" : "");
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final cfg = TrufiConfiguration();
    final theme = Theme.of(context);
    return FloatingActionButton(
      backgroundColor: theme.primaryColor,
      onPressed: () {
        setState(() {
          final String url = "mailto:${cfg.email.feedback}?subject=Feedback";
          _launched = _launch(context, url);
        });
      },
      heroTag: null,
      child: Icon(Icons.email, color: theme.primaryIconTheme.color),
    );
  }
}
