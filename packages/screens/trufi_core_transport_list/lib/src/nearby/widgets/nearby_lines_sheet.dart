import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/services.dart';
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show RouteBadge;
import 'package:trufi_core_utils/trufi_core_utils.dart' show safeNumberFormat;

import '../../../l10n/transport_list_localizations.dart';
import '../../models/transport_route.dart' show gtfsRouteTypeIcon;
import '../../widgets/route_count_indicator.dart';
import '../../widgets/transport_list_states.dart';
import '../nearby_line.dart';
import '../nearby_lines_cubit.dart';
import '../nearby_lines_data_source.dart';
import '../nearby_radius.dart';

/// "75 m" in the rider's locale (grouping separator, unit string), through
/// [safeNumberFormat] so locales intl has no symbols for (Quechua) still
/// render instead of throwing.
String formatNearbyMeters(BuildContext context, double meters) {
  final l10n = TransportListLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  return l10n.distanceMeters(
    safeNumberFormat('#,##0', locale).format(meters.round()),
  );
}

extension NearbyRadiusLabel on NearbyRadius {
  /// "300 m (8)": the bracket and how many lines fall inside it.
  String chipLabel(TransportListLocalizations l10n, int count) =>
      l10n.nearbyRadiusChip(meters.round(), count);
}

/// Content of the nearby-lines sheet (phone) or side panel (wide), in the
/// routes list's language: the count pill, the radius pills, the GTFS note
/// and the rows for the selected radius (or the matching loading / empty /
/// error state). The screen title lives in the floating header, not here.
///
/// The highlighted line is the row with the primary border, like the home
/// screen's selected itinerary card, and the list keeps it in view the way
/// the home screen's results sheet does (#1055): it scrolls just enough for
/// the row to be whole when the highlight changes (a label tapped on the
/// map), when a new query keeps it (a moved pin, a revisit), when the list
/// is built with it already set (a revisit, the phone / side-panel swap)
/// and when the screen comes back to the front (after a line's detail).
/// A highlighted line beyond the selected radius gets its row after the
/// others, so the list always shows what the map highlights.
class NearbyLinesSheet extends StatefulWidget {
  const NearbyLinesSheet({
    super.key,
    required this.state,
    this.scrollController,
    required this.onRadiusChanged,
    required this.onLineTap,
    required this.onLineDetails,
    this.onRetry,
  });

  final NearbyLinesState state;

  /// The draggable sheet's controller; null in the side panel.
  final ScrollController? scrollController;
  final ValueChanged<NearbyRadius> onRadiusChanged;

  /// A tap on a row: highlights its line, or clears the highlight when the
  /// row already wears it.
  final ValueChanged<NearbyLine> onLineTap;
  final ValueChanged<NearbyLine> onLineDetails;

  /// Re-runs the query after an error; null hides the retry button.
  final VoidCallback? onRetry;

  /// The rows the list shows: the lines within the radius and, after them,
  /// the highlighted line when it lies beyond (a label tapped outside the
  /// ring, or a radius narrowed under it). Nearest first, so the extra row
  /// keeps the order.
  static List<NearbyLine> rowsOf(NearbyLinesState state) {
    final visible = state.visibleLines;
    final selected = state.selectedLine;
    if (selected == null || selected.isWithin(state.radius)) return visible;
    return [...visible, selected];
  }

  @override
  State<NearbyLinesSheet> createState() => _NearbyLinesSheetState();
}

class _NearbyLinesSheetState extends State<NearbyLinesSheet> {
  /// The home screen's reveal: short, decelerating (#1055).
  static const Duration _revealDuration = Duration(milliseconds: 200);

  /// A row not built yet is reached in a few hops at most (see [_reveal]).
  static const int _revealHops = 4;
  static const double _rowGap = 12;

  /// One stable key per line, to find the highlighted row's render box.
  final Map<String, GlobalKey> _rowKeys = {};

  /// The rows of the last build (empty while a state replaces the list),
  /// to know where a row that is not built yet sits.
  List<NearbyLine> _rows = const [];

  /// Whether this screen's route was on top the last time it was checked.
  bool? _routeWasCurrent;

  /// Bumped by every reveal, so an older one still in flight gives way.
  int _revealToken = 0;

  /// What the system bars cover at the bottom of the list: the phone sheet
  /// runs under the navigation bar, while the side panel's SafeArea has
  /// already taken it out. Read on build.
  double _bottomInset = 0;

