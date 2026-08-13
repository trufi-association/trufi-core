import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/home_screen_localizations.dart';

/// Returns a darkened version of [color] if it's too light for text on white.
Color _legibleColor(Color color) {
  if (color.computeLuminance() > 0.4) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.5).clamp(0.0, 0.5)).toColor();
  }
  return color;
}

/// Content widget for displaying itinerary details inline (without Scaffold).
/// Use this when you want to show details within an existing panel/sheet.
class ItineraryDetailContent extends StatelessWidget {
  final routing.Itinerary itinerary;
  final VoidCallback? onBack;
  final VoidCallback? onStartNavigation;

  /// Callback when a transit route badge is tapped.
  /// Provides the route code to allow navigation to route details.
  final void Function(String routeCode)? onRouteTap;

  /// When true, the content will shrink to fit and disable its own scrolling.
  /// Use this when the content is inside a parent scrollable.
  final bool shrinkWrap;

  /// The itinerary's group members (#737), [itinerary] included. When there
  /// is more than one, the header shows a switcher so the rider can flip
  /// between the interchangeable options without leaving the detail.
  final List<routing.Itinerary>? alternatives;

  /// Called when the rider picks another option in the switcher.
  final void Function(routing.Itinerary alternative)? onSelectAlternative;

  const ItineraryDetailContent({
    super.key,
    required this.itinerary,
    this.onBack,
    this.onStartNavigation,
    this.onRouteTap,
    this.shrinkWrap = false,
    this.alternatives,
    this.onSelectAlternative,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Header
        _buildHeader(context, theme, colorScheme, l10n),
        // Interchangeable options of the itinerary's group (#737)
        ..._buildAlternativeSwitcher(context, theme, colorScheme),
        const SizedBox(height: 8),
        // Subtle separator
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.outlineVariant.withValues(alpha: 0.0),
                colorScheme.outlineVariant.withValues(alpha: 0.5),
                colorScheme.outlineVariant.withValues(alpha: 0.5),
                colorScheme.outlineVariant.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.15, 0.85, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Timeline
        _VerticalTimeline(
          itinerary: itinerary,
          l10n: l10n,
          onRouteTap: onRouteTap,
        ),
      ],
    );

