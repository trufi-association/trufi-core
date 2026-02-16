import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Internal preferences state for TrufiPlanner provider.
///
/// Only supports max walk distance configuration.
/// Handles its own persistence with SharedPreferences.
class TrufiPlannerPreferencesState extends ChangeNotifier {
  static const _key = 'routing_prefs_trufi_planner';

  double? _maxWalkDistance;
  bool _initialized = false;

  double? get maxWalkDistance => _maxWalkDistance;

  Future<void> initialize() async {
    if (_initialized) return;
    final sp = await SharedPreferences.getInstance();
    final json = sp.getString(_key);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _maxWalkDistance = (map['maxWalkDistance'] as num?)?.toDouble();
      } catch (_) {}
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode({
      'maxWalkDistance': _maxWalkDistance,
    }));
  }

  void setMaxWalkDistance(double? distance) {
    if (_maxWalkDistance == distance) return;
    _maxWalkDistance = distance;
    _save();
    notifyListeners();
  }

  void reset() {
    _maxWalkDistance = null;
    _save();
    notifyListeners();
  }
}

/// Complete preferences UI for TrufiPlanner provider.
///
/// Only supports max walk distance configuration.
class TrufiPlannerPreferences extends StatelessWidget {
  final TrufiPlannerPreferencesState state;

  const TrufiPlannerPreferences({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final distances = <double?>[null, 300, 500, 800, 1000, 1500];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.straighten_rounded,
                    color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Maximum walking distance',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
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
      },
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
          child: Text(label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              )),
        ),
      ),
    );
  }
}
