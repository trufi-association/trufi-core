import 'package:flutter/material.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import 'models/transport_route.dart';
import 'transport_list_data_provider.dart';

/// Data provider that connects to OpenTripPlanner to fetch transport routes
class OtpTransportDataProvider extends TransportListDataProvider {
  final OtpConfiguration _otpConfiguration;
  final TransitRouteRepository? _repository;

  TransportListState _state = const TransportListState();

  /// Cache of full route details (with geometry and stops)
  final Map<String, TransportRouteDetails> _detailsCache = {};

  OtpTransportDataProvider({
    required OtpConfiguration otpConfiguration,
  })  : _otpConfiguration = otpConfiguration,
        _repository = otpConfiguration.createTransitRouteRepository();

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

    try {
      await refresh();
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
        'Transit routes are not supported for OTP ${_otpConfiguration.version}',
      );
    }

    _state = _state.copyWith(isLoading: true);
    _notifySafe();

    try {
      final patterns = await _repository.fetchPatterns();

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

      _state = _state.copyWith(
        routes: routes,
        filteredRoutes: routes,
        isLoading: false,
      );
      _notifySafe();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      _notifySafe();
      rethrow;
    }
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
    if (_repository == null) return null;

    // Check cache first
    if (_detailsCache.containsKey(code)) {
      return _detailsCache[code];
    }

    _state = _state.copyWith(isLoadingDetails: true);
    _notifySafe();

    try {
      final pattern = await _repository.fetchPatternById(code);
      final details = _convertToTransportRouteDetails(pattern);

      // Cache the result
      _detailsCache[code] = details;

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

    IconData iconData;
    switch (mode) {
      case TransportMode.bus:
        iconData = Icons.directions_bus;
        break;
      case TransportMode.tram:
        iconData = Icons.tram;
        break;
      case TransportMode.subway:
        iconData = Icons.subway;
        break;
      case TransportMode.rail:
        iconData = Icons.train;
        break;
      case TransportMode.ferry:
        iconData = Icons.directions_ferry;
        break;
      case TransportMode.gondola:
      case TransportMode.cableCar:
        iconData = Icons.airline_seat_recline_extra;
        break;
      case TransportMode.funicular:
        iconData = Icons.terrain;
        break;
      default:
        iconData = Icons.directions_transit;
    }

    return Icon(iconData, size: 16, color: Colors.white);
  }
}
