import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../l10n/transport_list_localizations.dart';
import 'otp_transport_data_provider.dart';
import 'repository/transport_list_cache.dart';
import 'transport_detail_screen.dart';
import 'transport_list_content.dart';
import 'models/transport_route.dart';
import 'transport_list_data_provider.dart';
import 'widgets/operator_qr_dialog.dart';

/// Transport List screen module for TrufiApp integration with OTP and Map support.
///
/// Uses the current routing provider from [RoutingEngineManager] to fetch
/// transit routes. If the current provider doesn't support transit routes,
/// it will try to find an online provider that does.
///
/// Routes:
/// - `/routes` - shows the list of transit routes
/// - `/routes/:id` - shows route detail for the given pattern ID (path parameter)
class TransportListTrufiScreen extends TrufiScreen {
  final TransportListDataProvider Function(BuildContext context)?
  dataProviderBuilder;

  /// Base https URL used to build the shareable/printable operator QR
  /// links (e.g. `https://app.trufi.app` → `https://app.trufi.app/routes?
  /// operator=X`). Mirrors `HomeScreenConfig.shareBaseUrl`. When null,
  /// links fall back to the app's `deepLinkScheme`
  /// (`trufiapp://routes?operator=X`); with neither set, the QR
  /// affordances are hidden.
  final String? shareBaseUrl;

  TransportListTrufiScreen({this.dataProviderBuilder, this.shareBaseUrl});

  @override
  String get id => 'transport_list';

  @override
  String get path => '/routes';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => _TransportListScreenWidget(
        dataProviderBuilder: dataProviderBuilder,
        shareBaseUrl: shareBaseUrl,
      );

  @override
  List<TrufiSubRoute> get subRoutes => [
    TrufiSubRoute(
      path: ':id', // Path parameter - matches /routes/xxx
      builder: (context, params) {
        final routeId = params['id'];
        if (routeId == null || routeId.isEmpty) {
          return _TransportListScreenWidget(
            dataProviderBuilder: dataProviderBuilder,
          );
        }

        final Future<TransportRouteDetails?> Function(String) getDetails;
        if (dataProviderBuilder != null) {
          final provider = dataProviderBuilder!(context);
          getDetails = (code) async {
            await provider.load();
            return provider.getRouteDetails(code);
          };
        } else {
          getDetails = TransportDetailScreen.createGetRouteDetails(context);
        }

        return TransportDetailScreen(
          routeCode: routeId,
          getRouteDetails: getDetails,
        );
      },
    ),
  ];

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
  final TransportListDataProvider Function(BuildContext context)?
  dataProviderBuilder;
  final String? shareBaseUrl;

  const _TransportListScreenWidget({
    this.dataProviderBuilder,
    this.shareBaseUrl,
  });

  @override
  State<_TransportListScreenWidget> createState() =>
      _TransportListScreenWidgetState();
}

class _TransportListScreenWidgetState
    extends State<_TransportListScreenWidget> {
  TransportListDataProvider? _dataProvider;
  TransportListCache? _cache;
  bool _initialized = false;

  /// Last `operator` query parameter applied from the URL. Tracked so the
  /// URL only drives the filter when it actually changes — a user clearing
  /// the filter in the UI isn't fought by an unchanged URL.
  String? _appliedOperator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize data provider with routing engine from context
    if (!_initialized) {
      _initialized = true;
      _initializeDataProvider();
    }

    _syncOperatorFromUrl();
  }

  /// Applies the `operator` query parameter of `/routes?operator=...`
  /// deep links (QR codes at stops/vehicles) as the agency filter.
  void _syncOperatorFromUrl() {
    Uri uri;
    try {
      uri = GoRouterState.of(context).uri;
    } catch (_) {
      // Not hosted under GoRouter (e.g. embedded usage) — nothing to sync.
      return;
    }

    // Only sync while the list route itself is active; when a detail
    // sub-route is on top the URL has no `operator` and syncing would
    // wrongly clear the filter underneath it.
    if (uri.path != '/routes') return;

    final operator = uri.queryParameters['operator'];
    if (operator == _appliedOperator) return;
    _appliedOperator = operator;
    _dataProvider?.setAgencyFilter(operator);
  }

  /// Clears the agency filter and drops the `operator` parameter from the
  /// URL so the address bar/share state stays consistent.
  void _clearAgencyFilter() {
    _dataProvider?.setAgencyFilter(null);
    try {
      final router = GoRouter.of(context);
      final uri = router.routeInformationProvider.value.uri;
      if (uri.path == '/routes' &&
          uri.queryParameters.containsKey('operator')) {
        router.replace('/routes');
      }
    } catch (_) {
      // Not hosted under GoRouter — the in-memory filter is already cleared.
    }
  }

  /// Builds the link a printed QR encodes for [agencyName]: the https
  /// share URL when configured, else the app's custom scheme. Null when
  /// the app has neither (QR affordances hidden).
  String? _operatorLink(String agencyName) {
    final base = widget.shareBaseUrl;
    if (base != null) {
      final baseUri = Uri.parse(base);
      return Uri(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.hasPort ? baseUri.port : null,
        path: '/routes',
        queryParameters: {'operator': agencyName},
      ).toString();
    }

    String? scheme;
    try {
      scheme = Provider.of<AppConfiguration>(
        context,
        listen: false,
      ).deepLinkScheme;
    } catch (_) {
      // Not hosted under TrufiApp (e.g. embedded usage).
    }
    if (scheme == null) return null;
    return Uri(
      scheme: scheme,
      host: 'routes',
      queryParameters: {'operator': agencyName},
    ).toString();
  }

  void _showOperatorQr(String agencyName) {
    final link = _operatorLink(agencyName);
    if (link == null) return;
    showOperatorQrDialog(context, operatorName: agencyName, link: link);
  }

  /// Whether QR links can be built at all — gates the QR buttons.
  bool get _canShareOperatorQr =>
      widget.shareBaseUrl != null || _operatorLink('') != null;

  void _initializeDataProvider() {
    if (widget.dataProviderBuilder != null) {
      _dataProvider = widget.dataProviderBuilder!(context);
    } else {
      _cache = TransportListCache();
      _cache!.initialize();

      final routingManager = RoutingEngineManager.read(context);

      _dataProvider = OtpTransportDataProvider(
        manager: routingManager,
        cache: _cache,
      );
    }
  }

  @override
  void dispose() {
    _dataProvider?.dispose();
    _cache?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = _dataProvider;
    if (dataProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // This widget only shows the list - detail is handled by sub-route
    return TransportListContent(
      dataProvider: dataProvider,
      onClearAgencyFilter: _clearAgencyFilter,
      onShowOperatorQr: _canShareOperatorQr ? _showOperatorQr : null,
      onRouteTap: (route) {
        // Push to /routes/{id} so pop() returns here
        // URL updates automatically via GoRouter.optionURLReflectsImperativeAPIs
        final encodedId = Uri.encodeComponent(route.code);
        context.push('/routes/$encodedId');
      },
    );
  }
}
