import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trufi_configuration.dart';
import '../trufi_localizations.dart';
import '../widgets/trufi_drawer.dart';

class FeedbackPage extends StatefulWidget {
  static const String route = "/feedback";

  FeedbackPage({Key key}) : super(key: key);

  @override
  FeedBackPageState createState() => new FeedBackPageState();
}

class FeedBackPageState extends State<FeedbackPage> {
  Future<Null> _launched;

  Future<Null> _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch';
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
    final localization = TrufiLocalizations.of(context).localization;
    return AppBar(title: Text(localization.menuFeedback()));
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalizations.of(context).localization;
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                child: Text(
                  localization.feedbackTitle(),
                  style: theme.textTheme.title.copyWith(
                    color: theme.textTheme.body2.color,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localization.feedbackContent(),
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
          _launched = _launch("mailto:${cfg.email.feedback}?subject=Feedback");
        });
      },
      heroTag: null,
    );
  }
}
