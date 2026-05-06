import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/fares_localizations.dart';
import 'models/fare_models.dart';
import 'widgets/fare_card.dart';
import 'widgets/fares_hero.dart';
import 'widgets/fares_notes_card.dart';

/// Drop-in fares screen wired to a [FaresConfig].
///
/// Apps that want a custom layout can compose [FaresHero], [FareCard],
/// [FareCategoryChip] and [FaresNotesCard] from this package directly
/// instead of using this screen.
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
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.payments_outlined, order: 150);

  @override
  bool get hasOwnAppBar => true;

  @override
  String getLocalizedTitle(BuildContext context) {
    return FaresLocalizations.of(context).menuFares;
  }
}

class _FaresScreenWidget extends StatelessWidget {
  final FaresConfig config;

  const _FaresScreenWidget({required this.config});

  void _tryOpenDrawer(BuildContext context) {
    HapticFeedback.lightImpact();
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      scaffold!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = FaresLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _FaresHeader(
              title: localization.menuFares,
              onMenuPressed: () => _tryOpenDrawer(context),
            ),
            Expanded(child: _FaresContent(config: config)),
          ],
        ),
      ),
    );
  }
}

class _FaresHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const _FaresHeader({required this.title, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
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
          child: Opacity(opacity: animation.value, child: child),
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
    final localization = FaresLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fares = widget.config.fares;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedItem(
            index: 0,
            child: FaresHero(
              title: localization.faresTitle,
              subtitle: localization.faresSubtitle,
            ),
          ),
          const SizedBox(height: 20),
          _buildAnimatedItem(
            index: 1,
            child: _SectionHeader(
              title: localization.faresTitle,
              icon: Icons.receipt_long_rounded,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < fares.length; i++)
            _buildAnimatedItem(
              index: 2 + i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FareCard(
                  fare: fares[i],
                  currency: widget.config.currency,
                ),
              ),
            ),
          if (widget.config.lastUpdated != null) ...[
            const SizedBox(height: 8),
            _buildAnimatedItem(
              index: 2 + fares.length,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
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
                        localization.faresLastUpdated(
                          _formatDate(widget.config.lastUpdated!),
                        ),
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
          if (widget.config.additionalNotes != null) ...[
            const SizedBox(height: 20),
            _buildAnimatedItem(
              index: 3 + fares.length,
              child: FaresNotesCard(notes: widget.config.additionalNotes!),
            ),
          ],
          if (widget.config.externalFareUrl != null) ...[
            const SizedBox(height: 24),
            _buildAnimatedItem(
              index: 4 + fares.length,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      _openExternalUrl(widget.config.externalFareUrl!),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
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
}
