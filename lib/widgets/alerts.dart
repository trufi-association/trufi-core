import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/trufi_localizations.dart';

Widget buildAlertLocationServicesDenied(BuildContext context) {
  final localizations = TrufiLocalizations.of(context);
  return _buildAlert(
    context: context,
    title: Text(localizations.alertLocationServicesDeniedTitle),
    content: Text(localizations.alertLocationServicesDeniedMessage),
    actions: [_buildOKButton(context)],
  );
}

Widget buildErrorAlert({
  @required BuildContext context,
  String error,
}) {
  return _buildAlert(
    context: context,
    title: Text(TrufiLocalizations.of(context).commonError),
    content: Text(error),
    actions: [_buildOKButton(context)],
  );
}

Widget buildTransitErrorAlert({
  @required BuildContext context,
  @required Function onReportMissingRoute,
  @required Function onShowCarRoute,
  String error,
}) {
  final localizations = TrufiLocalizations.of(context);
  final theme = Theme.of(context);
  final actionTextStyle = theme.textTheme.body1.copyWith(
    color: theme.accentColor,
  );
  return _buildAlert(
    context: context,
    title: Text(localizations.noRouteError),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            onReportMissingRoute();
          },
          child: Text(
            localizations.noRouteErrorActionReportMissingRoute,
            style: actionTextStyle,
          ),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            localizations.noRouteErrorActionCancel,
            style: actionTextStyle,
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            onShowCarRoute();
          },
          child: Text(
            localizations.noRouteErrorActionShowCarRoute,
            style: actionTextStyle,
          ),
        ),
      ],
    ),
  );
}

Widget buildOnAndOfflineErrorAlert({
  @required BuildContext context,
  @required bool online,
  Widget title,
  Widget content,
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
  Widget title,
  Widget content,
  List<Widget> actions,
}) {
  return AlertDialog(
    backgroundColor: Theme.of(context).primaryColor,
    title: title,
    content: content,
    actions: actions,
  );
}

Widget _buildOKButton(BuildContext context) {
  return FlatButton(
    onPressed: () => Navigator.pop(context),
    child: Text(TrufiLocalizations.of(context).commonOK),
  );
}
