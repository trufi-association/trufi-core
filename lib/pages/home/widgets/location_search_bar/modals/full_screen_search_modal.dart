import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/repositories/location/location_repository.dart';
import 'package:trufi_core/repositories/location/models/defaults_location.dart';
import 'package:trufi_core/repositories/services/gps_lcoation/gps_location.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/utils/icon_utils/icons.dart';
import 'package:trufi_core/widgets/maps/choose_location/choose_location.dart';

/// A full-screen modal for searching and selecting locations.
///
/// This modal provides a search interface with:
/// - Text search with autocomplete
/// - Current location selection
/// - Map picker
/// - Default locations (home, work)
/// - Custom saved places
/// - Recent search history
/// - Favorite locations
class FullScreenSearchModal extends StatefulWidget {
  /// Shows the location selection modal and returns the selected location.
  ///
  /// [context] - The build context
  /// [location] - Optional initial location to display in search
  ///
  /// Returns the selected [TrufiLocation] or null if cancelled
  static Future<TrufiLocation?> onLocationSelected(
    BuildContext context, {
    TrufiLocation? location,
  }) async {
    final defaultSearch = (location != null)
        ? location.displayName(AppLocalization.of(context))
        : '';

    return await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => FullScreenSearchModal(
          location: location,
          defaultSearch: defaultSearch,
        ),
      ),
    );
  }

  final TrufiLocation? location;
  final String defaultSearch;

  const FullScreenSearchModal({
    super.key,
    this.location,
    required this.defaultSearch,
  });

  @override
  State<FullScreenSearchModal> createState() => _FullScreenSearchModalState();
}

