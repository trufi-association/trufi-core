import 'package:flutter/material.dart';

import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class FeedbackPage extends StatelessWidget {
  static const String route = "/Feedback";
  final Widget Function(BuildContext) drawerBuilder;

  const FeedbackPage({
    Key? key,
    required this.drawerBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localization.menuFeedback)),
      drawer: drawerBuilder(context),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text("feedbackTitle"),
                  Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: const Text("feedbackContent"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
        heroTag: null,
        child: const Icon(Icons.feedback),
      ),
    );
  }
}
