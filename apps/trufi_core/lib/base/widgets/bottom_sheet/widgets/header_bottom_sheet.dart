import 'package:flutter/material.dart';

/// Header widget for the bottom sheet with title and action buttons.
class HeaderBottomSheet extends StatelessWidget {
  final VoidCallback onClose;
  final String? title;

  const HeaderBottomSheet({
    super.key,
    required this.onClose,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title ?? 'Routes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _TrufiIconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            isCompact: true,
          ),
        ],
      ),
    );
  }
}

class _TrufiIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isCompact;

  const _TrufiIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey.withAlpha(45),
          shape: const CircleBorder(),
          visualDensity: isCompact ? VisualDensity.compact : null,
        ),
        iconSize: isCompact ? 18 : null,
        padding: isCompact ? const EdgeInsets.all(0) : null,
      ),
    );
  }
}
