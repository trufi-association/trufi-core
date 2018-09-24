import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/widgets/trufi_drawer.dart';

class FeedbackPage extends StatefulWidget {
  static const String route = "feedback";

  FeedbackPage({Key key}) : super(key: key);

  @override
  FeedBackPageState createState() => new FeedBackPageState();
}

class FeedBackPageState extends State<FeedbackPage> {
  static const LaunchUrl =
      "mailto:trufi-feedback@googlegroups.com?subject=Feedback";

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
      drawer: _buildDrawer(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(title: Text(TrufiLocalizations.of(context).menuFeedback));
  }

  Widget _buildBody(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                localizations.feedbackTitle,
                style: theme.textTheme.title,
              ),
              Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  localizations.feedbackContent,
                  style: theme.textTheme.body1,
                ),
              ),
              Container(height: 16.0),
              FutureBuilder<Null>(
                  future: _launched,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return Text(snapshot.hasError ? "${snapshot.error}" : "");
                  }),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return TrufiDrawer(
      FeedbackPage.route,
      onLanguageChangedCallback: () => setState(() {}),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return FloatingActionButton.extended(
      backgroundColor: theme.primaryColor,
      icon: Icon(Icons.send, color: theme.primaryIconTheme.color),
      label: Text(
        localizations.feedbackButton,
        style: theme.primaryTextTheme.body1,
      ),
      onPressed: () {
        setState(() {
          _launched = _launch(LaunchUrl);
        });
      },
    );
  }
}
