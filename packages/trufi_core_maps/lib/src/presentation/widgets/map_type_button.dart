import 'package:flutter/material.dart';

import '../../configuration/map_engine/trufi_map_engine.dart';
import 'map_type_option.dart';
import 'map_type_settings_screen.dart';

/// A button widget that displays a layers icon and opens a full-screen
/// map type settings popup when pressed.
///
/// Can be used with either [MapTypeOption] list or [ITrufiMapEngine] list.
/// Optionally supports additional settings like POI layers.
///
/// Example with options:
/// ```dart
/// MapTypeButton(
///   currentMapIndex: 0,
///   mapOptions: [
///     MapTypeOption(id: 'osm', name: 'OSM', description: '...'),
///   ],
///   onMapTypeChanged: (index) => setState(() => _currentIndex = index),
/// )
/// ```
///
/// Example with engines:
/// ```dart
/// MapTypeButton.fromEngines(
///   engines: [MapLibreEngine(), FlutterMapEngine()],
///   currentEngineIndex: 0,
///   onEngineChanged: (engine) => setState(() => _currentEngine = engine),
/// )
/// ```
///
/// Example with POI layers (using trufi_core_poi_layers package):
/// ```dart
/// MapTypeButton.fromEngines(
///   engines: [MapLibreEngine(), FlutterMapEngine()],
///   currentEngineIndex: 0,
///   onEngineChanged: (engine) => setState(() => _currentEngine = engine),
///   additionalSettings: BlocBuilder<POILayersCubit, POILayersState>(
///     builder: (context, state) {
///       return POILayersSettingsSection(
///         enabledCategories: state.enabledCategories,
///         onCategoryToggled: (category, enabled) {
///           context.read<POILayersCubit>().toggleCategory(category, enabled);
///         },
///         availableSubcategories: {
///           for (final cat in POICategory.values)
///             cat: context.read<POILayersCubit>().getSubcategories(cat),
///         },
///         enabledSubcategories: state.enabledSubcategories,
///         onSubcategoryToggled: (category, subcategory, enabled) {
///           context.read<POILayersCubit>().toggleSubcategory(
///             category, subcategory, enabled,
///           );
///         },
///       );
///     },
///   ),
/// )
/// ```
class MapTypeButton extends StatelessWidget {
  /// Currently selected map index.
  final int currentMapIndex;

  /// List of available map type options.
  final List<MapTypeOption> mapOptions;

  /// Callback when map type is changed by index.
  final ValueChanged<int> onMapTypeChanged;

  /// Tooltip message for the button.
  final String? tooltip;

  /// Icon to display on the button.
  final IconData icon;

  /// Icon color.
  final Color? iconColor;

  /// Background color of the button.
  final Color? backgroundColor;

  /// Size of the icon.
  final double iconSize;

  /// Border radius of the button.
  final double borderRadius;

  /// Padding inside the button.
  final EdgeInsetsGeometry padding;

  /// Title displayed in the settings screen app bar.
  final String? settingsAppBarTitle;

  /// Section title displayed above the map type list.
  final String? settingsSectionTitle;

  /// Text for the apply button in settings screen.
  final String? settingsApplyButtonText;

  /// Optional: Additional settings widget to display (e.g., POI layers).
  final Widget? additionalSettings;

  const MapTypeButton({
    super.key,
    required this.currentMapIndex,
    required this.mapOptions,
    required this.onMapTypeChanged,
    this.tooltip,
    this.icon = Icons.layers,
    this.iconColor,
    this.backgroundColor,
    this.iconSize = 24,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(12),
    this.settingsAppBarTitle,
    this.settingsSectionTitle,
    this.settingsApplyButtonText,
    this.additionalSettings,
  });

