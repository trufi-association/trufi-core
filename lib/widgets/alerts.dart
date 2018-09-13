import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_localizations.dart';

Widget buildAlertLocationServicesDenied(BuildContext context) {
  TrufiLocalizations localizations = TrufiLocalizations.of(context);
  return AlertDialog(
      title: Text(localizations.alertLocationServicesDeniedTitle),
      content: Text(localizations.alertLocationServicesDeniedMessage),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.commonOK),
        ),
      ]);
}
