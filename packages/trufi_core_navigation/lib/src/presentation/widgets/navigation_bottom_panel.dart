import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/navigation_localizations.dart';
import '../../models/navigation_state.dart';
import 'navigation_instruction_card.dart';

/// Bottom panel for navigation with instruction card and exit button.
class NavigationBottomPanel extends StatelessWidget {
  final NavigationState state;
  final VoidCallback onExitNavigation;

  /// [NavigationInstructionCard.showStops] of the instruction card (#1059).
  final bool showStops;

  const NavigationBottomPanel({
    super.key,
    required this.state,
    required this.onExitNavigation,
    this.showStops = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction card
          if (state.currentInstruction != null)
            NavigationInstructionCard(
              instruction: state.currentInstruction!,
              nextInstruction: state.nextInstruction,
              remainingStops: state.remainingStops,
              totalStops: state.totalStops,
              currentStopIndex: state.currentStopIndex,
              distanceToNextStop: state.distanceToNextStop,
              etaToDestination: state.etaToDestination,
              isOffRoute: state.isOffRoute,
              isGpsWeak: state.isGpsWeak,
              legs: state.route?.legs ?? [],
              currentLeg: state.currentLeg,
              totalDuration: state.etaToDestination,
              showStops: showStops,
            ),

          // Exit navigation button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  if (await showNavigationExitConfirmation(context) &&
                      context.mounted) {
                    onExitNavigation();
                  }
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(
                  NavigationLocalizations.of(context).navExitNavigation,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks the rider whether to end the navigation: the question of the exit
/// button, and of a back or an external link while the navigation runs
/// (#1065). True when they chose to exit; dismissing the dialog keeps the
/// navigation.
///
/// The dialog goes on the navigation's own navigator, not the app's root
/// one. In an app with a shell (go_router's `ShellRoute`), closing a dialog
/// on the root navigator makes the framework tell Android that it no longer
/// handles back, since the root navigator cannot pop: the next back, after
/// a Cancel, then closed the app and the navigation with it. On the
/// navigation's navigator the question also goes with the screen when a
/// link replaces it, instead of staying behind.
Future<bool> showNavigationExitConfirmation(BuildContext context) async {
  final loc = NavigationLocalizations.of(context);
  final exit = await showDialog<bool>(
    context: context,
    useRootNavigator: false,
    builder: (context) => AlertDialog(
      title: Text(loc.navExitConfirmTitle),
      content: Text(loc.navExitConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(loc.navCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(loc.navExit),
        ),
      ],
    ),
  );
  return exit ?? false;
}

/// Panel shown when navigation is completed.
class NavigationCompletedPanel extends StatelessWidget {
  final String? destinationName;
  final VoidCallback onClose;

  const NavigationCompletedPanel({
    super.key,
    this.destinationName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              NavigationLocalizations.of(context).navArrived,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            if (destinationName != null) ...[
              const SizedBox(height: 8),
              Text(
                destinationName!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onClose();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(NavigationLocalizations.of(context).navClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel shown when there's an error.
class NavigationErrorPanel extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onClose;
  final VoidCallback? onOpenSettings;

  const NavigationErrorPanel({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onClose,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                color: colorScheme.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Error message
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    child: Text(NavigationLocalizations.of(context).navClose),
                  ),
                ),
                const SizedBox(width: 12),
                if (onOpenSettings != null) ...[
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: onOpenSettings,
                      child: Text(
                        NavigationLocalizations.of(context).navSettings,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: onRetry,
                    child: Text(NavigationLocalizations.of(context).navRetry),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
