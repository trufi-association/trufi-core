import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_localizations.dart';

Widget buildAlertLocationServicesDenied(BuildContext context) {
  TrufiLocalizations localizations = TrufiLocalizations.of(context);
  return buildAlert(
    context: context,
    title: localizations.alertLocationServicesDeniedTitle,
    content: localizations.alertLocationServicesDeniedMessage,
  );
}

Widget buildAlert({
  @required BuildContext context,
  String title,
  String content,
}) {
  TrufiLocalizations localizations = TrufiLocalizations.of(context);
  return AlertDialog(
      title: title != null ? Text(title) : null,
      content: content != null ? Text(content) : null,
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.commonOK),
        ),
      ]);
}
