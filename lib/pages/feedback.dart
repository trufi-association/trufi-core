import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trufi_configuration.dart';
import '../widgets/trufi_drawer.dart';

class FeedbackPage extends StatefulWidget {
  static const String route = "/feedback";

  FeedbackPage({Key key}) : super(key: key);

  @override
  FeedBackPageState createState() => new FeedBackPageState();
}

class FeedBackPageState extends State<FeedbackPage> {
  Future<Null> _launched;

  Future<Null> _launch(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: new Text("Could not open mail app"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
      drawer: TrufiDrawer(FeedbackPage.route),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return AppBar(title: Text(localization.menuFeedback));
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                child: Text(
                  localization.feedbackTitle,
                  style: theme.textTheme.title.copyWith(
                    color: theme.textTheme.body2.color,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.feedbackContent,
                  style: theme.textTheme.body2,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: FutureBuilder<Null>(
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
      child: Icon(Icons.email, color: theme.primaryIconTheme.color),
      onPressed: () {
        setState(() {
          final String url = "mailto:${cfg.email.feedback}?subject=Feedback";
          _launched = _launch(context, url);
        });
      },
      heroTag: null,
    );
  }
}