  /// Creates a MapTypeButton from a list of map engines.
  ///
  /// This factory constructor automatically converts engines to MapTypeOptions
  /// and provides a callback with the selected engine.
  ///
  /// Example:
  /// ```dart
  /// MapTypeButton.fromEngines(
  ///   engines: [
  ///     MapLibreEngine(styleString: 'https://...'),
  ///     FlutterMapEngine(),
  ///   ],
  ///   currentEngineIndex: _currentIndex,
  ///   onEngineChanged: (engine) {
  ///     setState(() => _currentEngine = engine);
  ///   },
  /// )
  /// ```
  static Widget fromEngines({
    Key? key,
    required List<ITrufiMapEngine> engines,
    required int currentEngineIndex,
    required ValueChanged<ITrufiMapEngine> onEngineChanged,
    String? tooltip,
    IconData icon = Icons.layers,
    Color? iconColor,
    Color? backgroundColor,
    double iconSize = 24,
    double borderRadius = 8,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
    String? settingsAppBarTitle,
    String? settingsSectionTitle,
    String? settingsApplyButtonText,
    Widget? additionalSettings,
  }) {
    return _MapTypeButtonFromEngines(
      key: key,
      engines: engines,
      currentEngineIndex: currentEngineIndex,
      onEngineChanged: onEngineChanged,
      tooltip: tooltip,
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      iconSize: iconSize,
      borderRadius: borderRadius,
      padding: padding,
      settingsAppBarTitle: settingsAppBarTitle,
      settingsSectionTitle: settingsSectionTitle,
      settingsApplyButtonText: settingsApplyButtonText,
      additionalSettings: additionalSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MapTypeButtonBase(
      currentMapIndex: currentMapIndex,
      mapOptions: mapOptions,
      onMapTypeChanged: onMapTypeChanged,
      tooltip: tooltip,
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      iconSize: iconSize,
      borderRadius: borderRadius,
      padding: padding,
      settingsAppBarTitle: settingsAppBarTitle,
      settingsSectionTitle: settingsSectionTitle,
      settingsApplyButtonText: settingsApplyButtonText,
      additionalSettings: additionalSettings,
    );
  }
}

/// Internal widget for engine-based MapTypeButton.
class _MapTypeButtonFromEngines extends StatelessWidget {
  final List<ITrufiMapEngine> engines;
  final int currentEngineIndex;
  final ValueChanged<ITrufiMapEngine> onEngineChanged;
  final String? tooltip;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final String? settingsAppBarTitle;
  final String? settingsSectionTitle;
  final String? settingsApplyButtonText;
  final Widget? additionalSettings;

  const _MapTypeButtonFromEngines({
    super.key,
    required this.engines,
    required this.currentEngineIndex,
    required this.onEngineChanged,
    this.tooltip,
    this.icon = Icons.layers,
    this.iconColor,
    this.backgroundColor,
    this.iconSize = 24,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(12),
    this.settingsAppBarTitle,
    this.settingsSectionTitle,
    this.settingsApplyButtonText,
    this.additionalSettings,
  });

  @override
  Widget build(BuildContext context) {
    return _MapTypeButtonBase(
      currentMapIndex: currentEngineIndex,
      mapOptions: engines.toMapTypeOptions(),
      onMapTypeChanged: (index) => onEngineChanged(engines[index]),
      tooltip: tooltip,
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      iconSize: iconSize,
      borderRadius: borderRadius,
      padding: padding,
      settingsAppBarTitle: settingsAppBarTitle,
      settingsSectionTitle: settingsSectionTitle,
      settingsApplyButtonText: settingsApplyButtonText,
      additionalSettings: additionalSettings,
    );
  }
}

/// Base widget containing the actual button UI.
class _MapTypeButtonBase extends StatelessWidget {
  final int currentMapIndex;
  final List<MapTypeOption> mapOptions;
  final ValueChanged<int> onMapTypeChanged;
  final String? tooltip;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final String? settingsAppBarTitle;
  final String? settingsSectionTitle;
  final String? settingsApplyButtonText;
  final Widget? additionalSettings;

  const _MapTypeButtonBase({
    required this.currentMapIndex,
    required this.mapOptions,
    required this.onMapTypeChanged,
    this.tooltip,
    this.icon = Icons.layers,
    this.iconColor,
    this.backgroundColor,
    this.iconSize = 24,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(12),
    this.settingsAppBarTitle,
    this.settingsSectionTitle,
    this.settingsApplyButtonText,
    this.additionalSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Tooltip(
        message: tooltip ?? 'Change map type',
        child: IconButton(
          iconSize: iconSize,
          icon: Icon(
            icon,
            color: effectiveIconColor,
          ),
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(effectiveBackgroundColor),
            padding: WidgetStatePropertyAll(padding),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          onPressed: () => _openMapTypeSettings(context),
        ),
      ),
    );
  }

  void _openMapTypeSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapTypeSettingsScreen(
          currentMapIndex: currentMapIndex,
          mapOptions: mapOptions,
          onMapTypeChanged: onMapTypeChanged,
          appBarTitle: settingsAppBarTitle,
          sectionTitle: settingsSectionTitle,
          applyButtonText: settingsApplyButtonText,
          additionalSettings: additionalSettings,
        ),
      ),
    );
  }
}