  GlobalKey _rowKey(String lineKey) =>
      _rowKeys.putIfAbsent(lineKey, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    // Built with a highlight already set: a revisit (the cubit outlives
    // the screen) or the swap between the phone sheet and the side panel.
    if (widget.state.selectedLineKey != null) _scheduleReveal();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Back from a screen pushed on top (a line's detail): the list may
    // have been scrolled away from the highlighted row meanwhile.
    final isCurrent = ModalRoute.isCurrentOf(context) ?? true;
    if (_routeWasCurrent == false &&
        isCurrent &&
        widget.state.selectedLineKey != null) {
      _scheduleReveal();
    }
    _routeWasCurrent = isCurrent;
  }

  @override
  void didUpdateWidget(NearbyLinesSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = widget.state.selectedLineKey;
    if (selected == null) return;
    // A new highlight, or new rows that kept it (a new query). A radius
    // change keeps the rows and the scroll: the rider is at the pills.
    if (selected != oldWidget.state.selectedLineKey ||
        !identical(widget.state.lines, oldWidget.state.lines)) {
      _scheduleReveal();
    }
  }

  void _scheduleReveal() {
    final token = ++_revealToken;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _reveal(token, _revealHops),
    );
  }

  /// Scrolls just enough for the highlighted row to be whole inside the
  /// viewport: the home screen's rule for its selected card (#1055). The
  /// list is lazy, so a row far from the viewport has no render box yet:
  /// the list first moves to where the row must be, measured from the
  /// nearest row that is built, and tries again once it is laid out.
  Future<void> _reveal(int token, int hopsLeft) async {
    if (!mounted || token != _revealToken) return;
    final selected = widget.state.selectedLineKey;
    if (selected == null) return;
    final index = _rows.indexWhere((line) => line.lineKey == selected);
    if (index == -1) return;

    final rowContext = _rowKeys[selected]?.currentContext;
    final row = rowContext?.findRenderObject();
    if (rowContext != null && row is RenderBox && row.hasSize) {
      final viewport = RenderAbstractViewport.maybeOf(row);
      final position = Scrollable.maybeOf(rowContext)?.position;
      if (viewport == null || position == null) return;
      final target = _scrollTarget(
        position,
        top: viewport.getOffsetToReveal(row, 0).offset,
        height: row.size.height,
      );
      if (target == null) return;
      await position.animateTo(
        target,
        duration: _revealDuration,
        curve: Curves.easeOutCubic,
      );
      return;
    }

    if (hopsLeft == 0) return;
    final hop = _hopToward(index);
    if (hop == null) return;
    final (position, offset) = hop;
    await position.animateTo(
      offset,
      duration: _revealDuration,
      curve: Curves.easeOutCubic,
    );
    await WidgetsBinding.instance.endOfFrame;
    return _reveal(token, hopsLeft - 1);
  }

