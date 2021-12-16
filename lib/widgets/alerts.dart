import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

Widget buildAlertLocationServicesDenied(BuildContext context) {
  final localization = TrufiLocalization.of(context);
  return _buildAlert(
    context: context,
    title: Text(localization.alertLocationServicesDeniedTitle),
    content: Text(localization.alertLocationServicesDeniedMessage),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          Geolocator.requestPermission();
        },
        child: Text(
          localization.commonOK,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    ],
  );
}

Widget buildErrorAlert({
  required BuildContext context,
  required String error,
}) {
  final localization = TrufiLocalization.of(context);
  return _buildAlert(
    context: context,
    title: Text(localization.commonError),
    content: Text(error),
    actions: [_buildOKButton(context)],
  );
}

Widget buildTransitErrorAlert({
  required BuildContext context,
  required Function onReportMissingRoute,
  required Function onShowCarRoute,
  String? error,
}) {
  final localization = TrufiLocalization.of(context);
  final theme = context.read<ThemeCubit>().state.activeTheme!;
  final actionTextStyle = theme.textTheme.bodyText2!.copyWith(
    color: theme.accentColor,
  );
  return _buildAlert(
    context: context,
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
  required BuildContext context,
  required bool online,
  Widget? title,
  Widget? content,
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

Widget _buildAlert({
  required BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
}) {
  final theme = context.read<ThemeCubit>().state.activeTheme!;
  return AlertDialog(
    title: title,
    titleTextStyle: theme.primaryTextTheme.headline6!.copyWith(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    ),
    content: content,
    contentTextStyle:
        theme.primaryTextTheme.bodyText2!.copyWith(color: Colors.black),
    actions: actions,
  );
}

Widget _buildOKButton(BuildContext context) {
  final localization = TrufiLocalization.of(context);
  return TextButton(
    onPressed: () => Navigator.pop(context),
    child: Text(localization.commonOK),
  );
}
