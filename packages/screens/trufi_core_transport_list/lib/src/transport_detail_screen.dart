import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../l10n/transport_list_localizations.dart';
import 'models/transport_route.dart';

/// Callback type for moving the map to a specific location
typedef MapMoveCallback = void Function(double latitude, double longitude);

/// Callback type for selecting a stop on the map
typedef StopSelectionCallback = void Function(int? stopIndex);

/// Screen showing transport route details with map and stops
class TransportDetailScreen extends StatefulWidget {
  final String routeCode;
  final Future<TransportRouteDetails?> Function(String code) getRouteDetails;
  final Widget Function(
    BuildContext context,
    TransportRouteDetails? route,
    void Function(MapMoveCallback) registerMapMoveCallback,
    void Function(StopSelectionCallback) registerStopSelectionCallback,
  )?
  mapBuilder;
  final Uri? shareBaseUri;

  /// Base path for URL updates (web only). Example: '/routes'
  /// When set, the URL will be updated to include the route ID as a query parameter.
  final String? basePath;

  const TransportDetailScreen({
    super.key,
    required this.routeCode,
    required this.getRouteDetails,
    this.mapBuilder,
    this.shareBaseUri,
    this.basePath,
  });

  /// Shows the transport detail screen.
  ///
  /// Uses [RoutingEngineManager] and [MapEngineManager] from context automatically.
  static Future<void> show(
    BuildContext context, {
    required String routeCode,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TransportDetailScreen(
              routeCode: routeCode,
              getRouteDetails: _createGetRouteDetails(context),
              mapBuilder: _defaultMapBuilder,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Default map builder using _RouteMapView.
  static Widget _defaultMapBuilder(
    BuildContext context,
    TransportRouteDetails? route,
    void Function(MapMoveCallback) registerMapMoveCallback,
    void Function(StopSelectionCallback) registerStopSelectionCallback,
  ) {
    return _RouteMapView(
      route: route,
      registerMapMoveCallback: registerMapMoveCallback,
      registerStopSelectionCallback: registerStopSelectionCallback,
    );
  }

  /// Creates a getRouteDetails function using RoutingEngineManager from context.
  static Future<TransportRouteDetails?> Function(String) _createGetRouteDetails(
    BuildContext context,
  ) {
    final routingManager = RoutingEngineManager.read(context);
    final repository = routingManager.currentEngine.createTransitRouteRepository();

    return (String code) async {
      if (repository == null) return null;

      final route = await repository.fetchPatternById(code);
      return TransportRouteDetails(
        id: route.id,
        code: route.code,
        name: route.name,
        shortName: route.route?.shortName,
        longName: route.route?.longName,
        backgroundColor: route.route?.color != null
            ? Color(int.parse('FF${route.route!.color}', radix: 16))
            : null,
        textColor: route.route?.textColor != null
            ? Color(int.parse('FF${route.route!.textColor}', radix: 16))
            : null,
        geometry: route.geometry
            ?.map((p) => (latitude: p.latitude, longitude: p.longitude))
            .toList(),
        stops: route.stops
            ?.map((s) => TransportStop(
                  id: s.name,
                  name: s.name,
                  latitude: s.lat,
                  longitude: s.lon,
                ))
            .toList(),
      );
    };
  }

  @override
  State<TransportDetailScreen> createState() => _TransportDetailScreenState();
}

class _TransportDetailScreenState extends State<TransportDetailScreen>
    with SingleTickerProviderStateMixin {
  TransportRouteDetails? _route;
  bool _isLoading = false; // Only show loading if data takes > 200ms
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late AnimationController _fadeController;
  MapMoveCallback? _mapMoveCallback;
  StopSelectionCallback? _stopSelectionCallback;
  int? _selectedStopIndex;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadRoute();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoading = true);
    try {
      final route = await widget.getRouteDetails(widget.routeCode);
      if (mounted) {
        setState(() {
          _route = route;
          _isLoading = false;
        });
        _fadeController.forward();
        // Update URL with route ID (web only)
        _updateUrlWithRouteId();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading route: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Updates the URL with the route ID (web only).
  void _updateUrlWithRouteId() {
    if (!kIsWeb || widget.basePath == null) return;

    try {
      final uri = Uri(
        path: widget.basePath,
        queryParameters: {'id': widget.routeCode},
      );
      GoRouter.of(context).replace(uri.toString());
    } catch (e) {
      debugPrint('TransportDetailScreen: Error updating URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = TransportListLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, localization, theme, colorScheme),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    TransportListLocalizations localization,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // No AppBar - we'll use a custom header in the body
    return null;
  }

  Widget _buildTopBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final routeColor = _route?.backgroundColor ?? colorScheme.primary;
    final textColor = _route?.textColor ?? Colors.white;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Back button
              Material(
                color: colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                shadowColor: Colors.black26,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colorScheme.onSurface,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Route title card (only show when route is loaded)
              if (_route != null)
                Expanded(
                  child: Material(
                    color: colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    elevation: 2,
                    shadowColor: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Route badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: routeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_route!.modeIcon != null) ...[
                                  IconTheme(
                                    data: IconThemeData(
                                      color: textColor,
                                      size: 16,
                                    ),
                                    child: _route!.modeIcon!,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  _route!.displayName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Route name (show prefix like "MiniBus 1", origin/destination is in bottom sheet)
                          if (_route!.longNamePrefix.isNotEmpty)
                            Expanded(
                              child: Text(
                                _route!.longNamePrefix,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 12),

              // Share button
              if (_route != null && widget.shareBaseUri != null)
                Material(
                  color: colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _shareRoute();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.share_rounded,
                        color: colorScheme.onSurface,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the side panel width based on screen width.
  double _getSidePanelWidth(double screenWidth) {
    if (screenWidth >= 1200) return 420;
    if (screenWidth >= 900) return 380;
    return 340;
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Stack(
        children: [
          Positioned.fill(child: _LoadingState()),
          _buildBackButton(context, colorScheme),
        ],
      );
    }

    if (_route == null) {
      return Stack(
        children: [
          Positioned.fill(
            child: _ErrorState(onRetry: () => Navigator.pop(context)),
          ),
          _buildBackButton(context, colorScheme),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout: use side panel for wide screens (≥600px)
        final isWideScreen = constraints.maxWidth >= 600;
        final sidePanelWidth = _getSidePanelWidth(constraints.maxWidth);

        if (isWideScreen) {
          return _buildWideLayout(
            context,
            theme,
            colorScheme,
            sidePanelWidth,
          );
        } else {
          return _buildNarrowLayout(context, theme, colorScheme);
        }
      },
    );
  }

  /// Builds the layout for wide screens with side panel on the left.
  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double sidePanelWidth,
  ) {
    return Stack(
      children: [
        // Map - positioned to the right of side panel
        Positioned(
          top: 0,
          left: sidePanelWidth,
          bottom: 0,
          right: 0,
          child: widget.mapBuilder != null
              ? FadeTransition(
                  opacity: _fadeController,
                  child: widget.mapBuilder!(
                    context,
                    _route,
                    (callback) => _mapMoveCallback = callback,
                    (callback) => _stopSelectionCallback = callback,
                  ),
                )
              : Container(
                  color: colorScheme.surfaceContainerLow,
                  child: Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
        ),

        // Side panel on the left
        _buildSidePanel(context, theme, colorScheme, sidePanelWidth),

        // Top bar with route info - only over the map area
        Positioned(
          top: 0,
          left: sidePanelWidth,
          right: 0,
          child: _buildTopBarContent(context, theme, colorScheme),
        ),
      ],
    );
  }

  /// Builds the side panel for wide screens.
  Widget _buildSidePanel(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double width,
  ) {
    final routeColor = _route?.backgroundColor ?? colorScheme.primary;
    final textColor = _route?.textColor ?? Colors.white;

    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          right: false,
          child: Column(
            children: [
              // Header with back button and route info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Back button
                    Material(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: colorScheme.onSurface,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Route badge
                    if (_route != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: routeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_route!.modeIcon != null) ...[
                              IconTheme(
                                data: IconThemeData(
                                  color: textColor,
                                  size: 16,
                                ),
                                child: _route!.modeIcon!,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              _route!.displayName,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Route name
                    if (_route != null && _route!.longNamePrefix.isNotEmpty)
                      Expanded(
                        child: Text(
                          _route!.longNamePrefix,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    // Share button
                    if (_route != null && widget.shareBaseUri != null)
                      Material(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _shareRoute();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.share_rounded,
                              color: colorScheme.onSurface,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Stops content - scrollable
              Expanded(
                child: _SidePanelStopsContent(
                  route: _route!,
                  selectedStopIndex: _selectedStopIndex,
                  onStopTap: (index, lat, lng) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedStopIndex = index);
                    _mapMoveCallback?.call(lat, lng);
                    _stopSelectionCallback?.call(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the layout for narrow screens with bottom sheet.
  Widget _buildNarrowLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Stack(
      children: [
        // Map
        if (widget.mapBuilder != null)
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeController,
              child: widget.mapBuilder!(
                context,
                _route,
                (callback) => _mapMoveCallback = callback,
                (callback) => _stopSelectionCallback = callback,
              ),
            ),
          )
        else
          Positioned.fill(
            child: Container(
              color: colorScheme.surfaceContainerLow,
              child: Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

        // Top bar with route info
        _buildTopBar(context, theme, colorScheme),

        // Bottom sheet with stops only
        TrufiBottomSheet(
          controller: _sheetController,
          initialChildSize: 0.35,
          minChildSize: 0.15,
          maxChildSize: 0.5,
          snap: true,
          snapSizes: const [0.15, 0.35, 0.5],
          builder: (context, scrollController) => _StopsSheetContent(
            route: _route!,
            scrollController: scrollController,
            selectedStopIndex: _selectedStopIndex,
            onStopTap: (index, lat, lng) {
              HapticFeedback.selectionClick();
              setState(() => _selectedStopIndex = index);
              _mapMoveCallback?.call(lat, lng);
              _stopSelectionCallback?.call(index);
            },
          ),
        ),
      ],
    );
  }

  /// Builds just the content of the top bar (for wide screen layout).
  Widget _buildTopBarContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SafeArea(
      bottom: false,
      left: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Only show share button on the map area for wide screens
            // (back button and route info are in the side panel)
          ],
        ),
      ),
    );
  }

  /// Simple back button for loading/error states
  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            shadowColor: Colors.black26,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _shareRoute() {
    if (_route == null || widget.shareBaseUri == null) return;
    final uri = widget.shareBaseUri!.replace(
      queryParameters: {'id': _route!.code},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: $uri'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Content for the stops bottom sheet
/// Helper class for calculating route distance.
class _RouteDistanceCalculator {
  /// Calculates the total distance of the route in kilometers using Haversine formula.
  static double calculate(
    List<({double latitude, double longitude})>? geometry,
  ) {
    if (geometry == null || geometry.length < 2) return 0;

    double totalDistance = 0;
    for (int i = 0; i < geometry.length - 1; i++) {
      totalDistance += _haversineDistance(
        geometry[i].latitude,
        geometry[i].longitude,
        geometry[i + 1].latitude,
        geometry[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  /// Haversine formula to calculate distance between two coordinates in km.
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  /// Formats distance for display.
  static String format(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}

/// Content for the stops bottom sheet
class _StopsSheetContent extends StatelessWidget {
  final TransportRouteDetails route;
  final ScrollController scrollController;
  final int? selectedStopIndex;
  final void Function(int index, double lat, double lng)? onStopTap;

  const _StopsSheetContent({
    required this.route,
    required this.scrollController,
    this.selectedStopIndex,
    this.onStopTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stops = route.stops ?? [];

    return Column(
      children: [
        // Fixed header section
        _buildHeader(context, theme, colorScheme, stops),

        // Scrollable stops list
        Expanded(
          child: stops.isEmpty
              ? const _EmptyStopsInline()
              : ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    final isFirst = index == 0;
                    final isLast = index == stops.length - 1;
                    final isSelected = selectedStopIndex == index;
                    final routeColor =
                        route.backgroundColor ?? colorScheme.primary;

                    return _StopTimelineItem(
                      stop: stop,
                      isFirst: isFirst,
                      isLast: isLast,
                      isSelected: isSelected,
                      routeColor: routeColor,
                      onTap: onStopTap != null
                          ? () {
                              HapticFeedback.selectionClick();
                              onStopTap!(index, stop.latitude, stop.longitude);
                            }
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<TransportStop> stops,
  ) {
    final routeColor = route.backgroundColor ?? colorScheme.primary;
    final distance = _RouteDistanceCalculator.calculate(route.geometry);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Origin/Destination header (Google Maps style)
        if (route.hasOriginDestination)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicators (green dot, dotted line, red dot)
                Column(
                  children: [
                    // Green origin dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                    // Dotted line
                    CustomPaint(
                      size: const Size(2, 28),
                      painter: _DottedLinePainter(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    // Red destination dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Origin and destination text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Origin
                      Text(
                        route.longNameStart,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Destination
                      Text(
                        route.longNameLast,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Route statistics
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: routeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: routeColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Distance
                Expanded(
                  child: _StatItem(
                    icon: Icons.straighten_rounded,
                    label: 'Distance',
                    value: _RouteDistanceCalculator.format(distance),
                    color: routeColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                // Stops
                Expanded(
                  child: _StatItem(
                    icon: Icons.pin_drop_rounded,
                    label: 'Stops',
                    value: '${stops.length}',
                    color: routeColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                // Mode
                Expanded(
                  child: _StatItem(
                    icon: route.modeIcon != null
                        ? null
                        : Icons.directions_bus_rounded,
                    customIcon: route.modeIcon,
                    label: 'Mode',
                    value: route.modeName ?? 'Bus',
                    color: routeColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Stops header with divider
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            children: [
              Text(
                'Stops',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Inline empty stops state for sliver
class _EmptyStopsInline extends StatelessWidget {
  const _EmptyStopsInline();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No stops available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline stop item
class _StopTimelineItem extends StatelessWidget {
  final TransportStop stop;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final Color routeColor;
  final VoidCallback? onTap;

  const _StopTimelineItem({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    this.isSelected = false,
    required this.routeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTerminal = isFirst || isLast;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? routeColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Timeline indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 16 : 12,
                  height: isSelected ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? routeColor
                        : (isTerminal ? routeColor : colorScheme.surface),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : routeColor,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: routeColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Stop name
                Expanded(
                  child: Text(
                    stop.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: (isTerminal || isSelected)
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? routeColor : null,
                    ),
                  ),
                ),
                // Selected indicator icon
                if (isSelected)
                  Icon(Icons.location_on_rounded, size: 18, color: routeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading state with animated indicator
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading route...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state with retry option
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = TransportListLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.routeNotFound,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.routeLoadError,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(l10n.buttonGoBack),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for dotted line between origin and destination
class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Content for the side panel stops list (wide screens).
class _SidePanelStopsContent extends StatelessWidget {
  final TransportRouteDetails route;
  final int? selectedStopIndex;
  final void Function(int index, double lat, double lng)? onStopTap;

  const _SidePanelStopsContent({
    required this.route,
    this.selectedStopIndex,
    this.onStopTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stops = route.stops ?? [];
    final routeColor = route.backgroundColor ?? colorScheme.primary;
    final distance = _RouteDistanceCalculator.calculate(route.geometry);

    return Column(
      children: [
        // Origin/Destination header (Google Maps style)
        if (route.hasOriginDestination)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicators (green dot, dotted line, red dot)
                Column(
                  children: [
                    // Green origin dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                    // Dotted line
                    CustomPaint(
                      size: const Size(2, 28),
                      painter: _DottedLinePainter(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    // Red destination dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Origin and destination text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Origin
                      Text(
                        route.longNameStart,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Destination
                      Text(
                        route.longNameLast,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Route statistics cards
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: routeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: routeColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Distance
                Expanded(
                  child: _StatItem(
                    icon: Icons.straighten_rounded,
                    label: 'Distance',
                    value: _RouteDistanceCalculator.format(distance),
                    color: routeColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                // Stops
                Expanded(
                  child: _StatItem(
                    icon: Icons.pin_drop_rounded,
                    label: 'Stops',
                    value: '${stops.length}',
                    color: routeColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                // Mode
                Expanded(
                  child: _StatItem(
                    icon: route.modeIcon != null
                        ? null
                        : Icons.directions_bus_rounded,
                    customIcon: route.modeIcon,
                    label: 'Mode',
                    value: route.modeName ?? 'Bus',
                    color: routeColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Stops header with divider
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            children: [
              Text(
                'Stops',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),

        // Scrollable stops list
        Expanded(
          child: stops.isEmpty
              ? const _EmptyStopsInline()
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    final isFirst = index == 0;
                    final isLast = index == stops.length - 1;
                    final isSelected = selectedStopIndex == index;
                    final routeColor =
                        route.backgroundColor ?? colorScheme.primary;

                    return _StopTimelineItem(
                      stop: stop,
                      isFirst: isFirst,
                      isLast: isLast,
                      isSelected: isSelected,
                      routeColor: routeColor,
                      onTap: onStopTap != null
                          ? () {
                              HapticFeedback.selectionClick();
                              onStopTap!(index, stop.latitude, stop.longitude);
                            }
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Statistic item widget for route info display.
class _StatItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    this.icon,
    this.customIcon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (customIcon != null)
          IconTheme(
            data: IconThemeData(color: color, size: 20),
            child: customIcon!,
          )
        else if (icon != null)
          Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ============ Route Map View ============

/// Map view for displaying a route (used by showWithRoutingEngine)
class _RouteMapView extends StatefulWidget {
  final TransportRouteDetails? route;
  final void Function(MapMoveCallback) registerMapMoveCallback;
  final void Function(StopSelectionCallback) registerStopSelectionCallback;

  const _RouteMapView({
    required this.route,
    required this.registerMapMoveCallback,
    required this.registerStopSelectionCallback,
  });

  @override
  State<_RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<_RouteMapView> {
  TrufiMapController? _mapController;
  FitCameraLayer? _fitCameraLayer;
  _RouteLayer? _routeLayer;

  @override
  void initState() {
    super.initState();
    widget.registerMapMoveCallback(_moveToLocation);
    widget.registerStopSelectionCallback(_onStopSelected);
  }

  void _onStopSelected(int? stopIndex) {
    _routeLayer?.setSelectedStop(stopIndex);
  }

  void _moveToLocation(double latitude, double longitude) {
    _mapController?.setCameraPosition(
      TrufiCameraPosition(target: LatLng(latitude, longitude), zoom: 16),
    );
  }

  void _initializeIfNeeded(MapEngineManager mapEngineManager) {
    if (_mapController == null) {
      _mapController = TrufiMapController(
        initialCameraPosition: TrufiCameraPosition(
          target: mapEngineManager.defaultCenter,
          zoom: mapEngineManager.defaultZoom,
        ),
      );
      _fitCameraLayer = FitCameraLayer(_mapController!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateRoute();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route != oldWidget.route) {
      _updateRoute();
    }
  }

  void _updateRoute() {
    final route = widget.route;
    if (route == null || route.geometry == null || _mapController == null) {
      return;
    }

    if (_routeLayer != null) {
      _mapController!.removeLayer(_routeLayer!.id);
    }

    _routeLayer = _RouteLayer(_mapController!);
    _routeLayer!.setRoute(route);

    final points = route.geometry!
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    if (points.length > 1) {
      _fitCameraLayer?.setFitPoints(points);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(controller: _mapController!);
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);
    _initializeIfNeeded(mapEngineManager);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewPadding = MediaQuery.of(context).viewPadding;
        final sheetHeight = constraints.maxHeight * 0.30;
        final adjustedPadding = EdgeInsets.only(
          top: viewPadding.top + 70,
          bottom: viewPadding.bottom + sheetHeight,
          left: viewPadding.left,
          right: viewPadding.right,
        );
        _fitCameraLayer?.updateViewport(
          Size(constraints.maxWidth, constraints.maxHeight),
          adjustedPadding,
        );
        final topOffset = viewPadding.top + 70;

        return Stack(
          children: [
            _buildMap(mapEngineManager.currentEngine),
            Positioned(
              top: topOffset,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (mapEngineManager.engines.length > 1) ...[
                    MapTypeButton.fromEngines(
                      engines: mapEngineManager.engines,
                      currentEngineIndex: mapEngineManager.currentIndex,
                      onEngineChanged: (engine) {
                        mapEngineManager.setEngine(engine);
                      },
                      settingsAppBarTitle: 'Map Settings',
                      settingsSectionTitle: 'Map Type',
                      settingsApplyButtonText: 'Apply Changes',
                    ),
                    const SizedBox(height: 8),
                  ],
                  ValueListenableBuilder<bool>(
                    valueListenable: _fitCameraLayer!.outOfFocusNotifier,
                    builder: (context, outOfFocus, _) {
                      return AnimatedOpacity(
                        opacity: outOfFocus ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedScale(
                          scale: outOfFocus ? 1.0 : 0.8,
                          duration: const Duration(milliseconds: 200),
                          child: Material(
                            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            shadowColor: Colors.black26,
                            child: InkWell(
                              onTap: outOfFocus ? _fitCameraLayer!.reFitCamera : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.crop_free_rounded,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom layer for displaying route on map
class _RouteLayer extends TrufiLayer {
  _RouteLayer(super.controller) : super(id: 'route-layer', layerLevel: 1);

  TransportRouteDetails? _currentRoute;
  int? _selectedStopIndex;

  void setSelectedStop(int? stopIndex) {
    _selectedStopIndex = stopIndex;
    if (_currentRoute != null) {
      _updateStopMarkers(_currentRoute!);
    }
  }

  void setRoute(TransportRouteDetails route) {
    _currentRoute = route;
    clearMarkers();
    clearLines();

    if (route.geometry == null || route.geometry!.isEmpty) return;

    final routeColor = route.backgroundColor ?? Colors.blue;
    final points = route.geometry!
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    addLine(
      TrufiLine(
        id: 'route-line',
        position: points,
        color: routeColor,
        lineWidth: 5,
      ),
    );

    _updateStopMarkers(route);
  }

  void _updateStopMarkers(TransportRouteDetails route) {
    final stops = route.stops ?? [];
    for (int i = 0; i < stops.length; i++) {
      removeMarkerById('stop-$i');
    }
    removeMarkerById('selected-stop');
    removeMarkerById('origin-marker');
    removeMarkerById('destination-marker');

    if (stops.isEmpty) return;

    final routeColor = route.backgroundColor ?? Colors.blue;
    final colorHex = routeColor.toARGB32().toRadixString(16);
    final intermediateImageKey = 'stop_intermediate_$colorHex';
    final selectedImageKey = 'stop_selected_$colorHex';

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final isFirst = i == 0;
      final isLast = i == stops.length - 1;
      final isSelected = i == _selectedStopIndex;

      if (isFirst || isLast || isSelected) continue;

      addMarker(
        TrufiMarker(
          id: 'stop-$i',
          position: LatLng(stop.latitude, stop.longitude),
          widget: _StopMarker(color: routeColor),
          size: const Size(12, 12),
          layerLevel: 1,
          imageCacheKey: intermediateImageKey,
        ),
      );
    }

    final firstStop = stops.first;
    addMarker(
      TrufiMarker(
        id: 'origin-marker',
        position: LatLng(firstStop.latitude, firstStop.longitude),
        widget: const _OriginMarker(),
        size: const Size(28, 28),
        layerLevel: 5,
        imageCacheKey: 'origin_marker_v2',
        allowOverlap: true,
      ),
    );

    final lastStop = stops.last;
    addMarker(
      TrufiMarker(
        id: 'destination-marker',
        position: LatLng(lastStop.latitude, lastStop.longitude),
        widget: const _DestinationMarker(),
        size: const Size(36, 36),
        alignment: Alignment.topCenter,
        layerLevel: 5,
        imageCacheKey: 'destination_marker_v2',
        allowOverlap: true,
      ),
    );

    if (_selectedStopIndex != null && _selectedStopIndex! < stops.length) {
      final selectedStop = stops[_selectedStopIndex!];
      addMarker(
        TrufiMarker(
          id: 'selected-stop',
          position: LatLng(selectedStop.latitude, selectedStop.longitude),
          widget: _SelectedStopMarker(color: routeColor),
          size: const Size(24, 24),
          layerLevel: 10,
          imageCacheKey: selectedImageKey,
        ),
      );
    }
  }
}

class _StopMarker extends StatelessWidget {
  final Color color;

  const _StopMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class _OriginMarker extends StatelessWidget {
  const _OriginMarker();

  static const _color = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  static const _color = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.place_rounded,
      color: _color,
      size: 36,
    );
  }
}

class _SelectedStopMarker extends StatelessWidget {
  final Color color;

  const _SelectedStopMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