  /// The offset that makes a row whole between the viewport's top edge and
  /// its bottom edge less [_bottomInset], with as little scrolling as
  /// possible: a row below rests just above that line, a row above on the
  /// top edge, and a row taller than the room shows its top. Null when the
  /// row already is whole. [top] is the offset that puts the row's top on
  /// the viewport's top edge.
  double? _scrollTarget(
    ScrollPosition position, {
    required double top,
    required double height,
  }) {
    final bottom = math.min(
      top + height - position.viewportDimension + _bottomInset,
      top,
    );
    final pixels = position.pixels;
    final target = pixels > top
        ? top
        : pixels < bottom
        ? bottom
        : null;
    return target?.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  /// The offset that brings row [index] in, measured from the built row
  /// nearest to it: the rows share one height (a one-line title and a
  /// one-line subtitle). Null when no row is built.
  (ScrollPosition, double)? _hopToward(int index) {
    BuildContext? anchorContext;
    RenderBox? anchorBox;
    var anchorIndex = -1;
    for (var i = 0; i < _rows.length; i++) {
      final context = _rowKeys[_rows[i].lineKey]?.currentContext;
      final box = context?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      if (anchorBox == null ||
          (i - index).abs() < (anchorIndex - index).abs()) {
        anchorContext = context;
        anchorBox = box;
        anchorIndex = i;
      }
    }
    if (anchorContext == null || anchorBox == null) return null;
    final viewport = RenderAbstractViewport.maybeOf(anchorBox);
    final position = Scrollable.maybeOf(anchorContext)?.position;
    if (viewport == null || position == null) return null;

    final height = anchorBox.size.height;
    final top =
        viewport.getOffsetToReveal(anchorBox, 0).offset +
        (index - anchorIndex) * (height + _rowGap);
    final target = _scrollTarget(position, top: top, height: height);
    return target == null ? null : (position, target);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = TransportListLocalizations.of(context);
    _bottomInset = MediaQuery.paddingOf(context).bottom;
    final available = state.availability == NearbyAvailability.available;
    final visible = state.visibleLines;
    // Like the routes list: the count only heads an actual list of rows.
    final showCount =
        available &&
        state.errorMessage == null &&
        !state.isLoading &&
        visible.isNotEmpty;

    // A drag by the rider takes over: a reveal still under way (a hop
    // toward a row not built yet) gives way instead of cancelling it.
    return NotificationListener<ScrollStartNotification>(
      onNotification: (notification) {
        if (notification.dragDetails != null) _revealToken++;
        return false;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        primary: widget.scrollController == null ? false : null,
        slivers: [
          if (showCount)
            SliverToBoxAdapter(
              child: RouteCountIndicator(
                icon: Icons.radar_rounded,
                label: l10n.nearbyLinesInRadius(
                  visible.length,
                  state.radius.meters.round(),
                ),
              ),
            ),
          if (available) ...[
            SliverToBoxAdapter(
              child: _RadiusChips(
                radius: state.radius,
                counts: state.counts,
                onRadiusChanged: widget.onRadiusChanged,
              ),
            ),
            SliverToBoxAdapter(child: _InfoRow(text: l10n.nearbyFooterNote)),
          ],
          ..._buildBody(l10n),
        ],
      ),
    );
  }

  /// First matching state wins; the order is the order a rider can hit them.
  /// Also records the rows shown, for [_reveal].
  List<Widget> _buildBody(TransportListLocalizations l10n) {
    final state = widget.state;
    _rows = const [];
    if (state.isLoading && state.availability == NearbyAvailability.loading) {
      return [_boxed(TransportLoadingState(message: l10n.nearbyLoadingData))];
    }
    if (state.availability == NearbyAvailability.missing) {
      return [
        _boxed(
          TransportEmptyState(
            icon: Icons.cloud_off_rounded,
            title: l10n.nearbyUnavailableTitle,
            hint: l10n.nearbyUnavailableHint,
          ),
        ),
      ];
    }
    final error = state.errorMessage;
    if (error != null) {
      return [
        _boxed(
          TransportLoadErrorState(
            message: l10n.errorLoadingRoutes,
            hint: error,
            retryLabel: l10n.retry,
            onRetry: widget.onRetry,
          ),
        ),
      ];
    }
    if (state.isLoading) {
      return [_boxed(TransportLoadingState(message: l10n.nearbyLoadingData))];
    }
    if (state.lines.isEmpty) {
      return [
        _boxed(
          TransportEmptyState(
            icon: Icons.near_me_disabled_rounded,
            title: l10n.nearbyEmptyTitle(NearbyRadius.maxMeters.round()),
            hint: l10n.nearbyMovePinHint,
          ),
        ),
      ];
    }
    final rows = _rows = NearbyLinesSheet.rowsOf(state);
    // Keys of lines a new query dropped would only pile up.
    final shown = {for (final line in rows) line.lineKey};
    _rowKeys.removeWhere((lineKey, _) => !shown.contains(lineKey));
    return [
      // Nothing within the radius: say so, above the highlighted line's
      // row when the highlight lies beyond.
      if (state.visibleLines.isEmpty)
        _boxed(
          TransportEmptyState(
            icon: Icons.radar_rounded,
            title: l10n.nearbyEmptyInRadius(state.radius.meters.round()),
          ),
        ),
      if (rows.isNotEmpty)
        SliverPadding(
          // Room for the last row to clear the navigation bar too.
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + _bottomInset),
          sliver: SliverList.separated(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final line = rows[index];
              return KeyedSubtree(
                key: _rowKey(line.lineKey),
                child: NearbyLineTile(
                  line: line,
                  isSelected: line.lineKey == state.selectedLineKey,
                  isInsideRadius: line.isWithin(state.radius),
                  onTap: () => widget.onLineTap(line),
                  onDetails: () => widget.onLineDetails(line),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: _rowGap),
          ),
        ),
    ];
  }

  /// A state widget as a sliver, with room above and below: the states are
  /// built for a bounded body and centre themselves there, while a sheet
  /// gives them no height to centre in.
  Widget _boxed(Widget child) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: child,
    ),
  );
}

