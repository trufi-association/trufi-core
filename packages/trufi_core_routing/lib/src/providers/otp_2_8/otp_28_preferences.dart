import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simplified walk speed levels for UI.
enum WalkSpeedLevel {
  slow,
  normal,
  fast;

  double get speedValue {
    switch (this) {
      case WalkSpeedLevel.slow:
        return 0.8;
      case WalkSpeedLevel.normal:
        return 1.33;
      case WalkSpeedLevel.fast:
        return 1.8;
    }
  }

  double get reluctanceValue {
    switch (this) {
      case WalkSpeedLevel.slow:
        return 3.5;
      case WalkSpeedLevel.normal:
        return 2.0;
      case WalkSpeedLevel.fast:
        return 1.5;
    }
  }
}

/// Transport modes for routing configuration.
enum RoutingMode {
  walk,
  transit,
  bicycle,
  car;

  String get otpName {
    switch (this) {
      case RoutingMode.walk:
        return 'WALK';
      case RoutingMode.transit:
        return 'TRANSIT';
      case RoutingMode.bicycle:
        return 'BICYCLE';
      case RoutingMode.car:
        return 'CAR';
    }
  }
}

/// Internal preferences state for OTP 2.8 provider.
///
/// Handles its own persistence with SharedPreferences.
class Otp28PreferencesState extends ChangeNotifier {
  static const _key = 'routing_prefs_otp28';

  bool _wheelchair = false;
  double _walkSpeed = 1.33;
  double? _maxWalkDistance = 800;
  double _walkReluctance = 2.0;
  double _bikeSpeed = 5.0;
  Set<RoutingMode> _transportModes = const {
    RoutingMode.transit,
    RoutingMode.walk,
  };
  bool _initialized = false;

  bool get wheelchair => _wheelchair;
  double get walkSpeed => _walkSpeed;
  double? get maxWalkDistance => _maxWalkDistance;
  double get walkReluctance => _walkReluctance;
  double get bikeSpeed => _bikeSpeed;
  Set<RoutingMode> get transportModes => _transportModes;

  WalkSpeedLevel get walkSpeedLevel {
    if (_walkSpeed <= 0.9) return WalkSpeedLevel.slow;
    if (_walkSpeed <= 1.5) return WalkSpeedLevel.normal;
    return WalkSpeedLevel.fast;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    final sp = await SharedPreferences.getInstance();
    final json = sp.getString(_key);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _wheelchair = map['wheelchair'] as bool? ?? false;
        _walkSpeed = (map['walkSpeed'] as num?)?.toDouble() ?? 1.33;
        _maxWalkDistance = (map['maxWalkDistance'] as num?)?.toDouble() ?? 800;
        _walkReluctance = (map['walkReluctance'] as num?)?.toDouble() ?? 2.0;
        _bikeSpeed = (map['bikeSpeed'] as num?)?.toDouble() ?? 5.0;
        _transportModes =
            (map['transportModes'] as List<dynamic>?)
                ?.map(
                  (e) => RoutingMode.values.firstWhere(
                    (m) => m.name == e,
                    orElse: () => RoutingMode.transit,
                  ),
                )
                .toSet() ??
            const {RoutingMode.transit, RoutingMode.walk};
      } catch (_) {}
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _key,
      jsonEncode({
        'wheelchair': _wheelchair,
        'walkSpeed': _walkSpeed,
        'maxWalkDistance': _maxWalkDistance,
        'walkReluctance': _walkReluctance,
        'bikeSpeed': _bikeSpeed,
        'transportModes': _transportModes.map((m) => m.name).toList(),
      }),
    );
  }

  void setWheelchair(bool value) {
    if (_wheelchair == value) return;
    _wheelchair = value;
    if (value) {
      _walkSpeed = 0.8;
      _walkReluctance = 3.0;
      _maxWalkDistance ??= 400;
    }
    _save();
    notifyListeners();
  }

  void setWalkSpeedLevel(WalkSpeedLevel level) {
    if (walkSpeedLevel == level) return;
    _walkSpeed = level.speedValue;
    _walkReluctance = level.reluctanceValue;
    _save();
    notifyListeners();
  }

  void setMaxWalkDistance(double? distance) {
    if (_maxWalkDistance == distance) return;
    _maxWalkDistance = distance;
    _save();
    notifyListeners();
  }

  void setTransportModes(Set<RoutingMode> modes) {
    if (_transportModes == modes) return;
    _transportModes = Set.unmodifiable(modes);
    _save();
    notifyListeners();
  }

  void toggleTransportMode(RoutingMode mode) {
    final modes = Set<RoutingMode>.from(_transportModes);
    if (modes.contains(mode)) {
      if (modes.length > 1) modes.remove(mode);
    } else {
      modes.add(mode);
    }
    setTransportModes(modes);
  }

  void reset() {
    _wheelchair = false;
    _walkSpeed = 1.33;
    _maxWalkDistance = 800;
    _walkReluctance = 2.0;
    _bikeSpeed = 5.0;
    _transportModes = const {RoutingMode.transit, RoutingMode.walk};
    _save();
    notifyListeners();
  }
}

