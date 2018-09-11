import 'package:flutter/material.dart';

import 'package:trufi_app/drawer.dart';
import 'package:trufi_app/trufi_localizations.dart';

class AboutPage extends StatelessWidget {
  static const String route = "about";

  @override
  Widget build(BuildContext context) {
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.about)),
      body: Center(child: Text("It's all about TRUFI")),
      drawer: TrufiDrawer(AboutPage.route),
    );
  }
}
