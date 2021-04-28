import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

Widget buildAlertLocationServicesDenied(BuildContext context, ThemeData theme) {
  final localization = TrufiLocalization.of(context);
  return _buildAlert(
    theme: theme,
    title: Text(localization.alertLocationServicesDeniedTitle),
    content: Text(localization.alertLocationServicesDeniedMessage),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          Geolocator.requestPermission();
        },
        child: Text(localization.commonOK),
      ),
    ],
  );
}

Widget buildErrorAlert({
  @required BuildContext context,
  @required TrufiLocalization localization,
  @required ThemeData theme,
  String error,
}) {
  return _buildAlert(
    theme: theme,
    title: Text(localization.commonError),
    content: Text(error),
    actions: [
      TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localization.commonOK))
    ],
  );
}

Widget buildTransitErrorAlert({
  @required BuildContext context,
  @required Function onReportMissingRoute,
  @required Function onShowCarRoute,
  String error,
}) {
  final localization = TrufiLocalization.of(context);
  final theme = Theme.of(context);
  final actionTextStyle = theme.textTheme.bodyText2.copyWith(
    color: theme.accentColor,
  );
  return _buildAlert(
    theme: theme,
    title: Text(localization.noRouteError),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onReportMissingRoute();
          },
          child: Text(
            localization.noRouteErrorActionReportMissingRoute,
            style: actionTextStyle,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            localization.noRouteErrorActionCancel,
            style: actionTextStyle,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onShowCarRoute();
          },
          child: Text(
            localization.noRouteErrorActionShowCarRoute,
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
  @required TrufiLocalization localization,
  Widget title,
  Widget content,
}) {
  final theme = Theme.of(context);
  return _buildAlert(
    theme: theme,
    title: title,
    content: content,
    actions: [
      //TODO: re-add when offline mode is implemented
      //_buildOnAndOfflineButton(context, !online),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(localization.commonOK),
      ),
    ],
  );
}

// TODO: Understand why not implemented and used.
// ignore: unused_element
Widget _buildOnAndOfflineButton(BuildContext context, bool online) {
  final localization = TrufiLocalization.of(context);
  return TextButton(
    onPressed: () {
      context.read<PreferencesCubit>().updateOnline(loadOnline: online);
      Navigator.pop(context);
    },
    child: Text(
      online ? localization.commonGoOnline : localization.commonGoOffline,
    ),
  );
}

Widget _buildAlert({
  @required ThemeData theme,
  Widget title,
  Widget content,
  List<Widget> actions,
}) {
  return AlertDialog(
    backgroundColor: theme.primaryColor,
    title: title,
    titleTextStyle: theme.primaryTextTheme.headline6,
    content: content,
    contentTextStyle: theme.primaryTextTheme.bodyText2,
    actions: actions,
  );
}
