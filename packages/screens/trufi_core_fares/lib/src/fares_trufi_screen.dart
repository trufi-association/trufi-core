import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/fares_localizations.dart';

/// Fare information model
class FareInfo {
  /// Name of the transport type (e.g., "Bus", "Trufi", "Metro")
  final String transportType;

  /// Icon for this transport type
  final IconData icon;

  /// Color for this transport type (optional, uses primary if not set)
  final Color? color;

  /// Regular fare price
  final String regularFare;

  /// Student fare price (optional)
  final String? studentFare;

  /// Senior/elderly fare price (optional)
  final String? seniorFare;

  /// Additional notes about this fare
  final String? notes;

  const FareInfo({
    required this.transportType,
    required this.icon,
    this.color,
    required this.regularFare,
    this.studentFare,
    this.seniorFare,
    this.notes,
  });
}

/// Fares screen configuration
class FaresConfig {
  /// List of fare information to display
  final List<FareInfo> fares;

  /// Currency symbol (e.g., "Bs.", "$", "€")
  final String currency;

  /// Optional URL to external fare information
  final String? externalFareUrl;

  /// Last updated date for fare information
  final DateTime? lastUpdated;

  /// Additional notes shown at the bottom
  final String? additionalNotes;

  const FaresConfig({
    required this.fares,
    required this.currency,
    this.externalFareUrl,
    this.lastUpdated,
    this.additionalNotes,
  });
}

/// Fares screen module that implements TrufiScreen
class FaresTrufiScreen extends TrufiScreen {
  final FaresConfig config;

  FaresTrufiScreen({required this.config});

  @override
  String get id => 'fares';

  @override
  String get path => '/fares';

  @override
  Widget Function(BuildContext context) get builder =>
      (context) => _FaresScreenWidget(config: config);

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        FaresLocalizations.delegate,
      ];

  @override
  List<Locale> get supportedLocales => FaresLocalizations.supportedLocales;

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.payments_outlined,
        order: 150,
      );

  @override
  bool get hasOwnAppBar => true;

  @override
  String getLocalizedTitle(BuildContext context) {
    return FaresLocalizations.of(context)?.menuFares ?? 'Fares';
  }
}

/// Main screen widget with header and content
class _FaresScreenWidget extends StatelessWidget {
  final FaresConfig config;

  const _FaresScreenWidget({required this.config});

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
    final localization = FaresLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Modern header
            _FaresHeader(
              title: localization.menuFares,
              onMenuPressed: () => _tryOpenDrawer(context),
            ),
            // Content
            Expanded(
              child: _FaresContent(config: config),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern header for fares screen
class _FaresHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const _FaresHeader({
    required this.title,
    required this.onMenuPressed,
  });

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

/// Fares content widget with staggered animations
class _FaresContent extends StatefulWidget {
  final FaresConfig config;

  const _FaresContent({required this.config});

  @override
  State<_FaresContent> createState() => _FaresContentState();
}

class _FaresContentState extends State<_FaresContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Start animation after build
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
    int totalItems = 10,
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
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _openExternalUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = FaresLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero header card
          _buildAnimatedItem(
            index: 0,
            child: _FaresHeroCard(localization: localization),
          ),
          const SizedBox(height: 20),

          // Section title
          _buildAnimatedItem(
            index: 1,
            child: _buildSectionHeader(
              context,
              localization.faresTitle,
              Icons.receipt_long_rounded,
            ),
          ),
          const SizedBox(height: 12),

          // Fare cards
          ...widget.config.fares.asMap().entries.map(
                (entry) => _buildAnimatedItem(
                  index: 2 + entry.key,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FareCard(
                      fare: entry.value,
                      currency: widget.config.currency,
                      localization: localization,
                    ),
                  ),
                ),
              ),

          // Last updated
          if (widget.config.lastUpdated != null) ...[
            const SizedBox(height: 8),
            _buildAnimatedItem(
              index: 2 + widget.config.fares.length,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.update_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        localization.faresLastUpdated(_formatDate(widget.config.lastUpdated!)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Additional notes
          if (widget.config.additionalNotes != null) ...[
            const SizedBox(height: 20),
            _buildAnimatedItem(
              index: 3 + widget.config.fares.length,
              child: _NotesCard(notes: widget.config.additionalNotes!),
            ),
          ],

          // External link button
          if (widget.config.externalFareUrl != null) ...[
            const SizedBox(height: 24),
            _buildAnimatedItem(
              index: 4 + widget.config.fares.length,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openExternalUrl(widget.config.externalFareUrl!),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(localization.faresMoreInfo),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Hero card at the top of fares screen
class _FaresHeroCard extends StatelessWidget {
  final FaresLocalizations localization;

  const _FaresHeroCard({required this.localization});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payments_rounded,
              size: 36,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localization.faresTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localization.faresSubtitle,
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

/// Modernized fare card with improved styling
class _FareCard extends StatelessWidget {
  final FareInfo fare;
  final String currency;
  final FaresLocalizations localization;

  const _FareCard({
    required this.fare,
    required this.currency,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fareColor = fare.color ?? colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header with transport type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fareColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: fareColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    fare.icon,
                    color: fareColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    fare.transportType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                // Main price badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: fareColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$currency ${fare.regularFare}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Price details
          if (fare.studentFare != null || fare.seniorFare != null || fare.notes != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (fare.studentFare != null || fare.seniorFare != null) ...[
                    Row(
                      children: [
                        if (fare.studentFare != null)
                          Expanded(
                            child: _CompactPriceChip(
                              icon: Icons.school_rounded,
                              label: localization.faresStudent,
                              price: '$currency ${fare.studentFare}',
                              color: Colors.blue,
                            ),
                          ),
                        if (fare.studentFare != null && fare.seniorFare != null)
                          const SizedBox(width: 10),
                        if (fare.seniorFare != null)
                          Expanded(
                            child: _CompactPriceChip(
                              icon: Icons.elderly_rounded,
                              label: localization.faresSenior,
                              price: '$currency ${fare.seniorFare}',
                              color: Colors.teal,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (fare.notes != null) ...[
                    if (fare.studentFare != null || fare.seniorFare != null)
                      const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fare.notes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact price chip for student/senior fares
class _CompactPriceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final Color color;

  const _CompactPriceChip({
    required this.icon,
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notes card with info styling
class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 20,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