class _FullScreenSearchModalState extends State<FullScreenSearchModal> {
  late TextEditingController _controller;
  final _locationRepository = LocationRepository();
  String _currentSearch = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentSearch = widget.defaultSearch;
    _controller = TextEditingController(text: _currentSearch);
    _setupListeners();
    _initializeSearch();
  }

  @override
  void dispose() {
    _removeListeners();
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Sets up listeners for location repository changes
  void _setupListeners() {
    _locationRepository.searchResult.addListener(_update);
    _locationRepository.myDefaultPlaces.addListener(_update);
    _locationRepository.myPlaces.addListener(_update);
    _locationRepository.historyPlaces.addListener(_update);
    _locationRepository.favoritePlaces.addListener(_update);
  }

  /// Removes all repository listeners
  void _removeListeners() {
    _locationRepository.searchResult.removeListener(_update);
    _locationRepository.myDefaultPlaces.removeListener(_update);
    _locationRepository.myPlaces.removeListener(_update);
    _locationRepository.historyPlaces.removeListener(_update);
    _locationRepository.favoritePlaces.removeListener(_update);
  }

  /// Initializes the search with default text if provided
  void _initializeSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _locationRepository.initLoad();
      if (_currentSearch.isNotEmpty) {
        await _locationRepository.fetchLocations(_currentSearch.toLowerCase());
      }
    });
  }

  void _update() {
    if (mounted) setState(() {});
  }

  /// Sets the selected location and closes the modal
  Future<void> _setLocation({required TrufiLocation location}) async {
    await _locationRepository.insertHistoryPlace(location);
    if (mounted) Navigator.of(context).pop(location);
  }

  /// Handles search input changes with debouncing
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_currentSearch != query) {
        _currentSearch = query;
        _locationRepository.fetchLocations(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divider = Divider(
      height: 8,
      thickness: 8,
      color: theme.colorScheme.surfaceContainerHighest,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(theme),
            _buildLoadingIndicator(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (_locationRepository.searchResult.value == null)
                    _buildDefaultOptions(theme, divider),
                  _buildSearchResults(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the search bar at the top
  Widget _buildSearchBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: isDark ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: theme.colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'Search here',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchChanged,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                _locationRepository.fetchLocations('');
                setState(() {});
              },
              icon: const Icon(Icons.highlight_remove),
              color: theme.colorScheme.onSurface,
              tooltip: 'Clear',
            ),
        ],
      ),
    );
  }

  /// Builds the loading indicator
  Widget _buildLoadingIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable: _locationRepository.isLoading,
      builder: (context, loading, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? const LinearProgressIndicator(
                  key: ValueKey('progress'),
                  minHeight: 4,
                )
              : const SizedBox(key: ValueKey('noprog'), height: 4),
        );
      },
    );
  }

  /// Builds default options when no search is active
  Widget _buildDefaultOptions(ThemeData theme, Widget divider) {
    final localization = AppLocalization.of(context);

    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SearchOption(
            onTap: () => _handleCurrentLocation(context),
            title: "Your location",
            icon: const Icon(Icons.my_location),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 54,
            color: theme.dividerColor,
          ),
          _SearchOption(
            onTap: () async {
              final locationSelected = await ChooseLocationPage.selectLocation(
                context,
              );
              if (locationSelected != null) {
                _setLocation(location: locationSelected);
              }
            },
            title: "Choose on map",
            icon: const Icon(Icons.pin_drop),
          ),
          divider,
          _buildQuickActions(theme, localization),
          divider,
          _buildRecentHeader(theme),
        ],
      ),
    );
  }

  /// Builds quick action pills for default and custom places
  Widget _buildQuickActions(ThemeData theme, AppLocalization localization) {
    return SizedBox(
      height: 56,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: [
          ..._locationRepository.myDefaultPlaces.value.map(
            (place) => _QuickActionPill(
              icon: typeToIconData(
                place.type,
                color: theme.colorScheme.onSurface,
              ),
              title: localization.translate(
                DefaultLocationExt.detect(place)?.l10nKey,
              ),
              subtitle: place.isLatLngDefined
                  ? place.subTitle
                  : localization.translate(
                      LocalizationKey.defaultLocationSetLocation,
                    ),
              onTap: () => _handleDefaultPlaceSelection(place),
            ),
          ),
          ..._locationRepository.myPlaces.value.map(
            (place) => _QuickActionPill(
              icon: typeToIconData(
                place.type,
                color: theme.colorScheme.onSurface,
              ),
              title: place.description,
              subtitle: place.address ?? '',
              onTap: () => _setLocation(location: place),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles selection of default places (home, work)
  Future<void> _handleDefaultPlaceSelection(TrufiLocation place) async {
    if (place.isLatLngDefined) {
      _setLocation(location: place);
    } else {
      final locationSelected = await ChooseLocationPage.selectLocation(
        context,
        hideLocationDetails: true,
      );
      if (locationSelected != null) {
        await _locationRepository.updateMyDefaultPlace(
          place,
          place.copyWith(position: locationSelected.position),
        );
      }
    }
  }

  /// Handles current location selection
  Future<void> _handleCurrentLocation(BuildContext context) async {
    try {
      // Import GPS location service
      final gpsProvider = GPSLocationProvider();
      
      // Try to get current location
      await gpsProvider.start(context: context);
      final currentPosition = gpsProvider.current;
      
      if (currentPosition != null) {
        // Perform reverse geocoding to get address
        final location = await _locationRepository.reverseGeodecoding(
          currentPosition,
        );
        
        // Override description to indicate it's current location
        final currentLocation = TrufiLocation(
          description: 'Your Location',
          position: currentPosition,
          address: location.address,
          type: TrufiLocationType.currentLocation,
        );
        
        _setLocation(location: currentLocation);
      } else {
        // If location is not available, show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not get current location. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  /// Builds the recent search header
  Widget _buildRecentHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Builds the search results list
  Widget _buildSearchResults(ThemeData theme) {
    return SliverList.list(
      children: [
        if (_locationRepository.searchResult.value != null)
          if (_locationRepository.searchResult.value!.isNotEmpty)
            ..._locationRepository.searchResult.value!.map(
              (location) => _PlaceTile(
                location: location,
                onTap: () => _setLocation(location: location),
              ),
            )
          else
            _buildNoResults(theme)
        else ...[
          ..._locationRepository.historyPlaces.value.reversed.map(
            (location) => _PlaceTile(
              location: location,
              onTap: () => _setLocation(location: location),
            ),
          ),
          ..._locationRepository.favoritePlaces.value.reversed.map(
            (location) => _PlaceTile(
              location: location,
              onTap: () => _setLocation(location: location),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the no results widget
  Widget _buildNoResults(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Text(
          'No results found',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// A widget representing a search option with icon and title.
class _SearchOption extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  const _SearchOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      visualDensity: VisualDensity.compact,
      horizontalTitleGap: 12,
      onTap: onTap,
      minVerticalPadding: 12,
      leading: CircleAvatar(
        radius: 15,
        backgroundColor: isDark 
            ? theme.colorScheme.surfaceContainerHighest 
            : theme.colorScheme.primaryContainer,
        child: SizedBox(width: 18, height: 18, child: FittedBox(child: icon)),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// A quick action pill widget for frequently used locations.
class _QuickActionPill extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _QuickActionPill({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isDark 
                  ? theme.colorScheme.surfaceContainerHighest 
                  : theme.colorScheme.primaryContainer,
              child: SizedBox(
                width: 18,
                height: 18,
                child: FittedBox(child: icon),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tile widget representing a place in the search results or history.
class _PlaceTile extends StatelessWidget {
  final TrufiLocation location;
  final VoidCallback onTap;

  const _PlaceTile({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = location.displayName(AppLocalization.of(context));
    final subtitle = location.subTitle;

    return Column(
      children: [
        ListTile(
          visualDensity: VisualDensity.compact,
          horizontalTitleGap: 12,
          onTap: onTap,
          minVerticalPadding: subtitle.isNotEmpty ? 12 : 20,
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            radius: 15,
            child: typeToIconData(
              location.type,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1,
                  ),
                )
              : null,
        ),
        Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 54,
          color: theme.dividerColor,
        ),
      ],
    );
  }
}
