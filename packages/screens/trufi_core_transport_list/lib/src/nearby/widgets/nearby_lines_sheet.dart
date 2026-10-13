import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart' show safeNumberFormat;

import '../../../l10n/transport_list_localizations.dart';
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

/// Content of the nearby-lines sheet (phone) or side panel (wide): title,
/// highlight banner, radius chips, the rows for the selected radius (or the
/// matching empty/unavailable state) and the GTFS footer note.
class NearbyLinesSheet extends StatelessWidget {
  const NearbyLinesSheet({
    super.key,
    required this.state,
    this.scrollController,
    required this.onRadiusChanged,
    required this.onLineTap,
    required this.onLineDetails,
    this.onClearSelection,
    this.onClose,
  });

  final NearbyLinesState state;

  /// The draggable sheet's controller; null in the side panel.
  final ScrollController? scrollController;
  final ValueChanged<NearbyRadius> onRadiusChanged;
  final ValueChanged<NearbyLine> onLineTap;
  final ValueChanged<NearbyLine> onLineDetails;
  final VoidCallback? onClearSelection;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = TransportListLocalizations.of(context);
    final selected = state.selectedLine;

    return CustomScrollView(
      controller: scrollController,
      primary: scrollController == null ? false : null,
      slivers: [
        SliverToBoxAdapter(
          child: _SheetHeader(title: l10n.menuNearbyLines, onClose: onClose),
        ),
        if (selected != null)
          SliverToBoxAdapter(
            child: _SelectionBanner(line: selected, onClear: onClearSelection),
          ),
        if (state.availability == NearbyAvailability.available)
          SliverToBoxAdapter(
            child: _RadiusChips(
              radius: state.radius,
              counts: state.counts,
              onRadiusChanged: onRadiusChanged,
            ),
          ),
        _buildBody(context, l10n),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              l10n.nearbyFooterNote,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// First matching state wins; the order is the order a rider can hit them.
  Widget _buildBody(BuildContext context, TransportListLocalizations l10n) {
    if (state.isLoading && state.availability == NearbyAvailability.loading) {
      return SliverToBoxAdapter(
        child: _NearbyMessage(
          icon: Icons.downloading_rounded,
          title: l10n.nearbyLoadingData,
          showSpinner: true,
        ),
      );
    }
    if (state.availability == NearbyAvailability.missing) {
      return SliverToBoxAdapter(
        child: _NearbyMessage(
          icon: Icons.cloud_off_rounded,
          title: l10n.nearbyUnavailableTitle,
          hint: l10n.nearbyUnavailableHint,
        ),
      );
    }
    final error = state.errorMessage;
    if (error != null) {
      return SliverToBoxAdapter(
        child: _NearbyMessage(
          icon: Icons.error_outline_rounded,
          title: l10n.errorLoadingRoutes,
          hint: error,
        ),
      );
    }
    if (state.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (state.lines.isEmpty) {
      return SliverToBoxAdapter(
        child: _NearbyMessage(
          icon: Icons.near_me_disabled_rounded,
          title: l10n.nearbyEmptyTitle(NearbyRadius.maxMeters.round()),
          hint: l10n.nearbyMovePinHint,
        ),
      );
    }
    final visible = state.visibleLines;
    if (visible.isEmpty) {
      return SliverToBoxAdapter(
        child: _NearbyMessage(
          icon: Icons.radar_rounded,
          title: l10n.nearbyEmptyInRadius(state.radius.meters.round()),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        separatorBuilder: (_, _) => const SizedBox(height: 8),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = TransportListLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: l10n.nearbyClose,
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
          child: Row(
            children: [
              _LineBadge(line: line),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.nearbySelectedLine(line.displayName),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
                tooltip: l10n.nearbyClearSelection,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onClear?.call();
                },
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = TransportListLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: [
          for (final candidate in NearbyRadius.values)
            ChoiceChip(
              label: Text(candidate.chipLabel(l10n, counts[candidate] ?? 0)),
              selected: candidate == radius,
              showCheckmark: false,
              selectedColor: colorScheme.primaryContainer,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: candidate == radius
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
              onSelected: (_) {
                HapticFeedback.selectionClick();
                onRadiusChanged(candidate);
              },
            ),
        ],
      ),
    );
  }
}

/// One nearby line: badge, distance, stop or destination, detail chevron.
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

  /// Distance text in the primary color when inside the selected radius
  /// (the green labels of the mock), plain otherwise.
  final bool isInsideRadius;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  static final Map<
    NearbyMatchKind,
    String Function(TransportListLocalizations l10n, String distance)
  >
  _titles = {
    NearbyMatchKind.stop: (l10n, distance) => l10n.nearbyAtDistance(distance),
    NearbyMatchKind.passes: (l10n, distance) =>
        l10n.nearbyPassesAtDistance(distance),
  };

  static final Map<
    NearbyMatchKind,
    String Function(TransportListLocalizations l10n, NearbyLine line)
  >
  _subtitles = {
    NearbyMatchKind.stop: (l10n, line) =>
        l10n.nearbyStopName(line.stopName ?? ''),
    NearbyMatchKind.passes: (l10n, line) {
      final headsign = line.headsign;
      return headsign != null && headsign.isNotEmpty
          ? l10n.nearbyTowards(headsign)
          : line.longName;
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = TransportListLocalizations.of(context);
    final distance = formatNearbyMeters(context, line.distanceMeters);

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              _LineBadge(line: line),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _titles[line.kind]!(l10n, distance),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isInsideRadius
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitles[line.kind]!(l10n, line),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: l10n.nearbyOpenDetails,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDetails();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route number on the route color (theme primary when the feed has none).
class _LineBadge extends StatelessWidget {
  const _LineBadge({required this.line});

  final NearbyLine line;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = line.color ?? colorScheme.primary;
    final foreground = line.textColor ?? nearbyContrastColor(background);
    return Container(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        line.displayName,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Black or white, whichever reads on [background] (the rule of
/// `TransportTile`).
Color nearbyContrastColor(Color background) =>
    background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

class _NearbyMessage extends StatelessWidget {
  const _NearbyMessage({
    required this.icon,
    required this.title,
    this.hint,
    this.showSpinner = false,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hint = this.hint;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
