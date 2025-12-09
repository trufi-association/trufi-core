import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../../core/l10n/core_localizations.dart';
import 'l10n/about_localizations.dart';

/// About screen module
class AboutTrufiScreen extends TrufiScreen {
  @override
  String get id => 'about';

  @override
  String get path => '/about';

  @override
  Widget Function(BuildContext context) get builder => (_) => const _AboutScreen();

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        AboutLocalizations.delegate,
      ];

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.info,
        order: 900,
        showDividerBefore: true,
      );

  @override
  String getLocalizedTitle(BuildContext context) {
    return AboutLocalizations.of(context).aboutTitle;
  }
}

/// About screen widget
class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context) {
    final coreL10n = CoreLocalizations.of(context);
    final aboutL10n = AboutLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // App info card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_bus,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    coreL10n.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${aboutL10n.aboutVersion}: 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    aboutL10n.aboutDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Architecture info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aboutL10n.aboutArchitectureDetails,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.architecture,
                    title: aboutL10n.aboutPattern,
                    value: 'Clean Architecture + Modular',
                  ),
                  const _InfoRow(
                    icon: Icons.settings,
                    title: 'DI',
                    value: 'GetIt (Isolated Instance)',
                  ),
                  _InfoRow(
                    icon: Icons.route,
                    title: aboutL10n.aboutNavigation,
                    value: 'GoRouter with Dynamic Screens',
                  ),
                  _InfoRow(
                    icon: Icons.translate,
                    title: aboutL10n.aboutTranslations,
                    value: 'Per-Feature ARB Localizations',
                  ),
                  _InfoRow(
                    icon: Icons.storage,
                    title: aboutL10n.aboutState,
                    value: 'BLoC Pattern',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Issue reference card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        aboutL10n.aboutReferenceIssue,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue[700],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This POC implements the architecture proposed in:',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    'https://github.com/trufi-association/trufi-core/issues/777',
                    style: TextStyle(
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Features implemented
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aboutL10n.aboutFeaturesImplemented,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const _FeatureCheckItem(
                    title: 'TrufiModule Interface',
                    description: 'Abstract module lifecycle management',
                    isImplemented: true,
                  ),
                  const _FeatureCheckItem(
                    title: 'TrufiCore DI Container',
                    description: 'Isolated GetIt instance with dependency sorting',
                    isImplemented: true,
                  ),
                  const _FeatureCheckItem(
                    title: 'ScreenRegistry',
                    description: 'Dynamic screen registration for modules',
                    isImplemented: true,
                  ),
                  const _FeatureCheckItem(
                    title: 'ARB Localizations',
                    description: 'Flutter standard ARB-based translations',
                    isImplemented: true,
                  ),
                  const _FeatureCheckItem(
                    title: 'GoRouter Integration',
                    description: 'Modern declarative routing',
                    isImplemented: true,
                  ),
                  const _FeatureCheckItem(
                    title: 'Search Input Screen',
                    description: 'Origin/Destination input demo',
                    isImplemented: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Credits
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Trufi Association',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open Source Transit Solutions',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _FeatureCheckItem extends StatelessWidget {
  final String title;
  final String description;
  final bool isImplemented;

  const _FeatureCheckItem({
    required this.title,
    required this.description,
    required this.isImplemented,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isImplemented ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isImplemented ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
