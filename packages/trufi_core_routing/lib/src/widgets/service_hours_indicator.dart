import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/routing_localizations.dart';
import '../models/service_hours.dart';

/// One-line service indicator: a colored dot + a short label
/// telling the user whether the route is running right now.
///
/// Always evaluated against `DateTime.now()` (not the app's
/// `routingTimeOverride`) so the answer matches the user's
/// wall-clock — "is this bus running right now?". Tapping the
/// indicator expands a 7-day schedule inline (same pattern as the
/// "X paradas" toggle in the itinerary leg), with the chevron
/// flipping to signal the open state.
///
/// Examples (Spanish locale):
///   🟢  Activo · cierra a las 22:00      ⌄
///   🔴  Cerrado · abre a las 06:00       ⌄
///   🔴  Cerrado · abre lun a las 06:00   ⌄
///
/// Lives in `trufi_core_routing` so both the transit list (route tile
/// / detail) and the home screen (itinerary plan leg) can render the
/// same badge without depending on each other.
class ServiceHoursIndicator extends StatefulWidget {
  final ServiceHours serviceHours;

  const ServiceHoursIndicator({super.key, required this.serviceHours});

  @override
  State<ServiceHoursIndicator> createState() => _ServiceHoursIndicatorState();
}

class _ServiceHoursIndicatorState extends State<ServiceHoursIndicator> {
  bool _expanded = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Re-render every minute so the label flips at open/close time
    // without the user having to reopen the screen. Aligned to the
    // next wall-clock minute so the first tick lands right when the
    // displayed minute would change.
    final now = DateTime.now();
    final delay = Duration(
      seconds: 60 - now.second,
      milliseconds: -now.millisecond,
    );
    Future.delayed(delay, () {
      if (!mounted) return;
      setState(() {});
      _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // Convert ISO weekday (1=Mon..7=Sun) → a sample DateTime in that
  // weekday so DateFormat can render the locale-specific name.
  static DateTime _sampleDateForWeekday(int isoWeekday) {
    // 2024-01-01 was a Monday → adding (isoWeekday-1) days lands on the
    // requested weekday in any locale.
    return DateTime(2024, 1, isoWeekday);
  }

  ({String label, bool active}) _status(
    DateTime now,
    RoutingLocalizations l10n,
    String locale,
  ) {
    final sh = widget.serviceHours;
    final mins = now.hour * 60 + now.minute;
    final start = sh.startTime.hour * 60 + sh.startTime.minute;
    final end = sh.endTime.hour * 60 + sh.endTime.minute;
    final today = now.weekday;
    final runsToday = sh.daysOfWeek.contains(today);
    final inWindow = start <= end
        ? (mins >= start && mins < end)
        : (mins >= start || mins < end);

    if (runsToday && inWindow) {
      return (
        label: l10n.serviceActiveClosesAt(_fmt(sh.endTime)),
        active: true,
      );
    }
    if (runsToday && mins < start) {
      return (
        label: l10n.serviceClosedOpensAt(_fmt(sh.startTime)),
        active: false,
      );
    }
    for (int offset = 1; offset <= 7; offset++) {
      final candidate = ((today - 1 + offset) % 7) + 1;
      if (sh.daysOfWeek.contains(candidate)) {
        final whenLabel = offset == 1
            ? l10n.serviceTomorrow
            : DateFormat.E(locale).format(_sampleDateForWeekday(candidate));
        return (
          label: l10n.serviceClosedOpensDayAt(whenLabel, _fmt(sh.startTime)),
          active: false,
        );
      }
    }
    return (label: l10n.serviceClosed, active: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = RoutingLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final status = _status(DateTime.now(), l10n, locale);
    final dotColor = status.active ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    status.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 14, bottom: 4),
            child: _ScheduleList(serviceHours: widget.serviceHours),
          ),
      ],
    );
  }
}

/// 7-row list showing each weekday's hours, with the current day
/// highlighted. Rendered inline below [ServiceHoursIndicator] when
/// expanded.
class _ScheduleList extends StatelessWidget {
  final ServiceHours serviceHours;

  const _ScheduleList({required this.serviceHours});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = RoutingLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = DateTime.now().weekday;
    final hours =
        '${_ServiceHoursIndicatorState._fmt(serviceHours.startTime)} — '
        '${_ServiceHoursIndicatorState._fmt(serviceHours.endTime)}';
    // Capitalize the first letter — DateFormat.EEEE returns lowercase
    // in Spanish ("lunes") but the schedule reads better with title
    // case ("Lunes"), matching common UI conventions.
    String dayLong(int isoWeekday) {
      final raw = DateFormat.EEEE(locale).format(
        _ServiceHoursIndicatorState._sampleDateForWeekday(isoWeekday),
      );
      if (raw.isEmpty) return raw;
      return raw[0].toUpperCase() + raw.substring(1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int day = 1; day <= 7; day++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    dayLong(day),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: day == today
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    serviceHours.daysOfWeek.contains(day)
                        ? hours
                        : l10n.serviceClosed,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: day == today
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: serviceHours.daysOfWeek.contains(day)
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
