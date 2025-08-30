import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/pages/home/services/exception/fetch_online_exception.dart';
import 'package:trufi_core/base/widgets/alerts/base_build_alert.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class BuildTransitErrorAlert extends StatelessWidget {
  static const String _whatsAppNumber = '59176442031';
  final FetchOnlinePlanException exception;
  const BuildTransitErrorAlert({
    super.key,
    required this.exception,
  });

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final mapConfiguration = context.read<MapConfigurationCubit>().state;
    final theme = Theme.of(context);
    final actionTextStyle = TextStyle(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    return BaseBuildAlert(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.noRouteError),
          const SizedBox(height: 15),
          Text(
            localizedErrorForPlanError(
              exception.code,
              exception.message,
              localization,
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _openWhatsAppWithReport(context),
            child: Text(
              'Reportar problema',
              style: actionTextStyle,
            ),
          ),
          if (mapConfiguration.feedbackForm != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // ignore: deprecated_member_use
                launch(mapConfiguration.feedbackForm!);
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
        ],
      ),
    );
  }

  String localizedErrorForPlanError(
    int errorId,
    String message,
    TrufiBaseLocalization localization,
  ) {
    if (errorId == 500 || errorId == 503) {
      return localization.errorServerUnavailable;
    } else if (errorId == 400) {
      return localization.errorOutOfBoundary;
    } else if (errorId == 404) {
      return localization.errorPathNotFound;
    } else if (errorId == 406) {
      return localization.errorNoTransitTimes;
    } else if (errorId == 408) {
      return localization.errorServerTimeout;
    } else if (errorId == 409) {
      return localization.errorTrivialDistance;
    } else if (errorId == 413) {
      return localization.errorServerCanNotHandleRequest;
    } else if (errorId == 440) {
      return localization.errorUnknownOrigin;
    } else if (errorId == 450) {
      return localization.errorUnknownDestination;
    } else if (errorId == 460) {
      return localization.errorUnknownOriginDestination;
    } else if (errorId == 470) {
      return localization.errorNoBarrierFree;
    } else if (errorId == 340) {
      return localization.errorAmbiguousOrigin;
    } else if (errorId == 350) {
      return localization.errorAmbiguousDestination;
    } else if (errorId == 360) {
      return localization.errorAmbiguousOriginDestination;
    }
    return message;
  }

  Future<void> _openWhatsAppWithReport(BuildContext context) async {
    final msg = _buildWhatsAppMinimalHeader(context);
    final uri = Uri.parse(
        'https://wa.me/$_whatsAppNumber?text=${Uri.encodeComponent(msg)}');

    Navigator.of(context).pop();

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  String _buildWhatsAppMinimalHeader(BuildContext context) {
    final routePlannerState = context.read<RoutePlannerCubit>().state;

    final fromDesc = (routePlannerState.fromPlace?.description ?? '').trim();
    final fromLat = routePlannerState.fromPlace?.latLng.latitude;
    final fromLon = routePlannerState.fromPlace?.latLng.longitude;

    final toDesc = (routePlannerState.toPlace?.description ?? '').trim();
    final toLat = routePlannerState.toPlace?.latLng.latitude;
    final toLon = routePlannerState.toPlace?.latLng.longitude;

    final originName =
        _safeQuoted(fromDesc.isNotEmpty ? fromDesc : '(sin nombre)');
    final destName = _safeQuoted(toDesc.isNotEmpty ? toDesc : '(sin nombre)');

    final buf = StringBuffer()
      ..writeln('REPORT_START')
      ..writeln('SCHEMA_VERSION: 1.0')
      ..writeln('ORIGIN_NAME: $originName');
    if (fromLat != null && fromLon != null) {
      buf.writeln('ORIGIN_LAT: ${_fmtCoord(fromLat)} - ORIGIN_LON: ${_fmtCoord(fromLon)}');
    }
      buf.writeln('DEST_NAME: $destName');
    if (toLat != null && toLon != null) {
      buf.writeln('DEST_LAT: ${_fmtCoord(toLat)} - DEST_LON: ${_fmtCoord(toLon)}');
    }
    buf.writeln('REPORT_END');
    return buf.toString();
  }

  String _safeQuoted(String s) {
    final escaped = s.replaceAll('"', r'\"');
    return '"$escaped"';
  }

  String _fmtCoord(num v) => v.toStringAsFixed(8);
}
