import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../../core/l10n/core_localizations.dart';
import '../search/l10n/search_localizations.dart';
import 'l10n/home_localizations.dart';

/// Home screen module
class HomeTrufiScreen extends TrufiScreen {
  @override
  String get id => 'home';

  @override
  String get path => '/';

  @override
  Widget Function(BuildContext context) get builder => (_) => const _HomeScreen();

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        HomeLocalizations.delegate,
      ];

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.home,
        order: 0,
      );

  @override
  String getLocalizedTitle(BuildContext context) {
    return HomeLocalizations.of(context).homeTitle;
  }
}

/// Home screen widget
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WelcomeCard(),
          const SizedBox(height: 16),
          _SearchInputCard(),
          const SizedBox(height: 16),
          _QuickActionsSection(),
          const SizedBox(height: 16),
          _FeaturesShowcase(),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = HomeLocalizations.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.directions_bus,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homeTitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInputCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coreL10n = CoreLocalizations.of(context);
    final searchL10n = SearchLocalizations.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coreL10n.navSearch,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _LocationInputField(
              icon: Icons.my_location,
              iconColor: Colors.green,
              hint: searchL10n.searchOrigin,
              onTap: () => context.go('/search'),
            ),
            const SizedBox(height: 8),
            _LocationInputField(
              icon: Icons.location_on,
              iconColor: Colors.red,
              hint: searchL10n.searchDestination,
              onTap: () => context.go('/search'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/search'),
                icon: const Icon(Icons.search),
                label: Text(coreL10n.navSearch),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationInputField extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String hint;
  final VoidCallback onTap;

  const _LocationInputField({
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = HomeLocalizations.of(context);
    final searchL10n = SearchLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeQuickActions,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.map,
                label: searchL10n.searchChooseOnMap,
                onTap: () => context.go('/search'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.star,
                label: l10n.homeFavorites,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturesShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = HomeLocalizations.of(context);
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homePocFeatures,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green[800],
                  ),
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.route,
              title: 'GoRouter Navigation',
              description: 'Modern declarative routing with deep linking support',
            ),
            const _FeatureItem(
              icon: Icons.translate,
              title: 'Per-Feature Translations',
              description: 'Modular ARB-based localizations per feature',
            ),
            const _FeatureItem(
              icon: Icons.extension,
              title: 'Modular Architecture',
              description: 'TrufiModule interface with GetIt DI',
            ),
            const _FeatureItem(
              icon: Icons.dashboard_customize,
              title: 'Dynamic Screens',
              description: 'Screen registry for module-based screen registration',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green),
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
