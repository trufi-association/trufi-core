import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'l10n/settings_localizations.dart';
import 'overlay/privacy_consent/privacy_consent_manager.dart';

/// Settings screen module
class SettingsTrufiScreen extends TrufiScreen {
  @override
  String get id => 'settings';

  @override
  String get path => '/settings';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => const _SettingsScreenWidget();

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        SettingsLocalizations.delegate,
      ];

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.settings,
        order: 300,
      );

  @override
  bool get hasOwnAppBar => true;

  @override
  String getLocalizedTitle(BuildContext context) {
    return SettingsLocalizations.of(context).settingsTitle;
  }
}

/// Settings screen widget with header and content
class _SettingsScreenWidget extends StatelessWidget {
  const _SettingsScreenWidget();

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
    final settingsL10n = SettingsLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Modern header
            _SettingsHeader(
              title: settingsL10n.settingsTitle,
              onMenuPressed: () => _tryOpenDrawer(context),
            ),
            // Content
            const Expanded(
              child: _SettingsContent(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern header for settings screen
class _SettingsHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const _SettingsHeader({
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

/// Settings content with staggered animations
class _SettingsContent extends StatefulWidget {
  const _SettingsContent();

  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent>
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language settings card
          _buildAnimatedItem(
            index: 0,
            child: const _LanguageSettingsCard(),
          ),

          const SizedBox(height: 16),

          // Theme settings card
          _buildAnimatedItem(
            index: 1,
            child: const _ThemeSettingsCard(),
          ),

          const SizedBox(height: 16),

          // Routing settings card (before maps)
          _buildAnimatedItem(
            index: 2,
            child: const _RoutingSettingsCard(),
          ),

          const SizedBox(height: 16),

          // Map settings card
          _buildAnimatedItem(
            index: 3,
            child: const _MapSettingsCard(),
          ),

          const SizedBox(height: 16),

          // Privacy settings card
          _buildAnimatedItem(
            index: 4,
            child: const _PrivacySettingsCard(),
          ),
        ],
      ),
    );
  }
}

/// Language settings card with modern styling
class _LanguageSettingsCard extends StatelessWidget {
  const _LanguageSettingsCard();

  @override
  Widget build(BuildContext context) {
    final settingsL10n = SettingsLocalizations.of(context);
    final localeManager = LocaleManager.watch(context);

    return _SettingsCard(
      icon: Icons.translate_rounded,
      iconColor: Colors.blue,
      title: settingsL10n.settingsLanguage,
      subtitle: settingsL10n.settingsSelectLanguage,
      child: Column(
        children: [
          _LanguageOption(
            languageCode: 'en',
            languageName: 'English',
            isSelected: localeManager.currentLocale.languageCode == 'en',
            onSelect: () {
              HapticFeedback.selectionClick();
              localeManager.setLocaleByCode('en');
            },
          ),
          const SizedBox(height: 8),
          _LanguageOption(
            languageCode: 'es',
            languageName: 'Español',
            isSelected: localeManager.currentLocale.languageCode == 'es',
            onSelect: () {
              HapticFeedback.selectionClick();
              localeManager.setLocaleByCode('es');
            },
          ),
          const SizedBox(height: 8),
          _LanguageOption(
            languageCode: 'de',
            languageName: 'Deutsch',
            isSelected: localeManager.currentLocale.languageCode == 'de',
            onSelect: () {
              HapticFeedback.selectionClick();
              localeManager.setLocaleByCode('de');
            },
          ),
        ],
      ),
    );
  }
}

/// Theme settings card with modern styling
class _ThemeSettingsCard extends StatelessWidget {
  const _ThemeSettingsCard();

