import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Top bar for navigation screen with route info and controls.
class NavigationTopBar extends StatelessWidget {
  final String routeName;
  final String? routeShortName;
  final Color? routeColor;
  final Color? textColor;
  final Widget? modeIcon;
  final VoidCallback onClose;
  final VoidCallback onRecenter;
  final bool isFollowingUser;

  const NavigationTopBar({
    super.key,
    required this.routeName,
    this.routeShortName,
    this.routeColor,
    this.textColor,
    this.modeIcon,
    required this.onClose,
    required this.onRecenter,
    required this.isFollowingUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveRouteColor = routeColor ?? colorScheme.primary;
    final effectiveTextColor = textColor ?? Colors.white;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Close button
            _buildButton(
              context,
              icon: Icons.close_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                onClose();
              },
            ),
            const SizedBox(width: 12),

            // Route info card
            Expanded(
              child: Material(
                color: colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                elevation: 2,
                shadowColor: Colors.black26,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Route badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: effectiveRouteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (modeIcon != null) ...[
                              IconTheme(
                                data: IconThemeData(
                                    color: effectiveTextColor, size: 16),
                                child: modeIcon!,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              routeShortName ?? routeName,
                              style: TextStyle(
                                color: effectiveTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Route name
                      Expanded(
                        child: Text(
                          routeName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Re-center button
            _buildButton(
              context,
              icon: isFollowingUser
                  ? Icons.my_location_rounded
                  : Icons.location_searching_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                onRecenter();
              },
              isActive: isFollowingUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isActive
          ? colorScheme.primaryContainer
          : colorScheme.surface.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}
