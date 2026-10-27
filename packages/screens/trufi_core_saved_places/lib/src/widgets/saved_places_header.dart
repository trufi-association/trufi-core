import 'package:flutter/material.dart';

/// Header of this package's list screens (Your Places, Your Routes): the
/// hamburger, the title and an optional trailing action — the same row the
/// fares, settings and transport list screens draw.
class SavedPlacesHeader extends StatelessWidget {
  const SavedPlacesHeader({
    super.key,
    required this.title,
    required this.onMenuPressed,
    this.action,
  });

  final String title;
  final VoidCallback onMenuPressed;

  /// Trailing 48 × 48 button, typically a [SavedPlacesHeaderAction]; null
  /// ends the row with the title.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onMenuPressed,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// The header's tonal action (the "+" of Your Places): 48 × 48 on
/// primaryContainer, radius 14.
class SavedPlacesHeaderAction extends StatelessWidget {
  const SavedPlacesHeaderAction({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 24),
        ),
      ),
    );
  }
}
