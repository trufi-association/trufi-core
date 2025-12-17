import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

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

  /// List of saved/favorite places to show (static list).
  /// If [myPlacesProvider] is provided, this will be ignored.
  final List<SearchLocation> myPlaces;

  /// Provider for saved/favorite places (dynamic).
  /// If provided, places will be loaded from this provider instead of [myPlaces].
  final MyPlacesProvider? myPlacesProvider;

  /// Callback to get current location.
  /// This is async to support GPS location retrieval.
  final Future<SearchLocation?> Function()? onYourLocation;

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
    this.myPlacesProvider,
    this.onYourLocation,
    this.onChooseOnMap,
    required this.searchService,
    this.configuration = const LocationSearchScreenConfiguration(),
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _staggerController;

  String _query = '';
  List<SearchLocation> _searchResults = [];
  bool _isSearching = false;
  List<SearchLocation> _loadedPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
      _searchFocusNode.requestFocus();
    });
  }

  Future<void> _loadPlaces() async {
    if (widget.myPlacesProvider != null) {
      final places = await widget.myPlacesProvider!.getMyPlaces();
      if (mounted) {
        setState(() {
          _loadedPlaces = places.map(_myPlaceToSearchLocation).toList();
        });
      }
    } else {
      setState(() {
        _loadedPlaces = widget.myPlaces;
      });
    }
  }

  List<SearchLocation> get _myPlaces => _loadedPlaces;

  SearchLocation _myPlaceToSearchLocation(MyPlace place) {
    return SearchLocation(
      id: place.placeType == MyPlaceType.home
          ? 'home'
          : place.placeType == MyPlaceType.work
              ? 'work'
              : place.id,
      displayName: place.name,
      address: place.address,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

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

  Widget _buildAnimatedItem({
    required int index,
    required Widget child,
    int totalItems = 8,
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
          offset: Offset(0, 16 * (1 - animation.value)),
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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = widget.configuration;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Modern header with search field
            _buildAnimatedItem(
              index: 0,
              child: _SearchHeader(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: widget.isOrigin
                    ? config.originHintText
                    : config.destinationHintText,
                query: _query,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                  _performSearch(value);
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                    _searchResults = [];
                  });
                },
                onBack: () => Navigator.pop(context),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),

                  // Quick actions (Your Location, Choose on Map)
                  if (widget.onYourLocation != null ||
                      widget.onChooseOnMap != null) ...[
                    _buildAnimatedItem(
                      index: 1,
                      child: _QuickActionsSection(
                        onYourLocation: widget.onYourLocation != null
                            ? () async {
                                HapticFeedback.lightImpact();
                                final location = await widget.onYourLocation!();
                                if (location != null && context.mounted) {
                                  Navigator.pop(context, location);
                                }
                              }
                            : null,
                        onChooseOnMap: widget.onChooseOnMap != null
                            ? () async {
                                HapticFeedback.lightImpact();
                                final location = await widget.onChooseOnMap!();
                                if (location != null && context.mounted) {
                                  Navigator.pop(context, location);
                                }
                              }
                            : null,
                        yourLocationText: config.yourLocationText,
                        chooseOnMapText: config.chooseOnMapText,
                        yourLocationIcon: config.yourLocationIcon,
                        chooseOnMapIcon: config.chooseOnMapIcon,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Your Places section
                  if (_query.isEmpty && _myPlaces.isNotEmpty) ...[
                    _buildAnimatedItem(
                      index: 2,
                      child: _SectionTitle(title: config.yourPlacesTitle),
                    ),
                    const SizedBox(height: 8),
                    _buildAnimatedItem(
                      index: 3,
                      child: _YourPlacesSection(
                        places: _myPlaces,
                        getIconForPlace: _getIconForPlace,
                        getColorForPlace: _getColorForPlace,
                        onPlaceSelected: (place) {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context, place);
                        },
                      ),
                    ),
                  ],

                  // Search Results
                  if (_query.isNotEmpty) ...[
                    _SectionTitle(title: config.searchResultsTitle),
                    const SizedBox(height: 8),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_searchResults.isEmpty)
                      _EmptySearchResults(text: config.noResultsText)
                    else
                      ...List.generate(_searchResults.length, (index) {
                        final location = _searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ModernLocationTile(
                            location: location,
                            icon: Icons.place_rounded,
                            iconColor: colorScheme.primary,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context, location);
                            },
                          ),
                        );
                      }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPlace(SearchLocation location) {
    if (widget.configuration.placeIconBuilder != null) {
      return widget.configuration.placeIconBuilder!(location.id);
    }
    switch (location.id) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getColorForPlace(SearchLocation location) {
    switch (location.id) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}

/// Modern search header with back button and search field
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.query,
    required this.onChanged,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Back button
          Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onBack();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Search field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                  if (query.isNotEmpty) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onClear,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions section (Your Location, Choose on Map)
class _QuickActionsSection extends StatelessWidget {
  final VoidCallback? onYourLocation;
  final VoidCallback? onChooseOnMap;
  final String yourLocationText;
  final String chooseOnMapText;
  final IconData yourLocationIcon;
  final IconData chooseOnMapIcon;

  const _QuickActionsSection({
    this.onYourLocation,
    this.onChooseOnMap,
    required this.yourLocationText,
    required this.chooseOnMapText,
    required this.yourLocationIcon,
    required this.chooseOnMapIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          if (onYourLocation != null)
            _QuickActionItem(
              icon: yourLocationIcon,
              iconColor: Colors.blue,
              title: yourLocationText,
              onTap: onYourLocation!,
              isFirst: true,
              isLast: onChooseOnMap == null,
            ),
          if (onYourLocation != null && onChooseOnMap != null)
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          if (onChooseOnMap != null)
            _QuickActionItem(
              icon: chooseOnMapIcon,
              iconColor: Colors.green,
              title: chooseOnMapText,
              onTap: onChooseOnMap!,
              isFirst: onYourLocation == null,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

/// Single quick action item
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _QuickActionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
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

/// Your Places section (grouped in a single card)
class _YourPlacesSection extends StatelessWidget {
  final List<SearchLocation> places;
  final IconData Function(SearchLocation) getIconForPlace;
  final Color Function(SearchLocation) getColorForPlace;
  final ValueChanged<SearchLocation> onPlaceSelected;

  const _YourPlacesSection({
    required this.places,
    required this.getIconForPlace,
    required this.getColorForPlace,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: List.generate(places.length, (index) {
          final place = places[index];
          final isFirst = index == 0;
          final isLast = index == places.length - 1;

          return Column(
            children: [
              _YourPlaceItem(
                location: place,
                icon: getIconForPlace(place),
                iconColor: getColorForPlace(place),
                onTap: () => onPlaceSelected(place),
                isFirst: isFirst,
                isLast: isLast,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 60,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// Single place item in the Your Places section
class _YourPlaceItem extends StatelessWidget {
  final SearchLocation location;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _YourPlaceItem({
    required this.location,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.address != null &&
                        location.address!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        location.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

/// Section title
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Modern location tile
class _ModernLocationTile extends StatelessWidget {
  final SearchLocation location;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModernLocationTile({
    required this.location,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.address != null &&
                        location.address!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        location.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty search results state
class _EmptySearchResults extends StatelessWidget {
  final String text;

  const _EmptySearchResults({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
