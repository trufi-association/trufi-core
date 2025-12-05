import 'package:flutter/material.dart';

/// A button to swap origin and destination locations.
class SwapButton extends StatelessWidget {
  /// The current orientation to determine icon direction.
  final Orientation orientation;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  const SwapButton({
    super.key,
    required this.orientation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FittedBox(
      child: IconButton(
        icon: Icon(
          orientation == Orientation.portrait
              ? Icons.swap_vert
              : Icons.swap_horiz,
          color: colorScheme.onPrimary,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

/// A button to reset/clear the search.
class ResetButton extends StatelessWidget {
  /// Called when the button is pressed.
  final VoidCallback onPressed;

  const ResetButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FittedBox(
      child: IconButton(
        icon: Icon(
          Icons.clear,
          color: colorScheme.onPrimary,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

/// A menu button typically used to open a drawer.
class MenuButton extends StatelessWidget {
  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// Optional tooltip text.
  final String? tooltip;

  const MenuButton({
    super.key,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        Icons.menu,
        color: colorScheme.onPrimary,
      ),
      splashRadius: 24,
      iconSize: 24,
      onPressed: onPressed,
      tooltip: tooltip ?? MaterialLocalizations.of(context).openAppDrawerTooltip,
    );
  }
}
