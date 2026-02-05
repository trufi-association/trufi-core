import 'package:flutter/material.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import 'models/transport_route.dart';
import 'repository/transport_list_cache.dart';
import 'transport_list_data_provider.dart';

/// Data provider that fetches transport routes from a routing provider.
///
/// Supports optional [cache] parameter for persisting routes between sessions.
/// When cache is provided:
/// - Routes are loaded from cache first (instant display)
/// - Network fetch only happens on explicit refresh
/// - Cache is invalidated when [providerId] changes (e.g., switching from OTP to GTFS)
class OtpTransportDataProvider extends TransportListDataProvider {
  final TransitRouteRepository? _repository;
  final TransportListCache? _cache;
  final String? _providerId;

  // Start with isLoading=true so shimmer shows immediately
  TransportListState _state = const TransportListState(isLoading: true);

  /// In-memory cache of full route details (with geometry and stops)
  final Map<String, TransportRouteDetails> _detailsCache = {};

  OtpTransportDataProvider({
    required TransitRouteRepository? repository,
    TransportListCache? cache,
    String? providerId,
  })  : _repository = repository,
        _cache = cache,
        _providerId = providerId;

  /// Creates a data provider from an OtpConfiguration (legacy).
  @Deprecated('Use the repository constructor instead')
  factory OtpTransportDataProvider.fromOtpConfiguration({
    required OtpConfiguration otpConfiguration,
    TransportListCache? cache,
  }) {
    return OtpTransportDataProvider(
      repository: otpConfiguration.createTransitRouteRepository(),
      cache: cache,
    );
  }

  @override
  TransportListState get state => _state;

  @override
  Future<void> load() async {
    if (_repository == null) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return;
    }

    if (_state.routes.isNotEmpty) return;

    _state = _state.copyWith(isLoading: true);
    _notifySafe();

    // Try loading from cache first
    if (_cache != null) {
      try {
        // Check if cache is from the same provider
        if (_providerId != null) {
          final isValidCache = await _cache.isValidForProvider(_providerId);
          if (!isValidCache) {
            debugPrint('OtpTransportDataProvider.load: Cache is from different provider, clearing...');
            await _cache.clearRoutesCache();
          }
        }

        final cachedRoutes = await _cache.getCachedRoutes();
        if (cachedRoutes != null && cachedRoutes.isNotEmpty) {
          debugPrint('OtpTransportDataProvider.load: Loaded ${cachedRoutes.length} routes from cache');
          debugPrint('OtpTransportDataProvider.load: First 5 route codes: ${cachedRoutes.take(5).map((r) => r.code).toList()}');
          final routes = cachedRoutes.map(_convertCachedToTransportRoute).toList();
          _state = _state.copyWith(
            routes: routes,
            filteredRoutes: routes,
            isLoading: false,
          );
          _notifySafe();
          return; // Loaded from cache, no network needed
        }
      } catch (e) {
        debugPrint('OtpTransportDataProvider: Error loading from cache: $e');
      }
    }

