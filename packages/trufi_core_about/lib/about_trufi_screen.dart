import 'package:flutter/material.dart';
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
  String getLocalizedTitle(BuildContext context) {
    return AboutLocalization.of(context)?.menuAbout ?? 'About';
  }
}

/// About content widget (without Scaffold, for use with ShellRoute)
class _AboutContent extends StatelessWidget {
  final AboutScreenConfig config;

  const _AboutContent({required this.config});

  @override
  Widget build(BuildContext context) {
    final localization = AboutLocalization.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Header with logo/icon
            _buildHeader(context, localization),
            const SizedBox(height: 32),
            // Mission section
            _buildSection(
              context,
              icon: Icons.favorite_outline,
              title: localization.aboutCollapseTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.aboutCollapseContent,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localization.aboutCollapseContentFoot,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Get involved section
            _buildSection(
              context,
              icon: Icons.people_outline,
              title: localization.volunteerTrufi,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AboutLinkTile(
                    icon: Icons.language,
                    title: localization.trufiWebsite,
                    onTap: () => _launchUrl(
                      'https://www.trufi-association.org/?utm_source=${config.cityName}-${config.countryName}&utm_medium=${localization.localeName}&utm_campaign=in-app-referral&utm_content=trufi-association-website',
                    ),
                  ),
                  _AboutLinkTile(
                    icon: Icons.volunteer_activism,
                    title: localization.volunteerTrufi,
                    onTap: () => _launchUrl(
                      'https://www.trufi-association.org/volunteering/?utm_source=${config.cityName}-${config.countryName}&utm_medium=${localization.localeName}&utm_campaign=in-app-referral&utm_content=volunteer-for-trufi',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Open source section
            _buildSection(
              context,
              icon: Icons.code,
              title: 'Open Source',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.aboutOpenSource,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AboutLinkTile(
                    icon: Icons.open_in_new,
                    title: 'GitHub',
                    subtitle: 'trufi-association/trufi-core',
                    onTap: () => _launchUrl(
                      'https://github.com/trufi-association/trufi-core',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Contact section
            _buildSection(
              context,
              icon: Icons.mail_outline,
              title: 'Contact',
              child: _AboutLinkTile(
                icon: Icons.email,
                title: config.emailContact,
                subtitle: 'Send us feedback',
                onTap: () => _launchUrl(
                  'mailto:${config.emailContact}?subject=${config.appName} Feedback',
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Licenses button
            OutlinedButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: config.appName,
                applicationLegalese:
                    '${config.cityName}, ${config.countryName}',
              ),
              icon: const Icon(Icons.description_outlined),
              label: Text(localization.aboutLicenses),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AboutLocalization localization) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // App icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: config.logoAssetPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    config.logoAssetPath!,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.directions_bus,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
        ),
        const SizedBox(height: 16),
        // App name
        Text(
          config.appName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Tagline
        Text(
          localization.tagline('${config.cityName}, ${config.countryName}'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Version
        FutureBuilder(
          future: PackageInfoPlatform.version(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                localization.version(snapshot.data ?? ''),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Reusable link tile widget
class _AboutLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _AboutLinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