/// Complete preferences UI for OTP 2.8 provider.
class Otp28Preferences extends StatelessWidget {
  final Otp28PreferencesState state;
  final bool showWheelchair;

  const Otp28Preferences({super.key, required this.state, this.showWheelchair = true});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showWheelchair) ...[
              _AccessibilitySection(state: state),
              const SizedBox(height: 24),
            ],
            _WalkSpeedSection(state: state),
            const SizedBox(height: 24),
            _MaxWalkDistanceSection(state: state),
            const SizedBox(height: 24),
            _TransportModesSection(state: state),
          ],
        );
      },
    );
  }
}

// --- Accessibility ---

class _AccessibilitySection extends StatelessWidget {
  final Otp28PreferencesState state;
  const _AccessibilitySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _SettingsCard(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Icon(
              Icons.accessible_rounded,
              color: state.wheelchair
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Wheelchair accessible')),
          ],
        ),
        subtitle: Text(
          state.wheelchair
              ? 'Routes avoid stairs and steep slopes'
              : 'Include all routes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        value: state.wheelchair,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          state.setWheelchair(value);
        },
      ),
    );
  }
}

// --- Walk Speed ---

class _WalkSpeedSection extends StatelessWidget {
  final Otp28PreferencesState state;
  const _WalkSpeedSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              'Walking speed',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: WalkSpeedLevel.values.map((level) {
            final isSelected = state.walkSpeedLevel == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level != WalkSpeedLevel.fast ? 8 : 0,
                ),
                child: _SpeedChip(
                  label: _speedLabel(level),
                  icon: _speedIcon(level),
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    state.setWalkSpeedLevel(level);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static String _speedLabel(WalkSpeedLevel level) {
    switch (level) {
      case WalkSpeedLevel.slow:
        return 'Slow';
      case WalkSpeedLevel.normal:
        return 'Normal';
      case WalkSpeedLevel.fast:
        return 'Fast';
    }
  }

  static IconData _speedIcon(WalkSpeedLevel level) {
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
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
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

// --- Max Walk Distance ---

class _MaxWalkDistanceSection extends StatelessWidget {
  final Otp28PreferencesState state;
  const _MaxWalkDistanceSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final distances = <double?>[null, 300, 500, 800, 1000, 1500];

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
              'Maximum walking distance',
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
            final isSelected = state.maxWalkDistance == distance;
            return _DistanceChip(
              distance: distance,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                state.setMaxWalkDistance(distance);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DistanceChip extends StatelessWidget {
  final double? distance;
  final bool isSelected;
  final VoidCallback onTap;

  const _DistanceChip({
    required this.distance,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final label = distance == null
        ? 'No limit'
        : distance! >= 1000
        ? '${(distance! / 1000).toStringAsFixed(1)} km'
        : '${distance!.toInt()} m';

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
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

// --- Transport Modes ---

class _TransportModesSection extends StatelessWidget {
  final Otp28PreferencesState state;
  const _TransportModesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.commute_rounded, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Transport modes',
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
              icon: Icons.directions_bus_rounded,
              label: 'Transit',
              isSelected: state.transportModes.contains(RoutingMode.transit),
              onTap: () {
                HapticFeedback.selectionClick();
                state.toggleTransportMode(RoutingMode.transit);
              },
            ),
            _TransportModeChip(
              icon: Icons.directions_walk_rounded,
              label: 'Walk',
              isSelected: state.transportModes.contains(RoutingMode.walk),
              onTap: () {
                HapticFeedback.selectionClick();
                state.toggleTransportMode(RoutingMode.walk);
              },
            ),
            _TransportModeChip(
              icon: Icons.directions_bike_rounded,
              label: 'Bicycle',
              isSelected: state.transportModes.contains(RoutingMode.bicycle),
              onTap: () {
                HapticFeedback.selectionClick();
                state.toggleTransportMode(RoutingMode.bicycle);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _TransportModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransportModeChip({
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
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
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

// --- Helpers ---

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
