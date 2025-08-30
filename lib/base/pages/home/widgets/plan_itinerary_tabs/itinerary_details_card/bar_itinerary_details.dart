import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/duration_component.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/walk_distance.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class BarItineraryDetails extends StatelessWidget {
  final Itinerary itinerary;

  static const String _whatsAppNumber = '59176442031';

  const BarItineraryDetails({
    super.key,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);

    return Container(
      height: itinerary.startDateText(localization) == '' ? 40 : 54,
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DurationComponent(
            duration: itinerary.duration,
            startTime: itinerary.startTime,
            endTime: itinerary.endTime,
            futureText: itinerary.startDateText(localization),
          ),
          Row(
            children: [
              if (itinerary.walkDistance > 0)
                WalkDistance(
                  walkDistance: itinerary.walkDistance,
                  walkDuration: itinerary.walkTime,
                  icon: walkIcon(color: theme.iconTheme.color),
                ),
              if (itinerary.totalBikingDistance > 0) ...[
                const SizedBox(width: 10),
                WalkDistance(
                  walkDistance: itinerary.totalBikingDistance,
                  walkDuration: itinerary.totalBikingDuration,
                  icon: bikeIcon(color: theme.iconTheme.color),
                )
              ],
              const SizedBox(width: 8),
              Material(
                color: Colors.red,
                borderRadius: BorderRadius.circular(100),
                child: IconButton(
                  onPressed: () => _openWhatsAppWithReport(context),
                  icon: const Icon(Icons.flag_outlined),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), 
                    ),
                  ),
                  splashRadius: 24,

                  tooltip: 'Reportar problema',
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _openWhatsAppWithReport(BuildContext context) async {
    final localization = TrufiBaseLocalization.of(context);
    final msg = _buildWhatsAppMessage(itinerary, localization, context);
    final uri = Uri.parse(
        'https://wa.me/$_whatsAppNumber?text=${Uri.encodeComponent(msg)}');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  String _buildWhatsAppMessage(
    Itinerary itin,
    TrufiBaseLocalization localization,
    BuildContext context, {
    Uri? shareBaseItineraryUri,
  }) {
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;

    final legs = itin.legs;

    final originName = _safeQuoted(
      routePlannerState.fromPlace?.description?.trim() ??
          (legs.isNotEmpty ? _placeName(legs.first.fromPlace) : '(sin nombre)'),
    );
    final destName = _safeQuoted(
      routePlannerState.toPlace?.description?.trim() ??
          (legs.isNotEmpty ? _placeName(legs.last.toPlace) : '(sin nombre)'),
    );

    final out = StringBuffer()
      ..writeln('REPORT_START')
      ..writeln('SCHEMA_VERSION: 1.0')
      ..writeln('ORIGIN_NAME: $originName')
      ..writeln('DEST_NAME: $destName')
      ..writeln('');

    // 3) Legs
    for (final leg in legs) {
      final type = leg.transportMode.name.toUpperCase();
      final rel = (leg.routeId?.toString().trim().isNotEmpty ?? false)
          ? leg.routeId!.toString().trim()
          : '-';

      final code = _bestCodeForLeg(leg);

      final fromLat = _tryGetLat(leg.fromPlace);
      final fromLon = _tryGetLon(leg.fromPlace);
      final toLat = _tryGetLat(leg.toPlace);
      final toLon = _tryGetLon(leg.toPlace);

      final fromName = _safeQuoted(_placeName(leg.fromPlace));
      final toName = _safeQuoted(_placeName(leg.toPlace));
      if (leg.isLegOnFoot) {
        out.write('LEG|TYPE=$type');
      } else {
        out.write('LEG|TYPE=$type|REL=$rel|CODE=$code');
      }
      out.write('|FROM_LAT=${_fmtCoordOrDash(fromLat)}');
      out.write('|FROM_LON=${_fmtCoordOrDash(fromLon)}');
      out.write('|FROM_NAME=$fromName');
      out.write('|TO_LAT=${_fmtCoordOrDash(toLat)}');
      out.write('|TO_LON=${_fmtCoordOrDash(toLon)}');
      out.write('|TO_NAME=$toName');
      out.writeln();
    }

    final url = _buildShareUrlIfPossible(
      shareBaseItineraryUri,
      routePlannerState,
    );
    if (url != null && url.isNotEmpty) {
      out.writeln('ITINERARY_URL: $url');
    }

    out.writeln('REPORT_END');

    return out.toString();
  }

  String _bestCodeForLeg(Leg leg) {
    final s1 = leg.shortName?.trim();
    if (s1 != null && s1.isNotEmpty) return s1;

    final s2 = leg.route?.shortName?.trim();
    if (s2 != null && s2.isNotEmpty) return s2;

    final s3 = leg.routeLongName?.trim();
    if (s3 != null && s3.isNotEmpty) return s3;

    final s4 = leg.route?.longName?.trim();
    if (s4 != null && s4.isNotEmpty) return s4;

    return '-';
  }

  String _safeQuoted(String? s) {
    final val = (s ?? '').trim();
    final escaped = val.replaceAll('"', r'\"');
    return '"$escaped"';
  }

  String _placeName(Place p) {
    final n = (p.name ?? '').trim();
    if (n.isNotEmpty) return n;

    final lat = _tryGetLat(p);
    final lon = _tryGetLon(p);
    if (lat != null && lon != null) {
      return '(${_fmtCoord(lat)}, ${_fmtCoord(lon)})';
    }
    return '(sin nombre)';
  }

  double? _tryGetLat(Place p) {
    try {
      return (p as dynamic).lat as double?;
    } catch (_) {
      try {
        return (p as dynamic).latLng?.latitude as double?;
      } catch (_) {
        return null;
      }
    }
  }

  double? _tryGetLon(Place p) {
    try {
      return (p as dynamic).lon as double?;
    } catch (_) {
      try {
        return (p as dynamic).latLng?.longitude as double?;
      } catch (_) {
        return null;
      }
    }
  }

  String _fmtCoordOrDash(double? v) => v == null ? '-' : _fmtCoord(v);

  String _fmtCoord(num v) => v.toStringAsFixed(8); // precisión razonable

  String? _buildShareUrlIfPossible(
    Uri? base,
    RoutePlannerState state,
  ) {
    if (base == null || state.selectedItinerary == null) return null;

    final fromDesc = state.fromPlace?.description ?? '';
    final fromLat = state.fromPlace?.latLng.latitude ?? '';
    final fromLon = state.fromPlace?.latLng.longitude ?? '';

    final toDesc = state.toPlace?.description ?? '';
    final toLat = state.toPlace?.latLng.latitude ?? '';
    final toLon = state.toPlace?.latLng.longitude ?? '';

    final idx = state.plan?.itineraries?.indexOf(state.selectedItinerary!) ?? 0;

    final fromQ = '$fromDesc,$fromLat,$fromLon';
    final toQ = '$toDesc,$toLat,$toLon';

    return base.replace(
      queryParameters: {
        'from': fromQ,
        'to': toQ,
        'itinerary': idx.toString(),
      },
    ).toString();
  }
}
