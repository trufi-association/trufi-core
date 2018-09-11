import 'package:flutter/material.dart';

import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';

class FeedbackPage extends StatelessWidget {
  static const String route = "feedback";

  @override
  Widget build(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.feedback)),
      body: Center(child: Text("Any questions?")),
      drawer: TrufiDrawer(FeedbackPage.route),
    );
  }
}
