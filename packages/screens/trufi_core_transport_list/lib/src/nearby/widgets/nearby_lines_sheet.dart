import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show RouteBadge, RouteBadgeVariant;
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
/// routes list's language: the highlight chip, the count pill, the radius
/// pills, the GTFS note and the rows for the selected radius (or the
/// matching loading / empty / error state). The screen title and the close
/// action live in the floating header, not here.
class NearbyLinesSheet extends StatelessWidget {
  const NearbyLinesSheet({
    super.key,
    required this.state,
    this.scrollController,
    required this.onRadiusChanged,
    required this.onLineTap,
    required this.onLineDetails,
    this.onClearSelection,
    this.onRetry,
  });

  final NearbyLinesState state;

  /// The draggable sheet's controller; null in the side panel.
  final ScrollController? scrollController;
  final ValueChanged<NearbyRadius> onRadiusChanged;
  final ValueChanged<NearbyLine> onLineTap;
  final ValueChanged<NearbyLine> onLineDetails;
  final VoidCallback? onClearSelection;

  /// Re-runs the query after an error; null hides the retry button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = TransportListLocalizations.of(context);
    final selected = state.selectedLine;
    final available = state.availability == NearbyAvailability.available;
    final visible = state.visibleLines;
    // Like the routes list: the count only heads an actual list of rows.
    final showCount =
        available &&
        state.errorMessage == null &&
        !state.isLoading &&
        visible.isNotEmpty;

    return CustomScrollView(
      controller: scrollController,
      primary: scrollController == null ? false : null,
      slivers: [
        if (selected != null)
          SliverToBoxAdapter(
            child: _SelectionBanner(line: selected, onClear: onClearSelection),
          ),
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
              onRadiusChanged: onRadiusChanged,
            ),
          ),
          SliverToBoxAdapter(child: _InfoRow(text: l10n.nearbyFooterNote)),
        ],
        _buildBody(context, l10n),
      ],
    );
  }

  /// First matching state wins; the order is the order a rider can hit them.
  Widget _buildBody(BuildContext context, TransportListLocalizations l10n) {
    if (state.isLoading && state.availability == NearbyAvailability.loading) {
      return _boxed(TransportLoadingState(message: l10n.nearbyLoadingData));
    }
    if (state.availability == NearbyAvailability.missing) {
      return _boxed(
        TransportEmptyState(
          icon: Icons.cloud_off_rounded,
          title: l10n.nearbyUnavailableTitle,
          hint: l10n.nearbyUnavailableHint,
        ),
      );
    }
    final error = state.errorMessage;
    if (error != null) {
      return _boxed(
        TransportLoadErrorState(
          message: l10n.errorLoadingRoutes,
          hint: error,
          retryLabel: l10n.retry,
          onRetry: onRetry,
        ),
      );
    }
    if (state.isLoading) {
      return _boxed(TransportLoadingState(message: l10n.nearbyLoadingData));
    }
    if (state.lines.isEmpty) {
      return _boxed(
        TransportEmptyState(
          icon: Icons.near_me_disabled_rounded,
          title: l10n.nearbyEmptyTitle(NearbyRadius.maxMeters.round()),
          hint: l10n.nearbyMovePinHint,
        ),
      );
    }
    final visible = state.visibleLines;
    if (visible.isEmpty) {
      return _boxed(
        TransportEmptyState(
          icon: Icons.radar_rounded,
          title: l10n.nearbyEmptyInRadius(state.radius.meters.round()),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList.separated(
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final line = visible[index];
          return NearbyLineTile(
            line: line,
            isSelected: line.lineKey == state.selectedLineKey,
            isInsideRadius: true,
            onTap: () => onLineTap(line),
            onDetails: () => onLineDetails(line),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
      ),
    );
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

/// The highlighted line in the shape of the routes list's active-filter
/// chip (`secondaryContainer`, radius 20, × to clear), with the line's
/// badge in front of "Highlighted: 201". Hand-built rather than an
/// [InputChip]: a chip sizes its avatar to the label's height, and the
/// 24 px badge trips that assertion. The × gets a 40 px target, which
/// is what sets the chip's height.
class _SelectionBanner extends StatelessWidget {
  const _SelectionBanner({required this.line, required this.onClear});

  final NearbyLine line;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = TransportListLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Flexible(
            child: Material(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RouteBadge(
                      variant: RouteBadgeVariant.chip,
                      label: line.displayName,
                      color: line.color ?? colorScheme.primary,
                      textColor: line.textColor,
                      icon: Icon(gtfsRouteTypeIcon(line.routeType)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.nearbySelectedLine(line.displayName),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: l10n.nearbyClearSelection,
                      child: InkResponse(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onClear?.call();
                        },
                        radius: 20,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
