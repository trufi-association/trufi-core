import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/navigation_state.dart';
import 'navigation_instruction_card.dart';

/// Localized strings for navigation panels.
class NavigationPanelStrings {
  final String exitNavigation;
  final String exitNavigationTitle;
  final String exitNavigationMessage;
  final String buttonCancel;
  final String buttonExit;
  final String buttonClose;
  final String buttonRetry;
  final String buttonSettings;
  final String arrivedMessage;

  const NavigationPanelStrings({
    this.exitNavigation = 'Exit Navigation',
    this.exitNavigationTitle = 'Exit Navigation?',
    this.exitNavigationMessage = 'Are you sure you want to stop navigating this route?',
    this.buttonCancel = 'Cancel',
    this.buttonExit = 'Exit',
    this.buttonClose = 'Close',
    this.buttonRetry = 'Retry',
    this.buttonSettings = 'Settings',
    this.arrivedMessage = 'You have arrived!',
  });
}

/// Bottom panel for navigation with instruction card and exit button.
class NavigationBottomPanel extends StatelessWidget {
  final NavigationState state;
  final VoidCallback onExitNavigation;
  final NavigationPanelStrings strings;

  const NavigationBottomPanel({
    super.key,
    required this.state,
    required this.onExitNavigation,
    this.strings = const NavigationPanelStrings(),
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
            ),

          // Exit navigation button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showExitConfirmation(context);
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(strings.exitNavigation),
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

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.exitNavigationTitle),
        content: Text(strings.exitNavigationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.buttonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onExitNavigation();
            },
            child: Text(strings.buttonExit),
          ),
        ],
      ),
    );
  }
}

/// Panel shown when navigation is completed.
class NavigationCompletedPanel extends StatelessWidget {
  final String? destinationName;
  final VoidCallback onClose;
  final NavigationPanelStrings strings;

  const NavigationCompletedPanel({
    super.key,
    this.destinationName,
    required this.onClose,
    this.strings = const NavigationPanelStrings(),
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
              strings.arrivedMessage,
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
                child: Text(strings.buttonClose),
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
  final NavigationPanelStrings strings;

  const NavigationErrorPanel({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onClose,
    this.onOpenSettings,
    this.strings = const NavigationPanelStrings(),
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
                    child: Text(strings.buttonClose),
                  ),
                ),
                const SizedBox(width: 12),
                if (onOpenSettings != null) ...[
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: onOpenSettings,
                      child: Text(strings.buttonSettings),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: onRetry,
                    child: Text(strings.buttonRetry),
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