  @override
  Widget build(BuildContext context) {
    final settingsL10n = SettingsLocalizations.of(context);
    final themeManager = ThemeManager.watch(context);

    return _SettingsCard(
      icon: Icons.palette_rounded,
      iconColor: Colors.purple,
      title: settingsL10n.settingsTheme,
      subtitle: settingsL10n.settingsSelectTheme,
      child: Row(
        children: [
          Expanded(
            child: _ThemeOptionChip(
              icon: Icons.light_mode_rounded,
              label: settingsL10n.settingsThemeLight,
              isSelected: themeManager.isLight,
              onTap: () {
                HapticFeedback.selectionClick();
                themeManager.setThemeMode(ThemeMode.light);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ThemeOptionChip(
              icon: Icons.dark_mode_rounded,
              label: settingsL10n.settingsThemeDark,
              isSelected: themeManager.isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                themeManager.setThemeMode(ThemeMode.dark);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ThemeOptionChip(
              icon: Icons.auto_mode_rounded,
              label: settingsL10n.settingsThemeSystem,
              isSelected: themeManager.isSystem,
              onTap: () {
                HapticFeedback.selectionClick();
                themeManager.setThemeMode(ThemeMode.system);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Map settings card with modern styling
class _MapSettingsCard extends StatelessWidget {
  const _MapSettingsCard();

  @override
  Widget build(BuildContext context) {
    final settingsL10n = SettingsLocalizations.of(context);
    final mapEngineManager = MapEngineManager.maybeWatch(context);

    // If no MapEngineManager is available, don't show this card
    if (mapEngineManager == null || mapEngineManager.engines.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SettingsCard(
      icon: Icons.map_rounded,
      iconColor: Colors.teal,
      title: settingsL10n.settingsMap,
      subtitle: settingsL10n.settingsSelectMapType,
      child: Column(
        children: mapEngineManager.engines.asMap().entries.map((entry) {
          final index = entry.key;
          final engine = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < mapEngineManager.engines.length - 1 ? 8 : 0,
            ),
            child: _EngineOptionTile(
              name: engine.name,
              description: engine.description,
              icon: Icons.layers_rounded,
              isSelected: index == mapEngineManager.currentIndex,
              onTap: () {
                HapticFeedback.selectionClick();
                mapEngineManager.setEngineByIndex(index);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Routing settings card with modern styling
class _RoutingSettingsCard extends StatelessWidget {
  const _RoutingSettingsCard();

  @override
  Widget build(BuildContext context) {
    final settingsL10n = SettingsLocalizations.of(context);
    final routingEngineManager = routing.RoutingEngineManager.maybeWatch(context);

    // If no RoutingEngineManager is available or only one engine, don't show this card
    if (routingEngineManager == null || !routingEngineManager.hasMultipleEngines) {
      return const SizedBox.shrink();
    }

    return _SettingsCard(
      icon: Icons.route_rounded,
      iconColor: Colors.indigo,
      title: settingsL10n.settingsRouting,
      subtitle: settingsL10n.settingsSelectRoutingEngine,
      child: Column(
        children: routingEngineManager.engines.asMap().entries.map((entry) {
          final index = entry.key;
          final engine = entry.value;
          final isOffline = !engine.requiresInternet;

          // Get localized name and description
          final name = isOffline ? settingsL10n.engineOfflineName : settingsL10n.engineOnlineName;
          final description = isOffline ? settingsL10n.engineOfflineDescription : settingsL10n.engineOnlineDescription;

          // Get limitations based on engine type
          final limitations = isOffline
              ? [settingsL10n.limitationNoWalkingRoute]
              : [settingsL10n.limitationRequiresInternet, settingsL10n.limitationSlower];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < routingEngineManager.engines.length - 1 ? 8 : 0,
            ),
            child: _RoutingEngineOptionTile(
              name: name,
              description: description,
              limitations: limitations,
              icon: isOffline ? Icons.offline_bolt_rounded : Icons.cloud_rounded,
              isSelected: index == routingEngineManager.currentIndex,
              onTap: () {
                HapticFeedback.selectionClick();
                routingEngineManager.setEngineByIndex(index);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Base settings card with consistent styling
class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
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
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

/// Language option with selection state
class _LanguageOption extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final bool isSelected;
  final VoidCallback onSelect;

  const _LanguageOption({
    required this.languageCode,
    required this.languageName,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Language icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.language_rounded,
                  size: 22,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              // Language info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      languageCode.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme option chip with icon
class _ThemeOptionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Engine option tile with description (used for map and routing engines)
class _EngineOptionTile extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EngineOptionTile({
    required this.name,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Engine icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Map info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Routing engine option tile with description and limitations
class _RoutingEngineOptionTile extends StatelessWidget {
  final String name;
  final String description;
  final List<String> limitations;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoutingEngineOptionTile({
    required this.name,
    required this.description,
    required this.limitations,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Engine icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Engine info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (limitations.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: limitations.map((limitation) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.15)
                                  : colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              limitation,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Privacy settings card with toggle
class _PrivacySettingsCard extends StatelessWidget {
  const _PrivacySettingsCard();

  @override
  Widget build(BuildContext context) {
    final settingsL10n = SettingsLocalizations.of(context);
    final overlayManager = OverlayManager.watch(context);
    final privacyConsentManager =
        overlayManager.getManager<PrivacyConsentManager>();

    // If no PrivacyConsentManager is available, don't show this card
    if (privacyConsentManager == null) {
      return const SizedBox.shrink();
    }

    return _SettingsCard(
      icon: Icons.privacy_tip_rounded,
      iconColor: Colors.orange,
      title: settingsL10n.settingsPrivacy,
      subtitle: settingsL10n.settingsPrivacySubtitle,
      child: _PrivacyToggleTile(
        title: settingsL10n.settingsPrivacyShareData,
        description: settingsL10n.settingsPrivacyShareDataDescription,
        isEnabled: privacyConsentManager.isAccepted,
        onToggle: (value) {
          HapticFeedback.selectionClick();
          if (value) {
            privacyConsentManager.acceptConsent();
          } else {
            privacyConsentManager.declineConsent();
          }
        },
      ),
    );
  }
}

/// Toggle tile for privacy settings
class _PrivacyToggleTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _PrivacyToggleTile({
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isEnabled
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onToggle(!isEnabled),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEnabled
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: isEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Switch
              Switch.adaptive(
                value: isEnabled,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