    // No cache, fetch from network
    try {
      await _fetchAndCacheRoutes();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      _notifySafe();
      rethrow;
    }
  }

  @override
  Future<void> refresh() async {
    if (_repository == null) {
      throw UnsupportedError(
        'Transit routes are not supported by the current routing provider',
      );
    }

    _state = _state.copyWith(isLoading: true);
    _notifySafe();

    try {
      await _fetchAndCacheRoutes();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      _notifySafe();
      rethrow;
    }
  }

  /// Fetch routes from network and save to cache.
  Future<void> _fetchAndCacheRoutes() async {
    debugPrint('OtpTransportDataProvider._fetchAndCacheRoutes: Fetching from ${_repository.runtimeType}');
    final patterns = await _repository!.fetchPatterns();
    debugPrint('OtpTransportDataProvider._fetchAndCacheRoutes: Got ${patterns.length} patterns');
    debugPrint('OtpTransportDataProvider._fetchAndCacheRoutes: First 5 codes: ${patterns.take(5).map((p) => p.code).toList()}');

    // Sort routes by shortName (numeric first, then alphabetic)
    patterns.sort((a, b) {
      final aShortName = int.tryParse(a.route?.shortName ?? '');
      final bShortName = int.tryParse(b.route?.shortName ?? '');

      if (aShortName != null && bShortName != null) {
        return aShortName.compareTo(bShortName);
      } else if (aShortName == null && bShortName == null) {
        return (a.route?.shortName ?? '').compareTo(b.route?.shortName ?? '');
      } else if (aShortName != null) {
        return -1;
      }
      return 1;
    });

    final routes = patterns.map(_convertToTransportRoute).toList();

    // Cache the patterns if cache is available
    if (_cache != null) {
      try {
        final cachedPatterns = patterns.map(_convertToCachedPattern).toList();
        await _cache.cacheRoutes(cachedPatterns);
        // Save provider ID so we can invalidate cache when provider changes
        if (_providerId != null) {
          await _cache.cacheProviderId(_providerId);
        }
      } catch (e) {
        debugPrint('OtpTransportDataProvider: Error caching routes: $e');
      }
    }

    _state = _state.copyWith(
      routes: routes,
      filteredRoutes: routes,
      isLoading: false,
    );
    _notifySafe();
  }

  @override
  void filter(String query) {
    if (query.isEmpty) {
      _state = _state.copyWith(filteredRoutes: _state.routes);
    } else {
      final lowerQuery = query.toLowerCase();
      final filtered = _state.routes.where((route) {
        final searchText =
            '${route.name} ${route.shortName ?? ''} ${route.longName ?? ''}'
                .toLowerCase();
        return searchText.contains(lowerQuery);
      }).toList();
      _state = _state.copyWith(filteredRoutes: filtered);
    }
    _notifySafe();
  }

  @override
  Future<TransportRouteDetails?> getRouteDetails(String code) async {
    debugPrint('OtpTransportDataProvider.getRouteDetails: code=$code');
    debugPrint('OtpTransportDataProvider.getRouteDetails: repository type=${_repository.runtimeType}');

    if (_repository == null) return null;

    // Check in-memory cache first
    if (_detailsCache.containsKey(code)) {
      debugPrint('OtpTransportDataProvider.getRouteDetails: Found in memory cache');
      return _detailsCache[code];
    }

    // Check persistent cache
    if (_cache != null) {
      try {
        final cachedDetails = await _cache.getCachedDetails(code);
        if (cachedDetails != null) {
          final details = _convertCachedToTransportRouteDetails(cachedDetails);
          _detailsCache[code] = details;
          return details;
        }
      } catch (e) {
        debugPrint('OtpTransportDataProvider: Error loading cached details: $e');
      }
    }

    _state = _state.copyWith(isLoadingDetails: true);
    _notifySafe();

    try {
      final pattern = await _repository.fetchPatternById(code);
      final details = _convertToTransportRouteDetails(pattern);

      // Cache the result in memory
      _detailsCache[code] = details;

      // Cache to persistent storage
      if (_cache != null) {
        try {
          await _cache.cacheDetails(code, _convertToCachedDetails(pattern));
        } catch (e) {
          debugPrint('OtpTransportDataProvider: Error caching details: $e');
        }
      }

      _state = _state.copyWith(isLoadingDetails: false);
      _notifySafe();

      return details;
    } catch (e) {
      _state = _state.copyWith(isLoadingDetails: false);
      _notifySafe();
      rethrow;
    }
  }

  /// Safely notify listeners (deferred to next frame to avoid build errors)
  void _notifySafe() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // ============ Conversion methods ============

  /// Convert routing TransitRoute to transport_list TransportRoute
  TransportRoute _convertToTransportRoute(TransitRoute route) {
    return TransportRoute(
      id: route.id,
      code: route.code,
      name: route.name,
      shortName: route.route?.shortName,
      longName: route.route?.longName,
      backgroundColor: _parseColor(route.route?.color),
      textColor: _parseColor(route.route?.textColor),
      modeIcon: _getModeIcon(route.route?.mode),
    );
  }

  /// Convert routing TransitRoute to transport_list TransportRouteDetails
  TransportRouteDetails _convertToTransportRouteDetails(TransitRoute route) {
    return TransportRouteDetails(
      id: route.id,
      code: route.code,
      name: route.name,
      shortName: route.route?.shortName,
      longName: route.route?.longName,
      backgroundColor: _parseColor(route.route?.color),
      textColor: _parseColor(route.route?.textColor),
      modeIcon: _getModeIcon(route.route?.mode),
      modeName: route.route?.mode?.name,
      geometry: route.geometry
          ?.map((latLng) => (
                latitude: latLng.latitude,
                longitude: latLng.longitude,
              ))
          .toList(),
      stops: route.stops
          ?.map((stop) => TransportStop(
                id: stop.name,
                name: stop.name,
                latitude: stop.lat,
                longitude: stop.lon,
              ))
          .toList(),
    );
  }

  /// Convert TransitRoute to CachedRoutePattern for storage
  CachedRoutePattern _convertToCachedPattern(TransitRoute route) {
    return CachedRoutePattern(
      id: route.id,
      code: route.code,
      name: route.name,
      shortName: route.route?.shortName,
      longName: route.route?.longName,
      color: route.route?.color,
      textColor: route.route?.textColor,
      mode: route.route?.mode?.name,
    );
  }

  /// Convert TransitRoute to CachedRouteDetails for storage
  CachedRouteDetails _convertToCachedDetails(TransitRoute route) {
    return CachedRouteDetails(
      id: route.id,
      code: route.code,
      name: route.name,
      shortName: route.route?.shortName,
      longName: route.route?.longName,
      color: route.route?.color,
      textColor: route.route?.textColor,
      mode: route.route?.mode?.name,
      geometry: route.geometry
          ?.map((latLng) => CachedLatLng(
                latitude: latLng.latitude,
                longitude: latLng.longitude,
              ))
          .toList(),
      stops: route.stops
          ?.map((stop) => CachedStop(
                id: stop.name,
                name: stop.name,
                latitude: stop.lat,
                longitude: stop.lon,
              ))
          .toList(),
    );
  }

  /// Convert CachedRoutePattern to TransportRoute
  TransportRoute _convertCachedToTransportRoute(CachedRoutePattern cached) {
    return TransportRoute(
      id: cached.id,
      code: cached.code,
      name: cached.name,
      shortName: cached.shortName,
      longName: cached.longName,
      backgroundColor: _parseColor(cached.color),
      textColor: _parseColor(cached.textColor),
      modeIcon: _getModeIconFromString(cached.mode),
    );
  }

  /// Convert CachedRouteDetails to TransportRouteDetails
  TransportRouteDetails _convertCachedToTransportRouteDetails(
      CachedRouteDetails cached) {
    return TransportRouteDetails(
      id: cached.id,
      code: cached.code,
      name: cached.name,
      shortName: cached.shortName,
      longName: cached.longName,
      backgroundColor: _parseColor(cached.color),
      textColor: _parseColor(cached.textColor),
      modeIcon: _getModeIconFromString(cached.mode),
      modeName: cached.mode,
      geometry: cached.geometry
          ?.map((latLng) => (
                latitude: latLng.latitude,
                longitude: latLng.longitude,
              ))
          .toList(),
      stops: cached.stops
          ?.map((stop) => TransportStop(
                id: stop.id,
                name: stop.name,
                latitude: stop.latitude,
                longitude: stop.longitude,
              ))
          .toList(),
    );
  }

  /// Parse hex color string to Color
  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Get icon widget for transport mode
  Widget? _getModeIcon(TransportMode? mode) {
    if (mode == null) return null;
    return _getModeIconFromString(mode.name);
  }

  /// Get icon widget for transport mode from string name
  Widget? _getModeIconFromString(String? modeName) {
    if (modeName == null) return null;

    IconData iconData;
    switch (modeName.toLowerCase()) {
      case 'bus':
        iconData = Icons.directions_bus;
        break;
      case 'tram':
        iconData = Icons.tram;
        break;
      case 'subway':
        iconData = Icons.subway;
        break;
      case 'rail':
        iconData = Icons.train;
        break;
      case 'ferry':
        iconData = Icons.directions_ferry;
        break;
      case 'gondola':
      case 'cablecar':
        iconData = Icons.airline_seat_recline_extra;
        break;
      case 'funicular':
        iconData = Icons.terrain;
        break;
      default:
        iconData = Icons.directions_transit;
    }

    return Icon(iconData, size: 16, color: Colors.white);
  }
}
