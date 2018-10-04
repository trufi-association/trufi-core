import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/trufi_localizations.dart';

Widget buildAlertLocationServicesDenied(BuildContext context) {
  final localizations = TrufiLocalizations.of(context);
  return _buildAlert(
    context: context,
    title: localizations.alertLocationServicesDeniedTitle,
    content: localizations.alertLocationServicesDeniedMessage,
    actions: [_buildOKButton(context)],
  );
}

Widget buildOnAndOfflineErrorAlert({
  @required BuildContext context,
  @required bool online,
  String title,
  String content,
}) {
  return _buildAlert(
    context: context,
    title: title,
    content: content,
    actions: [
      _buildOnAndOfflineButton(context, !online),
      _buildOKButton(context),
    ],
  );
}

Widget _buildOnAndOfflineButton(BuildContext context, bool online) {
  return FlatButton(
    onPressed: () {
      PreferencesBloc.of(context).inChangeOnline.add(online);
      Navigator.pop(context);
    },
    child: Text(online ? "Switch to online" : "Switch to offline"),
  );
}

Widget _buildAlert({
  @required BuildContext context,
  String title,
  String content,
  List<Widget> actions,
}) {
  return AlertDialog(
    title: title != null ? Text(title) : null,
    content: content != null ? Text(content) : null,
    actions: actions,
  );
}

Widget _buildOKButton(BuildContext context) {
  return FlatButton(
    onPressed: () => Navigator.pop(context),
    child: Text(TrufiLocalizations.of(context).commonOK),
  );
}
