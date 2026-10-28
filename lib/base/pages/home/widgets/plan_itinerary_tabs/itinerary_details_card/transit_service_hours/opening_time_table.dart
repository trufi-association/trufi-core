import 'package:flutter/material.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/simple_opening_hours.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class OpeningTimeTable extends StatefulWidget {
  final SimpleOpeningHours openingHours;
  final String? currentOpeningTime;
  final bool isSimpleComponent;

  /// The instant the header describes ("service active", "departures");
  /// defaults to [DateTime.now]. Tests inject it to pin the weekday and the
  /// time of day.
  final DateTime? now;

  const OpeningTimeTable({
    super.key,
    required this.openingHours,
    this.currentOpeningTime,
    this.isSimpleComponent = false,
    this.now,
  });
  static String getCurrentOpeningTime(SimpleOpeningHours sOpeningHours) {
    final weekday = DateTime.now().weekday;
    return sOpeningHours.openingHours.values.toList()[weekday - 1].join(",");
  }

  @override
  State<OpeningTimeTable> createState() => _OpeningTimeTableState();
}

class _OpeningTimeTableState extends State<OpeningTimeTable> {
  static const Color _iconColor = Color(0xFF747474);
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    final localization = TrufiBaseLocalization.of(context);
    final isAlwaysOpen = widget.openingHours.inp == '24/7';
    final now = widget.now ?? DateTime.now();
    final weekday = now.weekday;
    final textColor = widget.isSimpleComponent
        ? isExpanded
            ? isDarkMode
                ? theme.colorScheme.surface
                : theme.colorScheme.onSurface
            : theme.colorScheme.onSurface
        : isExpanded
            ? isDarkMode
                ? theme.colorScheme.surface
                : theme.colorScheme.onSurface
            : isDarkMode
                ? theme.colorScheme.onSurface
                : theme.colorScheme.surface;
    return Row(
      children: [
        IntrinsicWidth(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              visualDensity: VisualDensity.compact,
              collapsedIconColor: isExpanded || widget.isSimpleComponent
                  ? Colors.black
                  : Colors.white,
              iconColor: textColor,
              backgroundColor: Colors.white,
              // collapsedBackgroundColor: Colors.transparent,
              tilePadding: EdgeInsets.symmetric(
                horizontal: widget.isSimpleComponent ? 0 : 10,
                vertical: 0,
              ),
              showTrailingIcon: false,
              childrenPadding: EdgeInsets.fromLTRB(
                  widget.isSimpleComponent ? 23 : 33, 0, 16, 10),
              title: Row(
                children: [
                  _header(localization, now, textColor),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: textColor,
                  ),
                ],
              ),
              onExpansionChanged: (value) => setState(() {
                isExpanded = value;
              }),
              children: [
                isAlwaysOpen
                    ? Text(
                        localization.commonOpenAlways,
                        style: const TextStyle(
                          color: _iconColor,
                        ),
                      )
                    : Column(
                        children: widget.openingHours.openingHours.keys.map(
                          (dayKey) {
                            bool isBold = widget.openingHours.openingHours.keys
                                    .toList()[weekday - 1] ==
                                dayKey;
                            final style = TextStyle(
                              fontWeight: isBold ? FontWeight.bold : null,
                              color: _iconColor,
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    SimpleOpeningHours.getDayName(
                                        dayKey, localization),
                                    style: style,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children:
                                        _dayTimes(dayKey, localization, style),
                                  )
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// One line per service window as written, the single departures on one
  /// line behind the "Departures" label; "Closed" when the day has neither.
  List<Widget> _dayTimes(
    String dayKey,
    TrufiBaseLocalization localization,
    TextStyle style,
  ) {
    final ranges = widget.openingHours.rangesOf(dayKey);
    final departures = widget.openingHours.departuresOf(dayKey);
    if (ranges.isEmpty && departures.isEmpty) {
      return [
        Text(
          localization.commonClosed,
          style: const TextStyle(color: _iconColor),
        )
      ];
    }
    return [
      ...ranges.map((range) => Text(range, style: style)),
      if (departures.isNotEmpty)
        Text(
          '${localization.openingHoursDepartures}: ${departures.join(', ')}',
          style: style,
        ),
    ];
  }

  /// The badge of the title: inside a service window, "service active ·
  /// closes at"; on a day with fixed departures, the ones still ahead (or
  /// "no more departures today"); otherwise "out of service".
  Widget _header(
    TrufiBaseLocalization localization,
    DateTime now,
    Color textColor,
  ) {
    final openingHours = widget.openingHours;
    if (openingHours.isWithinServiceWindowOn(now)) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.circle,
              color: Color(0xFF55FF33),
              size: 10,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              localization.openingHoursServiceActive,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.circle,
                color: textColor,
                size: 5,
              ),
            ),
            Text(
              "cierra a las ${openingHours.getClosingTimeOfDay(now)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }
    final departures = openingHours.departuresOn(now);
    if (departures.isNotEmpty) {
      final next = openingHours.nextDepartureOn(now);
      final upcoming = next == null
          ? const <String>[]
          : departures.sublist(departures.indexOf(next));
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              color: textColor,
              size: 14,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              upcoming.isNotEmpty
                  ? '${localization.openingHoursDepartures}: ${upcoming.join(', ')}'
                  : localization.openingHoursNoMoreDeparturesToday,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      margin: const EdgeInsets.only(right: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFD72A2A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        localization.openingHoursCurrentlyOutService,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
