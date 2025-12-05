import 'package:flutter/material.dart';

import '../models/search_location.dart';
import '../services/search_location_service.dart';

/// Configuration for [LocationSearchScreen].
class LocationSearchScreenConfiguration {
  /// Hint text for origin search.
  final String originHintText;

  /// Hint text for destination search.
  final String destinationHintText;

  /// Text for "Your Location" option.
  final String yourLocationText;

  /// Text for "Choose on Map" option.
  final String chooseOnMapText;

  /// Title for "Your Places" section.
  final String yourPlacesTitle;

  /// Title for "Search Results" section.
  final String searchResultsTitle;

  /// Text shown when no results are found.
  final String noResultsText;

  /// Icon for "Your Location" option.
  final IconData yourLocationIcon;

  /// Icon for "Choose on Map" option.
  final IconData chooseOnMapIcon;

  /// Icon builder for places. Returns icon based on location id.
  final IconData Function(String id)? placeIconBuilder;

  const LocationSearchScreenConfiguration({
    this.originHintText = 'Search origin...',
    this.destinationHintText = 'Search destination...',
    this.yourLocationText = 'Your Location',
    this.chooseOnMapText = 'Choose on Map',
    this.yourPlacesTitle = 'YOUR PLACES',
    this.searchResultsTitle = 'SEARCH RESULTS',
    this.noResultsText = 'No results found',
    this.yourLocationIcon = Icons.gps_fixed,
    this.chooseOnMapIcon = Icons.map,
    this.placeIconBuilder,
  });
}

/// A search screen with Your Location, Choose on Map, Your Places, and search results.
///
/// Returns a [SearchLocation] when a location is selected.
class LocationSearchScreen extends StatefulWidget {
  /// Whether searching for origin (true) or destination (false).
  final bool isOrigin;

  /// List of saved/favorite places to show.
  final List<SearchLocation> myPlaces;

  /// Callback to get current location.
  final SearchLocation Function()? onYourLocation;

  /// Callback to open map picker.
  final Future<SearchLocation?> Function()? onChooseOnMap;

  /// Search service to use (Photon, Nominatim, or custom).
  final SearchLocationService searchService;

  /// Configuration for text and icons.
  final LocationSearchScreenConfiguration configuration;

  const LocationSearchScreen({
    super.key,
    required this.isOrigin,
    this.myPlaces = const [],
    this.onYourLocation,
    this.onChooseOnMap,
    required this.searchService,
    this.configuration = const LocationSearchScreenConfiguration(),
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  List<SearchLocation> _searchResults = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await widget.searchService.search(query);
      if (mounted && _query == query) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.configuration;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.isOrigin
                ? config.originHintText
                : config.destinationHintText,
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
            _performSearch(value);
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _searchResults = [];
                });
              },
            ),
        ],
      ),
      body: ListView(
        children: [
          // Your Location
          if (widget.onYourLocation != null)
            _buildSectionItem(
              icon: config.yourLocationIcon,
              title: config.yourLocationText,
              onTap: () {
                final location = widget.onYourLocation!();
                Navigator.pop(context, location);
              },
            ),

          // Choose on Map
          if (widget.onChooseOnMap != null)
            _buildSectionItem(
              icon: config.chooseOnMapIcon,
              title: config.chooseOnMapText,
              onTap: () async {
                final location = await widget.onChooseOnMap!();
                if (location != null && context.mounted) {
                  Navigator.pop(context, location);
                }
              },
            ),

          if (widget.onYourLocation != null || widget.onChooseOnMap != null)
            const Divider(),

          // Your Places section
          if (_query.isEmpty && widget.myPlaces.isNotEmpty) ...[
            _buildSectionTitle(config.yourPlacesTitle),
            ...widget.myPlaces.map((place) => _buildLocationItem(place)),
            const Divider(),
          ],

          // Search Results
          if (_query.isNotEmpty) ...[
            _buildSectionTitle(config.searchResultsTitle),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(config.noResultsText),
              )
            else
              ..._searchResults.map((loc) => _buildLocationItem(loc)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSectionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildLocationItem(SearchLocation location) {
    return ListTile(
      leading: Icon(
        _getIconForPlace(location),
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(location.displayName),
      subtitle: location.address != null ? Text(location.address!) : null,
      onTap: () => Navigator.pop(context, location),
    );
  }

  IconData _getIconForPlace(SearchLocation location) {
    if (widget.configuration.placeIconBuilder != null) {
      return widget.configuration.placeIconBuilder!(location.id);
    }
    switch (location.id) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.place;
    }
  }
}
