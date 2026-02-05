import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../l10n/transport_list_localizations.dart';
import 'otp_transport_data_provider.dart';
import 'repository/transport_list_cache.dart';
import 'transport_detail_screen.dart';
import 'transport_list_content.dart';
import 'transport_list_data_provider.dart';

/// Transport List screen module for TrufiApp integration with OTP and Map support.
///
/// Uses the current routing provider from [RoutingEngineManager] to fetch
/// transit routes. If the current provider doesn't support transit routes,
/// it will try to find an online provider that does.
class TransportListTrufiScreen extends TrufiScreen {
  TransportListTrufiScreen();

  @override
  String get id => 'transport_list';

  @override
  String get path => '/routes';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => const _TransportListScreenWidget();

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    ...TransportListLocalizations.localizationsDelegates,
  ];

  @override
  List<Locale> get supportedLocales =>
      TransportListLocalizations.supportedLocales;

  @override
  List<SingleChildWidget> get providers => [];

  @override
  bool get hasOwnAppBar => true;

  @override
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.directions_bus, order: 1);

  @override
  String getLocalizedTitle(BuildContext context) {
    return TransportListLocalizations.of(context).menuTransportList;
  }
}

class _TransportListScreenWidget extends StatefulWidget {
  const _TransportListScreenWidget();

  @override
  State<_TransportListScreenWidget> createState() =>
      _TransportListScreenWidgetState();
}

class _TransportListScreenWidgetState
    extends State<_TransportListScreenWidget> {
  TransportListDataProvider? _dataProvider;
  TransportListCache? _cache;
  bool _urlParsed = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize data provider with routing engine from context
    if (!_initialized) {
      _initialized = true;
      _initializeDataProvider();
    }

    // Parse URL parameters on first load (web only)
    _parseUrlAndOpenRoute();
  }

  void _initializeDataProvider() {
    _cache = TransportListCache();
    _cache!.initialize();

    // Get the transit route repository from the routing engine manager
    final routingManager = RoutingEngineManager.read(context);
    TransitRouteRepository? repository;
    String? providerId;

    // Try current engine first
    if (routingManager.currentEngine.supportsTransitRoutes) {
      repository = routingManager.currentEngine.createTransitRouteRepository();
      providerId = routingManager.currentEngine.id;
    } else {
      // Fallback: find any engine that supports transit routes
      for (final engine in routingManager.engines) {
        if (engine.supportsTransitRoutes) {
          repository = engine.createTransitRouteRepository();
          providerId = engine.id;
          break;
        }
      }
    }

    _dataProvider = OtpTransportDataProvider(
      repository: repository,
      cache: _cache,
      providerId: providerId,
    );
  }

  @override
  void dispose() {
    _dataProvider?.dispose();
    _cache?.dispose();
    super.dispose();
  }

  /// Parses URL parameters and opens route detail if id is present (web only).
  /// Only runs on initial page load, not when URL is updated programmatically.
  void _parseUrlAndOpenRoute() {
    if (!kIsWeb || _urlParsed || _dataProvider == null) return;
    _urlParsed = true;

    try {
      final routerState = GoRouterState.of(context);
      final params = routerState.uri.queryParameters;
      final routeId = params['id'];

      if (routeId != null && routeId.isNotEmpty) {
        // Only open if this is the current route (not if we're being navigated away from)
        // Check if TransportDetailScreen is already being shown
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          // Already have screens on top, don't open another one
          return;
        }

        // Open route detail screen after frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          TransportDetailScreen.show(context, routeCode: routeId);
        });
      }
    } catch (e) {
      debugPrint('TransportListScreen: Error parsing URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = _dataProvider;
    if (dataProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return TransportListContent(
      dataProvider: dataProvider,
      onRouteTap: (route) {
        TransportDetailScreen.show(context, routeCode: route.code);
      },
    );
  }
}
