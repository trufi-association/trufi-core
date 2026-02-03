import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../../l10n/home_screen_localizations.dart';

/// Shows the routing settings bottom sheet.
/// Returns `true` if the user tapped "Apply" to confirm changes.
Future<bool?> showRoutingSettingsSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const RoutingSettingsSheet(),
  );
}

/// Bottom sheet for configuring routing preferences.
class RoutingSettingsSheet extends StatelessWidget {
  const RoutingSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.routeSettings,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final manager = RoutingPreferencesManager.maybeRead(context);
                    manager?.reset();
                    HapticFeedback.lightImpact();
                  },
                  child: Text(l10n.buttonReset),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accessibility section
                  const _AccessibilitySection(),
                  const SizedBox(height: 24),
                  // Walk speed section
                  const _WalkSpeedSection(),
                  const SizedBox(height: 24),
                  // Max walk distance section
                  const _MaxWalkDistanceSection(),
                  const SizedBox(height: 24),
                  // Transport modes section
                  const _TransportModesSection(),
                ],
              ),
            ),
          ),
          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.buttonApply),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Accessibility toggle section.
class _AccessibilitySection extends StatelessWidget {
  const _AccessibilitySection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final manager = RoutingPreferencesManager.maybeWatch(context);

    if (manager == null) return const SizedBox.shrink();

    final l10n = HomeScreenLocalizations.of(context);

    return _SettingsCard(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Icon(
              Icons.accessible_rounded,
              color: manager.wheelchair ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(l10n.wheelchairAccessible),
          ],
        ),
        subtitle: Text(
          manager.wheelchair
              ? l10n.wheelchairAccessibleOn
              : l10n.wheelchairAccessibleOff,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        value: manager.wheelchair,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          manager.setWheelchair(value);
        },
      ),
    );
  }
}

/// Walk speed selection section.
class _WalkSpeedSection extends StatelessWidget {
  const _WalkSpeedSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final manager = RoutingPreferencesManager.maybeWatch(context);

    if (manager == null) return const SizedBox.shrink();

    final l10n = HomeScreenLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_walk_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.walkingSpeed,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: WalkSpeedLevel.values.map((level) {
            final isSelected = manager.walkSpeedLevel == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level != WalkSpeedLevel.fast ? 8 : 0,
                ),
                child: _SpeedChip(
                  label: _getSpeedLabel(level, l10n),
                  icon: _getSpeedIcon(level),
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    manager.setWalkSpeedLevel(level);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getSpeedLabel(WalkSpeedLevel level, HomeScreenLocalizations l10n) {
    switch (level) {
      case WalkSpeedLevel.slow:
        return l10n.speedSlow;
      case WalkSpeedLevel.normal:
        return l10n.speedNormal;
      case WalkSpeedLevel.fast:
        return l10n.speedFast;
    }
  }

  IconData _getSpeedIcon(WalkSpeedLevel level) {
    switch (level) {
      case WalkSpeedLevel.slow:
        return Icons.elderly_rounded;
      case WalkSpeedLevel.normal:
        return Icons.directions_walk_rounded;
      case WalkSpeedLevel.fast:
        return Icons.directions_run_rounded;
    }
  }
}

/// Speed selection chip.
class _SpeedChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeedChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Max walk distance section.
class _MaxWalkDistanceSection extends StatelessWidget {
  const _MaxWalkDistanceSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);
    final manager = RoutingPreferencesManager.maybeWatch(context);

    if (manager == null) return const SizedBox.shrink();

    final distances = <double?>[null, 300, 500, 800, 1000, 1500];
    final currentDistance = manager.maxWalkDistance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.straighten_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.maxWalkDistance,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: distances.map((distance) {
            final isSelected = currentDistance == distance;
            return _DistanceChip(
              distance: distance,
              noLimitLabel: l10n.noLimit,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                manager.setMaxWalkDistance(distance);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Distance selection chip.
class _DistanceChip extends StatelessWidget {
  final double? distance;
  final String noLimitLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _DistanceChip({
    required this.distance,
    required this.noLimitLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final label = distance == null
        ? noLimitLabel
        : distance! >= 1000
            ? '${(distance! / 1000).toStringAsFixed(1)} km'
            : '${distance!.toInt()} m';

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Transport modes selection section.
class _TransportModesSection extends StatelessWidget {
  const _TransportModesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);
    final manager = RoutingPreferencesManager.maybeWatch(context);

    if (manager == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.commute_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.transportModes,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TransportModeChip(
              mode: RoutingMode.transit,
              icon: Icons.directions_bus_rounded,
              label: l10n.modeTransit,
              isSelected: manager.transportModes.contains(RoutingMode.transit),
              onTap: () {
                HapticFeedback.selectionClick();
                manager.toggleTransportMode(RoutingMode.transit);
              },
            ),
            _TransportModeChip(
              mode: RoutingMode.walk,
              icon: Icons.directions_walk_rounded,
              label: l10n.walk,
              isSelected: manager.transportModes.contains(RoutingMode.walk),
              onTap: () {
                HapticFeedback.selectionClick();
                manager.toggleTransportMode(RoutingMode.walk);
              },
            ),
            _TransportModeChip(
              mode: RoutingMode.bicycle,
              icon: Icons.directions_bike_rounded,
              label: l10n.modeBicycle,
              isSelected: manager.transportModes.contains(RoutingMode.bicycle),
              onTap: () {
                HapticFeedback.selectionClick();
                manager.toggleTransportMode(RoutingMode.bicycle);
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Transport mode selection chip.
class _TransportModeChip extends StatelessWidget {
  final RoutingMode mode;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransportModeChip({
    required this.mode,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings card container.
class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }
}
