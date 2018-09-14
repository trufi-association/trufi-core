import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              localizations.feedbackContent,
              style: theme.textTheme.title,
              textAlign: TextAlign.center,
            ),
            Container(height: 16.0),
            FutureBuilder<Null>(
                future: _launched,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Text(snapshot.hasError ? "${snapshot.error}" : "");
                }),
          ],
        ),
      ),
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
      icon: Icon(Icons.send),
      label: Text(localizations.feedbackButton),
      onPressed: () {
        setState(() {
          _launched = _launch(LaunchUrl);
        });
      },
    );
  }
}
