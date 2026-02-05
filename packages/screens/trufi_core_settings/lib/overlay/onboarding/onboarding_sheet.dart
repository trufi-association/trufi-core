import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/settings_localizations.dart';

/// Responsive onboarding dialog
/// - Large screens (>= 600px): Centered modal
/// - Small screens (< 600px): Bottom sheet
class OnboardingSheet extends StatelessWidget {
  final VoidCallback onComplete;

  /// Breakpoint for switching between modal and bottom sheet
  static const double _breakpoint = 600;

  const OnboardingSheet({super.key, required this.onComplete});

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
      // PointerInterceptor prevents platform views (maps) from
      // capturing touch events meant for this modal on web
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
            child: _buildContent(context, showCloseButton: true),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet for small screens (matches TrufiBottomSheet style)
  Widget _buildBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.bottomCenter,
      // PointerInterceptor prevents platform views (maps) from
      // capturing touch events meant for this sheet on web
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
        // Drag handle for bottom sheet (matches TrufiBottomSheet style)
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
        // Close button for modal
        if (showCloseButton)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onComplete();
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
        // Header content
        Padding(
          padding: EdgeInsets.fromLTRB(24, showDragHandle ? 0 : (showCloseButton ? 0 : 24), 24, 16),
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
                  Icons.waving_hand_rounded,
                  size: 32,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.onboardingTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.onboardingSubtitle,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                _OnboardingLanguageSection(l10n: l10n),
                const SizedBox(height: 16),
                _OnboardingThemeSection(l10n: l10n),
                const SizedBox(height: 16),
                _OnboardingMapSection(l10n: l10n),
                const SizedBox(height: 16),
                _OnboardingRoutingSection(l10n: l10n),
              ],
            ),
          ),
        ),
        // Bottom button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onComplete();
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.onboardingComplete,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Language selection section
class _OnboardingLanguageSection extends StatelessWidget {
  final SettingsLocalizations l10n;

  const _OnboardingLanguageSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final localeManager = LocaleManager.watch(context);

    return _OnboardingCard(
      icon: Icons.translate_rounded,
      iconColor: Colors.blue,
      title: l10n.onboardingLanguageTitle,
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
            languageName: 'Espanol',
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

/// Theme selection section
class _OnboardingThemeSection extends StatelessWidget {
  final SettingsLocalizations l10n;

  const _OnboardingThemeSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.watch(context);

    return _OnboardingCard(
      icon: Icons.palette_rounded,
      iconColor: Colors.purple,
      title: l10n.onboardingThemeTitle,
      child: Row(
        children: [
          Expanded(
            child: _ThemeChip(
              icon: Icons.light_mode_rounded,
              label: l10n.onboardingThemeLight,
              isSelected: themeManager.isLight,
              onTap: () {
                HapticFeedback.selectionClick();
                themeManager.setThemeMode(ThemeMode.light);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ThemeChip(
              icon: Icons.dark_mode_rounded,
              label: l10n.onboardingThemeDark,
              isSelected: themeManager.isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                themeManager.setThemeMode(ThemeMode.dark);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ThemeChip(
              icon: Icons.auto_mode_rounded,
              label: l10n.onboardingThemeSystem,
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

/// Map engine selection section
class _OnboardingMapSection extends StatelessWidget {
  final SettingsLocalizations l10n;

  const _OnboardingMapSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.maybeWatch(context);

    if (mapEngineManager == null || mapEngineManager.engines.isEmpty) {
      return const SizedBox.shrink();
    }

    return _OnboardingCard(
      icon: Icons.map_rounded,
      iconColor: Colors.teal,
      title: l10n.onboardingMapTitle,
      child: Column(
        children: mapEngineManager.engines.asMap().entries.map((entry) {
          final index = entry.key;
          final engine = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < mapEngineManager.engines.length - 1 ? 8 : 0,
            ),
            child: _EngineOption(
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

/// Routing engine selection section
class _OnboardingRoutingSection extends StatelessWidget {
  final SettingsLocalizations l10n;

  const _OnboardingRoutingSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final routingEngineManager = routing.RoutingEngineManager.maybeWatch(context);

    // Only show if multiple routing engines available
    if (routingEngineManager == null || !routingEngineManager.hasMultipleEngines) {
      return const SizedBox.shrink();
    }

    return _OnboardingCard(
      icon: Icons.route_rounded,
      iconColor: Colors.indigo,
      title: l10n.onboardingRoutingTitle,
      child: Column(
        children: routingEngineManager.engines.asMap().entries.map((entry) {
          final index = entry.key;
          final engine = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < routingEngineManager.engines.length - 1 ? 8 : 0,
            ),
            child: _EngineOption(
              name: engine.name,
              description: engine.description,
              icon: engine.requiresInternet
                  ? Icons.cloud_rounded
                  : Icons.offline_bolt_rounded,
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

/// Card container for onboarding sections
class _OnboardingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _OnboardingCard({
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
                    color: iconColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Language option tile
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
          ? colorScheme.primaryContainer.withAlpha(128)
          : colorScheme.surfaceContainerHighest.withAlpha(128),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withAlpha(128)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withAlpha(38)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.language_rounded,
                  size: 20,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
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
                        size: 14,
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

/// Theme option chip
class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
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
          : colorScheme.surfaceContainerHighest.withAlpha(128),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withAlpha(128)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
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
                const SizedBox(height: 4),
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

/// Engine option tile (used for map and routing engines)
class _EngineOption extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EngineOption({
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
          ? colorScheme.primaryContainer.withAlpha(128)
          : colorScheme.surfaceContainerHighest.withAlpha(128),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withAlpha(128)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withAlpha(38)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
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
                        size: 14,
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