class _RadiusChips extends StatelessWidget {
  const _RadiusChips({
    required this.radius,
    required this.counts,
    required this.onRadiusChanged,
  });

  final NearbyRadius radius;
  final Map<NearbyRadius, int> counts;
  final ValueChanged<NearbyRadius> onRadiusChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = TransportListLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final candidate in NearbyRadius.values)
            NearbyRadiusPill(
              label: candidate.chipLabel(l10n, counts[candidate] ?? 0),
              selected: candidate == radius,
              onTap: () {
                HapticFeedback.selectionClick();
                onRadiusChanged(candidate);
              },
            ),
        ],
      ),
    );
  }
}

/// One radius bracket, in the shape of the list's count pill: radius 20,
/// `labelMedium` w600, `primaryContainer` when selected.
class NearbyRadiusPill extends StatelessWidget {
  const NearbyRadiusPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The home screen's info line: a small outlined icon and a `bodySmall`
/// note ("Based on GTFS routes and schedules").
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// One nearby line, with the anatomy of the routes list tile: the color bar,
/// the badge, the line's identity as title, the walk as subtitle and the
/// detail chevron.
class NearbyLineTile extends StatelessWidget {
  const NearbyLineTile({
    super.key,
    required this.line,
    required this.isSelected,
    required this.isInsideRadius,
    required this.onTap,
    required this.onDetails,
  });

  final NearbyLine line;
  final bool isSelected;

  /// Distance in the primary color when inside the selected radius, in the
  /// subtitle's plain color otherwise.
  final bool isInsideRadius;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  static final Map<
    NearbyMatchKind,
    String Function(TransportListLocalizations l10n, String distance)
  >
  _distances = {
    NearbyMatchKind.stop: (l10n, distance) => l10n.nearbyAtDistance(distance),
    NearbyMatchKind.passes: (l10n, distance) =>
        l10n.nearbyPassesAtDistance(distance),
  };

  /// Title: the line's identity, with the routes list's rules
  /// (`route_long_name`, else the headsign, else the short name).
  static String _title(NearbyLine line) {
    if (line.longName.isNotEmpty) return line.longName;
    final headsign = line.headsign;
    if (headsign != null && headsign.isNotEmpty) return headsign;
    return line.displayName;
  }

  /// What follows the distance: the stop reached, or the destination of
  /// the pattern that passes by. Null when there is nothing beyond the
  /// title (a passing line without headsign would only repeat it).
  static String? _place(TransportListLocalizations l10n, NearbyLine line) {
    switch (line.kind) {
      case NearbyMatchKind.stop:
        return l10n.nearbyStopName(line.stopName ?? '');
      case NearbyMatchKind.passes:
        final headsign = line.headsign;
        return headsign != null && headsign.isNotEmpty
            ? l10n.nearbyTowards(headsign)
            : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = TransportListLocalizations.of(context);
    final lineColor = line.color ?? colorScheme.primary;
    final distance = _distances[line.kind]!(
      l10n,
      formatNearbyMeters(context, line.distanceMeters),
    );
    final place = _place(l10n, line);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.3,
    );

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 4,
                height: 72,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  // 2 on the right: the chevron brings its own 6 of tap area.
                  padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                  child: Row(
                    children: [
                      RouteBadge(
                        label: line.displayName,
                        color: lineColor,
                        textColor: line.textColor,
                        // 16 like the icon the routes list gets from
                        // its provider, so the two lists match.
                        icon: Icon(gtfsRouteTypeIcon(line.routeType), size: 16),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _title(line),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_walk_rounded,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                // One text so a tight column trims the
                                // place first and the walk never overflows.
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: distance,
                                          style: subtitleStyle?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isInsideRadius
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        if (place != null)
                                          TextSpan(text: ' · $place'),
                                      ],
                                    ),
                                    style: subtitleStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Chevron: opens the detail (the rest of the tile
                      // toggles the highlight).
                      Tooltip(
                        message: l10n.nearbyOpenDetails,
                        child: InkResponse(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onDetails();
                          },
                          radius: 22,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
