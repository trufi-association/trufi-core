import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatelessWidget {
  static const String route = "feedback";

  @override
  Widget build(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.feedback)),
      body: new _FeedBackPage(),
      drawer: buildDrawer(context, route),
    );
  }
}

class _FeedBackPage extends StatefulWidget {
  _FeedBackPage({Key key}) : super(key: key);

  @override
  _FeedBackPageState createState() => new _FeedBackPageState();
}

class _FeedBackPageState extends State<_FeedBackPage> {
  Future<Null> _launched;

  Future<Null> _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<Null> snapshot) {
    if (snapshot.hasError) {
      return new Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    const String toLaunch = 'mailto:feedback@trufi.com?subject=Feedback';
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            child: new Text(
              localizations.feedbackContent,
              maxLines: 3,
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.7),
            ),
            padding: const EdgeInsets.all(24.0),
          ),
          const Padding(padding: const EdgeInsets.all(16.0)),
          new RaisedButton(
            onPressed: () => setState(() {
                  _launched = _launch(toLaunch);
                }),
            child: new Text(localizations.feedbackButton),
          ),
          const Padding(padding: const EdgeInsets.all(16.0)),
          new FutureBuilder<Null>(future: _launched, builder: _launchStatus),
        ],
      ),
    );
  }
}