    if (shrinkWrap) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: content,
    );
  }

  /// The group's options (#737), drawn in journey order with the app's own
  /// visual language (pattern shared by Google Maps' "or `line`" and
  /// Transit/Citymapper's saturated badges): the slots every option has in
  /// common render once as static chips, and the slot that varies renders
  /// as full-color selectable pills — route color with the departure time
  /// inside, a ring on the selected one, the rest dimmed. Both pill states
  /// share size. Hidden when there is nothing to switch to or the options
  /// would be indistinguishable (identical variants while clock times are
  /// pinned/hidden).
  List<Widget> _buildAlternativeSwitcher(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final options = alternatives;
    if (options == null || options.length < 2 || onSelectAlternative == null) {
      return const [];
    }
    final timesHidden =
        context.watch<AppConfiguration?>()?.routingTimeOverride != null;

    List<routing.Leg> transitLegs(routing.Itinerary it) =>
        it.legs.where((leg) => leg.transitLeg).toList(growable: false);

    final referenceLegs = transitLegs(options.first);
    final slotCount = referenceLegs.length;

    // The slot whose route differs between options; null when every slot
    // matches (a departures-only group).
    int? variantSlot;
    for (var i = 0; i < slotCount; i++) {
      final name = referenceLegs[i].displayName;
      final differs = options.any(
        (option) => transitLegs(option)[i].displayName != name,
      );
      if (differs) {
        variantSlot = i;
        break;
      }
    }

    // Pills show the bus type and name; the departure time belongs to the
    // header, which updates on switch (Sam 2026-08-13). The time joins the
    // label only when names alone can't tell the options apart — a
    // departures-only group, or two options riding a same-named variant.
    final variantNames = [
      for (final option in options)
        variantSlot != null ? transitLegs(option)[variantSlot].displayName : '',
    ];
    final needsTime =
        variantNames.toSet().length != variantNames.length ||
        variantNames.any((name) => name.isEmpty);

    String label(routing.Itinerary it, String name) {
      if (!needsTime) return name;
      if (timesHidden) return name;
      final time = formatClockTime(context, it.startTime);
      return name.isEmpty ? time : '$name · $time';
    }

    final labels = [
      for (final (i, option) in options.indexed) label(option, variantNames[i]),
    ];
    // Indistinguishable pills would be worse than none.
    if (labels.any((l) => l.isEmpty) ||
        labels.toSet().length != labels.length) {
      return const [];
    }

    final children = <Widget>[];
    void addSeparator() {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    void addPills() {
      for (final (index, option) in options.indexed) {
        if (index > 0) children.add(const SizedBox(width: 8));
        children.add(
          _optionPill(
            context,
            option,
            index: index,
            selected: option == itinerary,
            showTime: needsTime && !timesHidden,
            colorScheme: colorScheme,
            variantLeg: variantSlot != null
                ? transitLegs(option)[variantSlot]
                : null,
            fallbackLeg: referenceLegs.firstOrNull,
          ),
        );
      }
    }

    for (var i = 0; i < slotCount; i++) {
      if (i > 0) addSeparator();
      if (i == variantSlot) {
        addPills();
      } else {
        // Stable across switches: the chip comes from the first option,
        // not the displayed itinerary, so its color never flickers.
        children.add(
          _commonChip(referenceLegs[i], withIcon: i == 0, colorScheme),
        );
      }
    }
    if (variantSlot == null) {
      // Departures-only group: the times are the options.
      if (slotCount > 0) addSeparator();
      addPills();
    }

    return [
      const SizedBox(height: 8),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: children),
        ),
      ),
    ];
  }

  /// A slot every option shares, in the card chips' language: solid route
  /// color, rounded, bold name (icon only on the journey's first chip).
  Widget _commonChip(
    routing.Leg leg,
    ColorScheme colorScheme, {
    required bool withIcon,
  }) {
    final color = _routeColor(leg.routeColor, colorScheme);
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    final name = leg.displayName;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[
            Icon(Icons.directions_bus_rounded, size: 16, color: textColor),
            if (name.isNotEmpty) const SizedBox(width: 4),
          ],
          if (name.isNotEmpty)
            Text(
              name,
              maxLines: 1,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  /// One selectable option: the varying route's chip in its OWN color with
  /// the departure inside. Selection is a ring plus full saturation — the
  /// ring space is reserved in both states so pills never resize.
  Widget _optionPill(
    BuildContext context,
    routing.Itinerary option, {
    required int index,
    required bool selected,
    required bool showTime,
    required ColorScheme colorScheme,
    required routing.Leg? variantLeg,
    required routing.Leg? fallbackLeg,
  }) {
    final colorLeg = variantLeg ?? fallbackLeg;
    final color = colorLeg != null
        ? _routeColor(colorLeg.routeColor, colorScheme)
        : colorScheme.primary;
    // Unselected pills blend into the strip, so text contrast must follow
    // the EFFECTIVE fill, not the base route color — deriving it from the
    // base washed white text to ~2:1 on light theme.
    final fill = selected
        ? color
        : Color.alphaBlend(
            color.withValues(alpha: 0.45),
            colorScheme.surfaceContainerHighest,
          );
    final textColor = fill.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    final name = variantLeg?.displayName ?? '';
    final time = showTime ? formatClockTime(context, option.startTime) : null;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        key: ValueKey('itinerary-option-$index'),
        borderRadius: BorderRadius.circular(10),
        onTap: selected
            ? null
            : () {
                HapticFeedback.selectionClick();
                onSelectAlternative!(option);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            // Only the FILL dims on unselected pills: the text keeps
            // full opacity — in a departures-only group the time is the
            // whole decision, and washing it out with the fill hurt
            // dark-theme contrast.
            color: selected ? color : color.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The bus type leads the pill (Sam 2026-08-13: "mostrar el
              // tipo de bus y el nombre").
              if (variantLeg != null) ...[
                Icon(
                  _modeIcon(variantLeg.transportMode),
                  size: 14,
                  color: textColor,
                ),
                if (name.isNotEmpty) const SizedBox(width: 4),
              ],
              if (name.isNotEmpty)
                Text(
                  name,
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              if (name.isNotEmpty && time != null) const SizedBox(width: 6),
              if (time != null)
                Text(
                  time,
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _modeIcon(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.rail:
        return Icons.train_rounded;
      case routing.TransportMode.subway:
        return Icons.subway_rounded;
      case routing.TransportMode.tram:
        return Icons.tram_rounded;
      case routing.TransportMode.ferry:
        return Icons.directions_boat_rounded;
      default:
        return Icons.directions_bus_rounded;
    }
  }

  Color _routeColor(String colorStr, ColorScheme colorScheme) {
    // Empty guard: 'FF' alone parses to a transparent blue and would make
    // the fallback unreachable.
    final parsed = colorStr.isNotEmpty
        ? int.tryParse('FF$colorStr', radix: 16)
        : null;
    return parsed != null ? Color(parsed) : colorScheme.primary;
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    HomeScreenLocalizations l10n,
  ) {
    final duration = itinerary.duration;
    final durationText = duration.inHours > 0
        ? l10n.durationHoursMinutes(
            duration.inHours,
            duration.inMinutes.remainder(60),
          )
        : l10n.durationMinutes(duration.inMinutes);

    // Calculate total walking
    final walkingLegs = itinerary.legs.where(
      (leg) => leg.transportMode == routing.TransportMode.walk,
    );
    final totalWalkingMeters = walkingLegs.fold<int>(
      0,
      (sum, leg) => sum + leg.distance.toInt(),
    );
    final transferCount = itinerary.legs.where((leg) => leg.transitLeg).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Back button, Duration chip, Time range, Go button
          Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onBack?.call();
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),
              // Duration chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  durationText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Time range — hidden when the app pins routing time to
              // a fixed value, since startTime/endTime would be
              // synthetic ("today @ 12:xx") and confuse the user.
              // FittedBox: 12-hour locales overflow this row on ordinary
              // phone widths — scale down instead (same as the card).
              if (context.watch<AppConfiguration?>()?.routingTimeOverride ==
                  null)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatClockTime(context, itinerary.startTime),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          formatClockTime(context, itinerary.endTime),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
              // Go button
              if (onStartNavigation != null)
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onStartNavigation!();
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: Text(l10n.buttonGo),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Distance, Walking, Transfers, CO2
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                // Distance
                Icon(
                  Icons.straighten_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDistance(itinerary.distance, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                // Walking distance
                if (totalWalkingMeters > 0) ...[
                  Icon(
                    Icons.directions_walk_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(totalWalkingMeters, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Transfers
                if (transferCount > 1) ...[
                  Icon(
                    Icons.sync_alt_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${transferCount - 1}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // CO2 emissions
                if (itinerary.emissionsPerPerson != null &&
                    itinerary.emissionsPerPerson! > 0) ...[
                  Icon(Icons.eco_rounded, size: 14, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    l10n.co2Emissions(
                      itinerary.emissionsPerPerson!.toStringAsFixed(0),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(int meters, HomeScreenLocalizations l10n) {
    if (meters < 1000) {
      return l10n.distanceMeters(meters);
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return l10n.distanceKilometers(km);
  }
}

/// Vertical timeline showing all legs with icons on the left.
class _VerticalTimeline extends StatelessWidget {
  final routing.Itinerary itinerary;
  final HomeScreenLocalizations l10n;
  final void Function(String routeCode)? onRouteTap;

  const _VerticalTimeline({
    required this.itinerary,
    required this.l10n,
    this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final legs = itinerary.legs;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          for (int i = 0; i < legs.length; i++) ...[
            // Origin (only first leg)
            if (i == 0)
              _PlaceItem(
                place: legs[i].fromPlace,
                dotColor: const Color(0xFFE91E63),
                isOrigin: true,
                lineColorBelow: _getLegColor(legs[i], colorScheme),
                time: legs[i].fromPlace?.departureTime,
              ),

            // Leg
            _LegItem(
              leg: legs[i],
              l10n: l10n,
              lineColor: _getLegColor(legs[i], colorScheme),
              onRouteTap: onRouteTap,
            ),

            // Destination / Transfer
            _PlaceItem(
              place: legs[i].toPlace,
              dotColor: i == legs.length - 1
                  ? const Color(0xFFE91E63) // Destination
                  : _getLegColor(legs[i + 1], colorScheme), // Transfer
              isDestination: i == legs.length - 1,
              lineColorAbove: _getLegColor(legs[i], colorScheme),
              lineColorBelow: i < legs.length - 1
                  ? _getLegColor(legs[i + 1], colorScheme)
                  : null,
              time: legs[i].toPlace?.arrivalTime,
            ),
          ],
        ],
      ),
    );
  }

  Color _getLegColor(routing.Leg leg, ColorScheme colorScheme) {
    if (leg.transportMode == routing.TransportMode.walk ||
        leg.transportMode == routing.TransportMode.bicycle) {
      return colorScheme.outlineVariant;
    }
    if (leg.routeColor.isNotEmpty) {
      final parsed = int.tryParse('FF${leg.routeColor}', radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return _getModeColor(leg.transportMode);
  }

  Color _getModeColor(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.bus:
        return const Color(0xFFE91E63);
      case routing.TransportMode.rail:
      case routing.TransportMode.subway:
        return const Color(0xFF4CAF50);
      case routing.TransportMode.tram:
        return const Color(0xFFFF5722);
      case routing.TransportMode.ferry:
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF2196F3);
    }
  }
}

/// Place item (origin, transfer, or destination).
class _PlaceItem extends StatelessWidget {
  final routing.Place? place;
  final Color dotColor;
  final bool isOrigin;
  final bool isDestination;
  final Color? lineColorAbove;
  final Color? lineColorBelow;
  final DateTime? time;

  const _PlaceItem({
    required this.place,
    required this.dotColor,
    this.isOrigin = false,
    this.isDestination = false,
    this.lineColorAbove,
    this.lineColorBelow,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Icon column (empty for places)
        const SizedBox(width: 32),
        // Timeline column - use Icon for destination, CustomPaint for others
        SizedBox(
          width: 20,
          height: 32,
          child: isDestination
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Line above
                    if (lineColorAbove != null)
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 4,
                          height: 10,
                          color: lineColorAbove,
                        ),
                      ),
                    // Pin icon
                    Icon(Icons.location_on, size: 20, color: dotColor),
                  ],
                )
              : CustomPaint(
                  painter: _DotLinePainter(
                    dotColor: dotColor,
                    lineColorAbove: lineColorAbove,
                    lineColorBelow: lineColorBelow,
                    isOrigin: isOrigin,
                    isDestination: false,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        // Place name
        Expanded(
          child: Text(
            place?.name ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Time — hidden when the routing time is overridden, since
        // the value would be from a synthetic "midday" plan.
        if (time != null &&
            context.watch<AppConfiguration?>()?.routingTimeOverride == null)
          Text(
            formatClockTime(context, time!),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Custom painter for dot and lines.
class _DotLinePainter extends CustomPainter {
  final Color dotColor;
  final Color? lineColorAbove;
  final Color? lineColorBelow;
  final bool isOrigin;
  final bool isDestination;

  _DotLinePainter({
    required this.dotColor,
    this.lineColorAbove,
    this.lineColorBelow,
    this.isOrigin = false,
    this.isDestination = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const lineWidth = 4.0;
    const dotRadius = 6.0;

    // Line above
    if (lineColorAbove != null) {
      final paint = Paint()
        ..color = lineColorAbove!
        ..strokeWidth = lineWidth;
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, centerY - dotRadius),
        paint,
      );
    }

    // Line below
    if (lineColorBelow != null) {
      final paint = Paint()
        ..color = lineColorBelow!
        ..strokeWidth = lineWidth;
      canvas.drawLine(
        Offset(centerX, centerY + dotRadius),
        Offset(centerX, size.height),
        paint,
      );
    }

    // Dot
    if (isOrigin) {
      // Origin: outlined circle
      final paint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);
    } else if (isDestination) {
      // Destination: filled circle with border
      final fillPaint = Paint()..color = dotColor;
      final borderPaint = Paint()
        ..color = dotColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, fillPaint);
      canvas.drawCircle(Offset(centerX, centerY), dotRadius + 2, borderPaint);
    } else {
      // Transfer: filled circle
      final paint = Paint()..color = dotColor;
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Leg item (walking or transit).
class _LegItem extends StatefulWidget {
  final routing.Leg leg;
  final HomeScreenLocalizations l10n;
  final Color lineColor;
  final void Function(String routeCode)? onRouteTap;

  const _LegItem({
    required this.leg,
    required this.l10n,
    required this.lineColor,
    this.onRouteTap,
  });

  @override
  State<_LegItem> createState() => _LegItemState();
}

class _LegItemState extends State<_LegItem> {
  bool _isExpanded = false;
  bool _isNavigating = false;

  void _handleRouteTap() {
    if (_isNavigating) return;
    final routeCode = widget.leg.tripPatternId ?? widget.leg.route?.id ?? '';
    if (routeCode.isEmpty) return;

    _isNavigating = true;
    HapticFeedback.lightImpact();
    widget.onRouteTap!(routeCode);

    // Reset after a delay to allow navigation to complete
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final leg = widget.leg;
    final isWalk = leg.transportMode == routing.TransportMode.walk;
    final isBike = leg.transportMode == routing.TransportMode.bicycle;
    final hasStops =
        leg.intermediatePlaces != null && leg.intermediatePlaces!.isNotEmpty;
    final stopsCount = leg.intermediatePlaces?.length ?? 0;

    // IntrinsicHeight + stretch lets the timeline line grow with the
    // content. Without it the line had a fixed height and visibly
    // ended mid-leg when extra rows (expanded service hours, stops
    // count) pushed the leg content below 90px.
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon (only for walking/biking) — fixed-size, top-aligned.
              SizedBox(
                width: 32,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 24,
                    child: (isWalk || isBike)
                        ? Icon(
                            _getModeIcon(leg.transportMode),
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),
              ),
              // Timeline line — stretches vertically with the row.
              SizedBox(
                width: 20,
                child: Center(
                  child: Container(
                    width: 4,
                    color: (isWalk || isBike)
                        ? widget.lineColor.withValues(alpha: 0.5)
                        : widget.lineColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Leg content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: _buildLegContent(
                    theme,
                    colorScheme,
                    isWalk,
                    isBike,
                    hasStops,
                    stopsCount,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Expanded stops
        if (_isExpanded && hasStops) _buildExpandedStops(theme, colorScheme),
      ],
    );
  }

  Widget _buildLegContent(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isWalk,
    bool isBike,
    bool hasStops,
    int stopsCount,
  ) {
    final leg = widget.leg;
    final durationText = _formatDuration(leg.duration);
    final distanceText = _formatDistance(leg.distance.toInt());

    if (isWalk || isBike) {
      // Walking/biking: simple text
      return Text(
        '${isWalk ? widget.l10n.walk : widget.l10n.bike} $durationText ($distanceText)',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Title: corridor descriptor (e.g. "Trufi 134"). Falls back to the
    // headsign when no route_long_name is set on the leg.
    final routeName = leg.routeLongName ?? leg.headsign;
    // Subtitle: route variant ("Verde", "Bandera Roja") when distinct
    // from the title. Surfaces the OSM `description` of the trip for
    // feeds where multiple branches share a route_short_name. Skipped
    // when headsign equals the title (already shown above).
    final routeVariant =
        (leg.headsign != null &&
            leg.headsign!.isNotEmpty &&
            leg.headsign != routeName)
        ? leg.headsign
        : null;

    final badgeTextColor = widget.lineColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    // The whole identity (badge + name + variant + chevron) is a
    // single tap target that opens the route detail screen. The
    // chevron at the end is an explicit affordance — without it the
    // tappable area looked like static metadata. The "stops count" on
    // the right is intentionally outside this InkWell because it
    // toggles inline expansion, a different action.
    final identityRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Route badge with icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: widget.lineColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getModeIcon(leg.transportMode),
                size: 14,
                color: badgeTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                leg.displayName,
                style: TextStyle(
                  color: badgeTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Live indicator: pulses when a live vehicle is reported for
        // this leg's route. Only visible if a RealtimeVehiclesProvider
        // is wired.
        Builder(
          builder: (context) {
            final realtime = context.watch<RealtimeVehiclesProvider?>();
            if (realtime == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: LiveBusBadge.whenLive(
                provider: realtime,
                leg: leg,
                color: widget.lineColor,
                size: 12,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        // Route name + (optional) variant inline. Mirrors the
        // identity layout used in the transit list (TransportTile)
        // and the route detail header — `routeLongName` first,
        // headsign as a tinted suffix after a "·" separator when
        // it carries a distinct branch label.
        if (routeName != null)
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: routeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (routeVariant != null)
                    TextSpan(
                      text: '  ·  $routeVariant',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              // Wrap to a second line when the variant is long
              // (e.g. "Panter blanco: bandera roja"); ellipsize
              // beyond that. Keeps short cases on one line and
              // long ones legible without crashing the layout.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );

    // Transit leg - badge on first row, info below
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row: identity (tappable, full width). The "stops count"
        // toggle used to live here, but it created a visual inconsistency
        // — placing it on the same line as the route name made it look
        // like part of the identity. It now sits below the operating
        // hours, in document order, as just another expand control.
        widget.onRouteTap != null
            ? InkWell(
                onTap: _handleRouteTap,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: identityRow,
                ),
              )
            : identityRow,
        // Second row: duration and distance below the identity, so
        // the route name reads as the primary label and the trip
        // metrics sit underneath as secondary information (mirrors
        // how the search list and detail header are stacked).
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '$durationText, $distanceText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Third row: live operating-hours indicator (only when the
        // local planner has populated `serviceHours` from the bundled
        // GTFS — OTP providers don't expose calendar+frequencies via
        // their public APIs, so this row is silently skipped there).
        if (leg.serviceHours != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: routing.ServiceHoursIndicator(
              serviceHours: leg.serviceHours!,
            ),
          ),
        // Fourth row: stops count toggle, right-aligned. Same expand
        // pattern as the operating-hours indicator above — tap flips
        // the chevron and reveals the stop list inline. Aligned right
        // so it doesn't compete with the leg's left-anchored content
        // (route name, duration, hours).
        if (hasStops)
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isExpanded = !_isExpanded);
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$stopsCount ${widget.l10n.stops}',
                      style: TextStyle(
                        color: _legibleColor(widget.lineColor),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 16,
                      color: _legibleColor(widget.lineColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Third row: Agency info (if available)
        if (leg.agency?.name != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              widget.l10n.operatedBy(leg.agency!.name!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        // Fourth row: Fare link (if available)
        if (leg.agency?.fareUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () {
                // TODO: Launch URL
                HapticFeedback.lightImpact();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.l10n.viewFares,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedStops(ThemeData theme, ColorScheme colorScheme) {
    final stops = widget.leg.intermediatePlaces!;

    return Column(
      children: [
        for (final stop in stops)
          SizedBox(
            height: 28,
            child: Row(
              children: [
                // Icon column (empty)
                const SizedBox(width: 32),
                // Timeline line with small dot
                SizedBox(
                  width: 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vertical line
                      Container(
                        width: 4,
                        color: widget.lineColor.withValues(alpha: 0.3),
                      ),
                      // Small bullet
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.lineColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Stop name
                Expanded(
                  child: Text(
                    stop.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Time — hidden under routing time override (synthetic).
                if (stop.arrivalTime != null &&
                    context.watch<AppConfiguration?>()?.routingTimeOverride ==
                        null)
                  Text(
                    formatClockTime(context, stop.arrivalTime!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getModeIcon(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.walk:
        return Icons.directions_walk_rounded;
      case routing.TransportMode.bicycle:
        return Icons.directions_bike_rounded;
      case routing.TransportMode.bus:
        return Icons.directions_bus_rounded;
      case routing.TransportMode.rail:
        return Icons.train_rounded;
      case routing.TransportMode.subway:
        return Icons.subway_rounded;
      case routing.TransportMode.tram:
        return Icons.tram_rounded;
      case routing.TransportMode.ferry:
        return Icons.directions_boat_rounded;
      default:
        return Icons.directions_transit_rounded;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return widget.l10n.durationHoursMinutes(hours, minutes);
    }
    return widget.l10n.durationMinutes(minutes);
  }

  String _formatDistance(int meters) {
    if (meters < 1000) {
      return widget.l10n.distanceMeters(meters);
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return widget.l10n.distanceKilometers(km);
  }
}

/// Screen showing detailed information about an itinerary (full screen).
class ItineraryDetailScreen extends StatelessWidget {
  final routing.Itinerary itinerary;
  final VoidCallback? onStartNavigation;
  final void Function(String routeCode)? onRouteTap;

  const ItineraryDetailScreen({
    super.key,
    required this.itinerary,
    this.onStartNavigation,
    this.onRouteTap,
  });

  /// Shows the itinerary detail screen with a slide transition.
  static Future<void> show(
    BuildContext context, {
    required routing.Itinerary itinerary,
    VoidCallback? onStartNavigation,
    void Function(String routeCode)? onRouteTap,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ItineraryDetailScreen(
              itinerary: itinerary,
              onStartNavigation: onStartNavigation,
              onRouteTap: onRouteTap,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);

    final duration = itinerary.duration;
    final durationText = duration.inHours > 0
        ? l10n.durationHoursMinutes(
            duration.inHours,
            duration.inMinutes.remainder(60),
          )
        : l10n.durationMinutes(duration.inMinutes);

    // Calculate total walking
    final walkingLegs = itinerary.legs.where(
      (leg) => leg.transportMode == routing.TransportMode.walk,
    );
    final totalWalkingMinutes = walkingLegs.fold<int>(
      0,
      (sum, leg) => sum + leg.duration.inMinutes,
    );
    final totalWalkingMeters = walkingLegs.fold<int>(
      0,
      (sum, leg) => sum + leg.distance.toInt(),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 20,
              color: colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              durationText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.directions_walk_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text(
                  l10n.durationMinutes(totalWalkingMinutes),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDistance(totalWalkingMeters, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: _VerticalTimeline(
          itinerary: itinerary,
          l10n: l10n,
          onRouteTap: onRouteTap,
        ),
      ),
    );
  }

  String _formatDistance(int meters, HomeScreenLocalizations l10n) {
    if (meters < 1000) {
      return l10n.distanceMeters(meters);
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return l10n.distanceKilometers(km);
  }
}
