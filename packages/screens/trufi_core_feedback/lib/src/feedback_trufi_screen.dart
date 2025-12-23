import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/feedback_localizations.dart';

/// Feedback screen configuration
class FeedbackConfig {
  /// URL to open for feedback (will append query params: lang, geo, app)
  final String feedbackUrl;

  /// Optional callback to get current location (latitude, longitude)
  final Future<(double, double)?> Function()? getCurrentLocation;

  const FeedbackConfig({required this.feedbackUrl, this.getCurrentLocation});
}

/// Feedback screen module that implements TrufiScreen
class FeedbackTrufiScreen extends TrufiScreen {
  final FeedbackConfig config;

  FeedbackTrufiScreen({required this.config});

  @override
  String get id => 'feedback';

  @override
  String get path => '/feedback';

  @override
  Widget Function(BuildContext context) get builder =>
      (context) => _FeedbackScreenWidget(config: config);

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    FeedbackLocalizations.delegate,
  ];

  @override
  List<Locale> get supportedLocales => FeedbackLocalizations.supportedLocales;

  @override
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.feedback_outlined, order: 800);

  @override
  bool get hasOwnAppBar => true;

  @override
  String getLocalizedTitle(BuildContext context) {
    return FeedbackLocalizations.of(context).menuFeedback;
  }
}

/// Main screen widget with header and content
class _FeedbackScreenWidget extends StatelessWidget {
  final FeedbackConfig config;

  const _FeedbackScreenWidget({required this.config});

  /// Try to open the drawer from the nearest ancestor Scaffold
  void _tryOpenDrawer(BuildContext context) {
    HapticFeedback.lightImpact();
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      scaffold!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = FeedbackLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Modern header
            _FeedbackHeader(
              title: localization.menuFeedback,
              onMenuPressed: () => _tryOpenDrawer(context),
            ),
            // Content
            Expanded(child: _FeedbackContent(config: config)),
          ],
        ),
      ),
    );
  }
}

/// Modern header for feedback screen
class _FeedbackHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const _FeedbackHeader({required this.title, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Menu button
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
          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feedback content widget with animations
class _FeedbackContent extends StatefulWidget {
  final FeedbackConfig config;

  const _FeedbackContent({required this.config});

  @override
  State<_FeedbackContent> createState() => _FeedbackContentState();
}

class _FeedbackContentState extends State<_FeedbackContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem({
    required int index,
    required Widget child,
    int totalItems = 6,
  }) {
    final startTime = (index / totalItems).clamp(0.0, 0.6);
    final endTime = ((index / totalItems) + 0.4).clamp(0.0, 1.0);

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }

  Future<void> _openFeedback(BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final localization = FeedbackLocalizations.of(context);
      final version = await PackageInfoPlatform.version();

      String geoParam = '';
      if (widget.config.getCurrentLocation != null) {
        final location = await widget.config.getCurrentLocation!();
        if (location != null) {
          geoParam = '${location.$1},${location.$2}';
        }
      }

      final uri = Uri.parse(widget.config.feedbackUrl).replace(
        queryParameters: {
          'lang': localization.localeName,
          if (geoParam.isNotEmpty) 'geo': geoParam,
          'app': version,
        },
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = FeedbackLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hero card
                _buildAnimatedItem(
                  index: 0,
                  child: _FeedbackHeroCard(localization: localization),
                ),
                const SizedBox(height: 20),

                // Main content card
                _buildAnimatedItem(
                  index: 1,
                  child: _ContentCard(content: localization.feedbackContent),
                ),
                const SizedBox(height: 16),

                // What we'd love to hear card
                _buildAnimatedItem(
                  index: 2,
                  child: _WhatWeWantCard(localization: localization),
                ),
              ],
            ),
          ),
        ),

        // Bottom action area
        _buildAnimatedItem(
          index: 3,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : () => _openFeedback(context),
                icon: _isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.open_in_new_rounded, size: 20),
                label: Text(localization.feedbackSend),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hero card at the top of feedback screen
class _FeedbackHeroCard extends StatelessWidget {
  final FeedbackLocalizations localization;

  const _FeedbackHeroCard({required this.localization});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with decorative background
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localization.feedbackTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your voice matters to us',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Content card with main description
class _ContentCard extends StatelessWidget {
  final String content;

  const _ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 22,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What we want to hear card with feedback items
class _WhatWeWantCard extends StatelessWidget {
  final FeedbackLocalizations localization;

  const _WhatWeWantCard({required this.localization});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    size: 22,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    localization.feedbackWhatWeWant,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FeedbackItem(
                  icon: Icons.bug_report_rounded,
                  text: localization.feedbackBugs,
                  color: Colors.red,
                ),
                const SizedBox(height: 10),
                _FeedbackItem(
                  icon: Icons.route_rounded,
                  text: localization.feedbackRoutes,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                _FeedbackItem(
                  icon: Icons.auto_awesome_rounded,
                  text: localization.feedbackSuggestions,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual feedback item with icon and text
class _FeedbackItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeedbackItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
