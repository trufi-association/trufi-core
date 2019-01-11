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

Widget buildErrorAlert({
  @required BuildContext context,
  String error,
}) {
  return _buildAlert(
    context: context,
    title: TrufiLocalizations.of(context).commonError,
    content: error,
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
      //TODO: re-add when offline mode is implemented
      //_buildOnAndOfflineButton(context, !online),
      _buildOKButton(context),
    ],
  );
}

Widget _buildOnAndOfflineButton(BuildContext context, bool online) {
  final localizations = TrufiLocalizations.of(context);
  return FlatButton(
    onPressed: () {
      PreferencesBloc.of(context).inChangeOnline.add(online);
      Navigator.pop(context);
    },
    child: Text(
      online ? localizations.commonGoOnline : localizations.commonGoOffline,
    ),
  );
}

Widget _buildAlert({
  @required BuildContext context,
  String title,
  String content,
  List<Widget> actions,
}) {
  TextStyle textStyle = TextStyle().copyWith(
    color: Theme.of(context).textTheme.body2.color,
  );
  return AlertDialog(
    title: title != null ? Text(title, style: textStyle) : null,
    content: content != null ? Text(content, style: textStyle) : null,
    actions: actions,
  );
}

Widget _buildOKButton(BuildContext context) {
  return FlatButton(
    onPressed: () => Navigator.pop(context),
    child: Text(TrufiLocalizations.of(context).commonOK),
  );
}
