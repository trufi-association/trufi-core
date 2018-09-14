import 'package:flutter/material.dart';
import 'package:trufi_app/trufi_localizations.dart';

Widget buildAlertLocationServicesDenied(BuildContext context) {
  TrufiLocalizations localizations = TrufiLocalizations.of(context);
  return buildAlert(context, localizations.alertLocationServicesDeniedTitle,
      localizations.alertLocationServicesDeniedMessage);
}

Widget buildAlert(BuildContext context, String title, String text) {
  TrufiLocalizations localizations = TrufiLocalizations.of(context);
  return AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.commonOK),
        ),
      ]);
}
