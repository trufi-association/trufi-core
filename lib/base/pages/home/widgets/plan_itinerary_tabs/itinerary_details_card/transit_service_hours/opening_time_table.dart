import 'package:flutter/material.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/simple_opening_hours.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class OpeningTimeTable extends StatefulWidget {
  final SimpleOpeningHours openingHours;
  final String? currentOpeningTime;
  final bool isSimpleComponent;
  const OpeningTimeTable({
    super.key,
    required this.openingHours,
    this.currentOpeningTime,
    this.isSimpleComponent = false,
  });
  static String getCurrentOpeningTime(SimpleOpeningHours sOpeningHours) {
    final weekday = DateTime.now().weekday;
    return sOpeningHours.openingHours.values.toList()[weekday - 1].join(",");
  }

  @override
  State<OpeningTimeTable> createState() => _OpeningTimeTableState();
}

class _OpeningTimeTableState extends State<OpeningTimeTable> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    final localization = TrufiBaseLocalization.of(context);
    final isAlwaysOpen = widget.openingHours.inp == '24/7';
    final weekday = DateTime.now().weekday;
    const iconColor = Color(0xFF747474);
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
                  (widget.openingHours.isOpenNow())
                      ? Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color(0xFF55FF33),
                                size: 10,
                              ),
                              SizedBox(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.circle,
                                  color: textColor,
                                  size: 5,
                                ),
                              ),
                              Text(
                                "cierra a las ${widget.openingHours.getClosingTimeOfDay(DateTime.now())}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          margin: EdgeInsets.only(right: 30),
                          decoration: BoxDecoration(
                            color: Color(0xFFD72A2A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            localization.openingHoursCurrentlyOutService,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
                          color: iconColor,
                        ),
                      )
                    : Column(
                        children: widget.openingHours.openingHours.entries.map(
                          (day) {
                            bool isBold = widget.openingHours.openingHours.keys
                                    .toList()[weekday - 1] ==
                                day.key;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    SimpleOpeningHours.getDayName(
                                        day.key, localization),
                                    style: TextStyle(
                                      fontWeight:
                                          isBold ? FontWeight.bold : null,
                                      color: iconColor,
                                    ),
                                  ),
                                  Column(
                                    children: day.value.isNotEmpty
                                        ? day.value
                                            .map((e) => Text(
                                                  e,
                                                  style: TextStyle(
                                                    fontWeight: isBold
                                                        ? FontWeight.bold
                                                        : null,
                                                    color: iconColor,
                                                  ),
                                                ))
                                            .toList()
                                        : [
                                            Text(
                                              localization.commonClosed,
                                              style: const TextStyle(
                                                  color: iconColor),
                                            )
                                          ],
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
}
