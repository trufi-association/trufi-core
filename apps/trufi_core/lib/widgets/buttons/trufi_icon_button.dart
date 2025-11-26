import 'package:flutter/material.dart';

class TrufiIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isCompact;

  const TrufiIconButton({
    super.key,
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
        padding: isCompact ? EdgeInsets.all(0) : null,
      ),
    );
  }
}
