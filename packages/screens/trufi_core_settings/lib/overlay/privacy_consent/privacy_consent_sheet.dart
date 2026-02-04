import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../l10n/settings_localizations.dart';

/// Privacy consent dialog for log reporting
/// - Large screens (>= 600px): Centered modal
/// - Small screens (< 600px): Bottom sheet
class PrivacyConsentSheet extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  /// Breakpoint for switching between modal and bottom sheet
  static const double _breakpoint = 600;

  const PrivacyConsentSheet({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= _breakpoint;

    if (isLargeScreen) {
      return _buildCenteredModal(context);
    } else {
      return _buildBottomSheet(context);
    }
  }

  /// Centered modal for large screens
  Widget _buildCenteredModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: PointerInterceptor(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: screenSize.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildContent(context, showCloseButton: false),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet for small screens
  Widget _buildBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.bottomCenter,
      child: PointerInterceptor(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _buildContent(context, showCloseButton: false, showDragHandle: true),
          ),
        ),
      ),
    );
  }

  /// Shared content for both layouts
  Widget _buildContent(
    BuildContext context, {
    bool showCloseButton = false,
    bool showDragHandle = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = SettingsLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle for bottom sheet
        if (showDragHandle)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        // Header content
        Padding(
          padding: EdgeInsets.fromLTRB(24, showDragHandle ? 8 : 24, 24, 16),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.privacy_tip_rounded,
                  size: 32,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.privacyConsentTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.privacyConsentSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(77)),
        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _PrivacyInfoCard(l10n: l10n),
          ),
        ),
        // Bottom buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // Accept button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onAccept();
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.privacyConsentAccept,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Decline button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDecline();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: Text(
                    l10n.privacyConsentDecline,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Information card explaining what data is collected
class _PrivacyInfoCard extends StatelessWidget {
  final SettingsLocalizations l10n;

  const _PrivacyInfoCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.privacyConsentInfoTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _InfoItem(
                  icon: Icons.bug_report_rounded,
                  text: l10n.privacyConsentInfoLogs,
                ),
                const SizedBox(height: 12),
                _InfoItem(
                  icon: Icons.route_rounded,
                  text: l10n.privacyConsentInfoRoutes,
                ),
                const SizedBox(height: 12),
                _InfoItem(
                  icon: Icons.shield_rounded,
                  text: l10n.privacyConsentInfoAnonymous,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual info item with icon
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
