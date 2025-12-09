import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../core/l10n/core_localizations.dart';
import '../home/l10n/home_localizations.dart';
import '../search/l10n/search_localizations.dart';
import 'l10n/settings_localizations.dart';

/// Settings screen module
class SettingsTrufiScreen extends TrufiScreen {
  @override
  String get id => 'settings';

  @override
  String get path => '/settings';

  @override
  Widget Function(BuildContext context) get builder => (_) => const _SettingsScreen();

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
  String getLocalizedTitle(BuildContext context) {
    return SettingsLocalizations.of(context).settingsTitle;
  }
}

/// Settings screen widget
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    final settingsL10n = SettingsLocalizations.of(context);
    final coreL10n = CoreLocalizations.of(context);
    final homeL10n = HomeLocalizations.of(context);
    final searchL10n = SearchLocalizations.of(context);
    final localeManager = LocaleManager.read(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language settings card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.translate, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        settingsL10n.settingsLanguage,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settingsL10n.settingsSelectLanguage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: localeManager,
                    builder: (context, child) {
                      return Column(
                        children: [
                          _LanguageOption(
                            languageCode: 'en',
                            languageName: 'English',
                            flag: '🇬🇧',
                            isSelected:
                                localeManager.currentLocale.languageCode == 'en',
                            onSelect: () => localeManager.setLocaleByCode('en'),
                          ),
                          _LanguageOption(
                            languageCode: 'es',
                            languageName: 'Español',
                            flag: '🇪🇸',
                            isSelected:
                                localeManager.currentLocale.languageCode == 'es',
                            onSelect: () => localeManager.setLocaleByCode('es'),
                          ),
                          _LanguageOption(
                            languageCode: 'de',
                            languageName: 'Deutsch',
                            flag: '🇩🇪',
                            isSelected:
                                localeManager.currentLocale.languageCode == 'de',
                            onSelect: () => localeManager.setLocaleByCode('de'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dynamic translation demo card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Text(
                        settingsL10n.settingsTranslationDemo,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue[700],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    settingsL10n.settingsTranslationDemoDesc,
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 16),
                  _TranslationDemo(
                    key_: 'coreL10n.navHome',
                    value: coreL10n.navHome,
                  ),
                  _TranslationDemo(
                    key_: 'coreL10n.navSearch',
                    value: coreL10n.navSearch,
                  ),
                  _TranslationDemo(
                    key_: 'coreL10n.navSettings',
                    value: coreL10n.navSettings,
                  ),
                  _TranslationDemo(
                    key_: 'homeL10n.homeTitle',
                    value: homeL10n.homeTitle,
                  ),
                  _TranslationDemo(
                    key_: 'searchL10n.searchOrigin',
                    value: searchL10n.searchOrigin,
                  ),
                  _TranslationDemo(
                    key_: 'searchL10n.searchDestination',
                    value: searchL10n.searchDestination,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Theme settings card (placeholder)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        settingsL10n.settingsTheme,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.light_mode),
                    title: Text(settingsL10n.settingsThemeLight),
                    trailing: Radio<String>(
                      value: 'light',
                      groupValue: 'light',
                      onChanged: (value) {},
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: Text(settingsL10n.settingsThemeDark),
                    trailing: Radio<String>(
                      value: 'dark',
                      groupValue: 'light',
                      onChanged: (value) {},
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_system_daydream),
                    title: Text(settingsL10n.settingsThemeSystem),
                    trailing: Radio<String>(
                      value: 'system',
                      groupValue: 'light',
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Theme switching is a placeholder for this POC.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Module info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.extension, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        settingsL10n.settingsRegisteredModules,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('AppModule'),
                  ),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('HomeScreen'),
                  ),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('SearchScreen'),
                  ),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('FeedbackScreen'),
                  ),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('SettingsScreen'),
                  ),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('AboutScreen'),
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

class _LanguageOption extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String flag;
  final bool isSelected;
  final VoidCallback onSelect;

  const _LanguageOption({
    required this.languageCode,
    required this.languageName,
    required this.flag,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(languageName),
      subtitle: Text(languageCode.toUpperCase()),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      selected: isSelected,
      onTap: onSelect,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _TranslationDemo extends StatelessWidget {
  final String key_;
  final String value;

  const _TranslationDemo({
    required this.key_,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key_,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.blue[700],
                fontSize: 12,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward, size: 16),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
