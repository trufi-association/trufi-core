import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'l10n/about_localizations.dart';

/// About screen configuration
class AboutScreenConfig {
  final String appName;
  final String cityName;
  final String countryName;
  final String emailContact;
  final String? logoAssetPath;
  final String? websiteUrl;
  final String? twitterUrl;
  final String? facebookUrl;

  const AboutScreenConfig({
    required this.appName,
    required this.cityName,
    required this.countryName,
    required this.emailContact,
    this.logoAssetPath,
    this.websiteUrl,
    this.twitterUrl,
    this.facebookUrl,
  });
}

/// About screen module that implements TrufiScreen
class AboutTrufiScreen extends TrufiScreen {
  final AboutScreenConfig config;

  AboutTrufiScreen({required this.config});

  @override
  String get id => 'about';

  @override
  String get path => '/about';

  @override
  Widget Function(BuildContext context) get builder =>
      (context) => _AboutContent(config: config);

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        AboutLocalization.delegate,
      ];

  @override
  List<Locale> get supportedLocales => AboutLocalization.supportedLocales;

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.info_outline,
        order: 900,
        showDividerBefore: true,
      );

  @override
  bool get hasOwnAppBar => true;

  @override
  String getLocalizedTitle(BuildContext context) {
    return AboutLocalization.of(context)?.menuAbout ?? 'About';
  }
}

/// About screen widget with modern design
class _AboutContent extends StatelessWidget {
  final AboutScreenConfig config;

  const _AboutContent({required this.config});

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
    final localization = AboutLocalization.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Modern header
            _AboutHeader(
              title: localization.menuAbout,
              onMenuPressed: () => _tryOpenDrawer(context),
            ),
            // Content
            Expanded(
              child: _AboutScrollContent(config: config),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern header for about screen
class _AboutHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const _AboutHeader({
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

/// Scrollable content with staggered animations
class _AboutScrollContent extends StatefulWidget {
  final AboutScreenConfig config;

  const _AboutScrollContent({required this.config});

  @override
  State<_AboutScrollContent> createState() => _AboutScrollContentState();
}

class _AboutScrollContentState extends State<_AboutScrollContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _launchUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AboutLocalization.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          // Hero card with app info
          _buildAnimatedItem(
            index: 0,
            child: _AboutHeroCard(config: widget.config),
          ),
          const SizedBox(height: 20),

          // Mission section
          _buildAnimatedItem(
            index: 1,
            child: _AboutSectionCard(
              icon: Icons.favorite_rounded,
              iconColor: Colors.red,
              title: localization.aboutCollapseTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.aboutCollapseContent,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.handshake_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localization.aboutCollapseContentFoot,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Get involved section
          _buildAnimatedItem(
            index: 2,
            child: _AboutSectionCard(
              icon: Icons.people_rounded,
              iconColor: Colors.blue,
              title: localization.volunteerTrufi,
              child: Column(
                children: [
                  _AboutLinkTile(
                    icon: Icons.language_rounded,
                    iconColor: Colors.teal,
                    title: localization.trufiWebsite,
                    onTap: () => _launchUrl(
                      'https://www.trufi-association.org/?utm_source=${widget.config.cityName}-${widget.config.countryName}&utm_medium=${localization.localeName}&utm_campaign=in-app-referral&utm_content=trufi-association-website',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AboutLinkTile(
                    icon: Icons.volunteer_activism_rounded,
                    iconColor: Colors.pink,
                    title: localization.volunteerTrufi,
                    onTap: () => _launchUrl(
                      'https://www.trufi-association.org/volunteering/?utm_source=${widget.config.cityName}-${widget.config.countryName}&utm_medium=${localization.localeName}&utm_campaign=in-app-referral&utm_content=volunteer-for-trufi',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Open source section
          _buildAnimatedItem(
            index: 3,
            child: _AboutSectionCard(
              icon: Icons.code_rounded,
              iconColor: Colors.green,
              title: 'Open Source',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.aboutOpenSource,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AboutLinkTile(
                    icon: Icons.open_in_new_rounded,
                    iconColor: Colors.deepPurple,
                    title: 'GitHub',
                    subtitle: 'trufi-association/trufi-core',
                    onTap: () => _launchUrl(
                      'https://github.com/trufi-association/trufi-core',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact section
          _buildAnimatedItem(
            index: 4,
            child: _AboutSectionCard(
              icon: Icons.mail_rounded,
              iconColor: Colors.orange,
              title: 'Contact',
              child: _AboutLinkTile(
                icon: Icons.email_rounded,
                iconColor: Colors.indigo,
                title: widget.config.emailContact,
                subtitle: 'Send us feedback',
                onTap: () => _launchUrl(
                  'mailto:${widget.config.emailContact}?subject=${widget.config.appName} Feedback',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Licenses button
          _buildAnimatedItem(
            index: 5,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  showLicensePage(
                    context: context,
                    applicationName: widget.config.appName,
                    applicationLegalese:
                        '${widget.config.cityName}, ${widget.config.countryName}',
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 20),
                label: Text(localization.aboutLicenses),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero card with app logo and info
class _AboutHeroCard extends StatelessWidget {
  final AboutScreenConfig config;

  const _AboutHeroCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final localization = AboutLocalization.of(context)!;
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
          // App icon with decorative background
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: config.logoAssetPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      config.logoAssetPath!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.directions_bus_rounded,
                    size: 44,
                    color: colorScheme.onPrimaryContainer,
                  ),
          ),
          const SizedBox(height: 20),
          // App name
          Text(
            config.appName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Tagline
          Text(
            localization.tagline('${config.cityName}, ${config.countryName}'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Version badge
          FutureBuilder(
            future: PackageInfoPlatform.version(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  localization.version(snapshot.data ?? ''),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Section card with colored header
class _AboutSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _AboutSectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

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
          // Header with colored background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
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
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Reusable link tile widget with modern styling
class _AboutLinkTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _AboutLinkTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: iconColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
