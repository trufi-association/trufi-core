import 'package:flutter/material.dart';

/// A button for selecting a tab item.
/// ## Properties
/// * `label`: The text displayed on the button.
/// * `isSelected`: Whether the tab is currently selected.
/// * `leadingIcon`: An optional icon to display before the label.
/// * `isVerticalOrientation`:  Whether the layout should be vertical or horizontal.
/// * `onPressed`: A callback function to execute when the button is pressed.
class TabItemButton extends StatelessWidget {
  const TabItemButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isSelected,
    this.leadingIcon,
    this.isVerticalOrientation = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isVerticalOrientation;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashFactory: InkRipple.splashFactory,
        splashColor: theme.colorScheme.primary.withAlpha(31),
        highlightColor: theme.colorScheme.primary.withAlpha(31),
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 14),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: isSelected
                  ? BorderDirectional(
                      bottom: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? theme.colorScheme.primary :  theme.colorScheme.outline,
                    fontWeight: isSelected ? FontWeight.w500 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
