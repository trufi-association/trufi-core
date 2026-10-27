import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart'
    show RoutingEngineManager;
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/transport_list_localizations.dart';
import '../models/transport_route.dart';
import '../transport_detail_screen.dart';
import 'nearby_geometry.dart';
import 'nearby_line.dart';
import 'nearby_lines_cubit.dart';
import 'nearby_lines_data_source.dart';
import 'nearby_radius.dart';
import 'widgets/nearby_header_card.dart';
import 'widgets/nearby_lines_sheet.dart';
import 'widgets/nearby_map_layers.dart';

/// Opens the detail of a nearby line; the default pushes
/// [TransportDetailScreen] with locally built details (see
/// [showNearbyLineDetails]).
typedef NearbyLineDetailsCallback =
    void Function(BuildContext context, NearbyLine line);

/// Drawer screen `/nearby`: the lines passing within 100 / 300 / 500 m of
/// the rider's position or a map pin, computed offline from the local
/// planner's GTFS (#1006).
///
/// Needs a `MapEngineManager` in the provider tree and, to show anything, a
/// `TrufiPlannerProvider` with `TrufiPlannerConfig.local` among the
/// `RoutingEngineManager` engines (or a [dataSourceBuilder]). Without one the
/// screen explains that the offline planner is missing instead of failing.
class NearbyLinesTrufiScreen extends TrufiScreen {
  NearbyLinesTrufiScreen({
    this.dataSourceBuilder,
    this.onLineDetails,
    this.initialRadius = NearbyRadius.m300,
    LocationService? locationService,
  }) : _locationService = locationService ?? LocationService();

  /// Replaces the default lookup (first local `TrufiPlannerProvider`).
  final NearbyLinesDataSource Function(BuildContext context)? dataSourceBuilder;

  /// Replaces the default detail navigation, e.g. to route through
  /// `/routes/:id` with the code the app's list provider understands.
  final NearbyLineDetailsCallback? onLineDetails;

  final NearbyRadius initialRadius;
  final LocationService _locationService;

  @override
  String get id => 'nearby_lines';

  @override
  String get path => '/nearby';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => _NearbyLinesScreenWidget(
        onLineDetails: onLineDetails ?? showNearbyLineDetails,
      );

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    ...TransportListLocalizations.localizationsDelegates,
    MapsLocalizations.delegate,
  ];

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<NearbyLinesCubit>(
      create: (context) => NearbyLinesCubit(
        dataSource: _resolveDataSource(context),
        defaultAnchor: MapEngineManager.read(context).defaultCenter,
        locate: () => locateDevice(_locationService),
        initialRadius: initialRadius,
      ),
    ),
  ];

  @override
  bool get hasOwnAppBar => true;

  @override
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.near_me_rounded, order: 2);

  @override
  String getLocalizedTitle(BuildContext context) =>
      TransportListLocalizations.of(context).menuNearbyLines;

  @override
  Future<void> dispose() async {
    _locationService.dispose();
  }

  NearbyLinesDataSource? _resolveDataSource(BuildContext context) {
    final builder = dataSourceBuilder;
    if (builder != null) return builder(context);
    final engines = RoutingEngineManager.maybeRead(context)?.engines;
    return GtfsNearbyLinesDataSource.fromEngines(engines ?? const []);
  }
}

/// Permission flow of the home screen without its dialogs: ask once when
/// merely denied, give up on "denied forever" / services off / no fix in
/// 10 s. Null means "use the pin fallback"; the header's hint explains it.
Future<LatLng?> locateDevice(LocationService service) async {
  try {
    var status = await service.checkPermission();
    if (status == LocationPermissionStatus.denied) {
      status = await service.requestPermission();
    }
    if (status != LocationPermissionStatus.granted) return null;
    final location = await service.getCurrentLocation(
      timeout: const Duration(seconds: 10),
    );
    if (location == null) return null;
    return LatLng(location.latitude, location.longitude);
  } catch (_) {
    // Timeout, geolocator failure or no plugin on this platform: fall back.
    return null;
  }
}

/// What [TransportDetailScreen] renders for a nearby line, built from the
/// local feed — no engine call, so it works whichever routing engine is
/// current (the OTP engines cannot resolve a local `routeId#patternId`).
TransportRouteDetails nearbyLineToRouteDetails(
  NearbyLine line,
  NearbyLineGeometry geometry,
) {
  return TransportRouteDetails(
    id: line.detailCode,
    code: line.detailCode,
    name: line.headsign ?? line.longName,
    shortName: line.shortName.isEmpty ? null : line.shortName,
    longName: line.longName.isEmpty ? null : line.longName,
    backgroundColor: line.color,
    textColor: line.textColor,
    modeIcon: Icon(gtfsRouteTypeIcon(line.routeType), size: 16),
    agencyName: line.agencyName,
    headsign: line.headsign,
    geometry: [
      for (final point in geometry.polyline)
        (latitude: point.latitude, longitude: point.longitude),
    ],
    stops: [
      for (final stop in geometry.stops)
        TransportStop(
          id: stop.id,
          name: stop.name,
          latitude: stop.position.latitude,
          longitude: stop.position.longitude,
        ),
    ],
    modeName: line.routeType.displayName,
  );
}

/// Default [NearbyLineDetailsCallback]: pushes the route detail over the
/// nearby screen (pageless route, URL unchanged — like the home map picker).
void showNearbyLineDetails(BuildContext context, NearbyLine line) {
  final geometry = context.read<NearbyLinesCubit>().dataSource?.geometryOf(
    line,
  );
  if (geometry == null) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(TransportListLocalizations.of(context).routeLoadError),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return;
  }
  final details = nearbyLineToRouteDetails(line, geometry);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TransportDetailScreen(
        routeCode: line.detailCode,
        getRouteDetails: (_) async => details,
      ),
    ),
  );
}

class _NearbyLinesScreenWidget extends StatefulWidget {
  const _NearbyLinesScreenWidget({required this.onLineDetails});

  final NearbyLineDetailsCallback onLineDetails;

  @override
  State<_NearbyLinesScreenWidget> createState() =>
      _NearbyLinesScreenWidgetState();
}

class _NearbyLinesScreenWidgetState extends State<_NearbyLinesScreenWidget> {
  /// Side panel instead of a bottom sheet from this width (the route detail
  /// screen's threshold).
  static const double _wideBreakpoint = 600;

  /// Zoom at which the 300 m ring fills a phone screen comfortably; used
  /// until the viewport is known and a real fit is possible.
  static const double _anchorZoom = 15;

  /// Margin around the floating header; with the header card's height it
  /// is what the camera fit keeps clear of the ring on phones.
  static const double _headerPadding = 12;

  static const double _sheetMinSize = 0.14;
  static const double _sheetInitialSize = 0.35;
  static const double _sheetMaxSize = 0.85;
  static const double _controlsTopInset = 12;
  static const double _wideFitPadding = 24;

  final TrufiMapController _mapController = TrufiMapController();
  final FitCameraUtil _fitCamera = FitCameraUtil();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  TrufiCameraPosition? _initialCamera;
  TrufiCameraPosition? _camera;
  bool _outOfFocus = false;

  /// The fit the listener could not do yet (no viewport before the first
  /// layout, or the anchor was already known when the screen was revisited).
  bool _fitPending = true;
  NearbyLinesState? _lastState;

  @override
  void initState() {
    super.initState();
    // The cubit is app-scoped: every visit re-locates and re-queries.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NearbyLinesCubit>().start();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _initializeCamera(MapEngineManager manager, NearbyLinesState state) {
    if (_initialCamera != null) return;
    _initialCamera = TrufiCameraPosition(
      target: state.anchor ?? manager.defaultCenter,
      zoom: _anchorZoom,
    );
    _camera = _initialCamera;
  }

  /// Camera side effects: fit the ring when the anchor or radius moves, the
  /// selected line when one is highlighted, the ring again when cleared.
  void _onStateChanged(NearbyLinesState state) {
    final previous = _lastState;
    _lastState = state;
    final anchor = state.anchor;
    if (anchor == null) return;

    final anchorChanged = previous?.anchor != anchor;
    final radiusChanged = previous?.radius != state.radius;
    final selectionChanged = previous?.selectedLineKey != state.selectedLineKey;

    if (state.selectedGeometry.length > 1) {
      if (selectionChanged || anchorChanged || _fitPending) {
        _fitTo(state.selectedGeometry, fallbackTarget: anchor);
      }
      return;
    }
    if (anchorChanged || radiusChanged || selectionChanged || _fitPending) {
      _fitTo(
        NearbyGeometry.circlePolygon(anchor, state.radius.meters),
        fallbackTarget: anchor,
      );
    }
  }

  void _fitTo(List<LatLng> points, {required LatLng fallbackTarget}) {
    final fallback = TrufiCameraPosition(
      target: fallbackTarget,
      zoom: _anchorZoom,
    );
    final fitted = _fitCamera.cameraForPoints(
      points,
      _camera ?? _initialCamera ?? fallback,
    );
    _fitPending = fitted == null;
    if (!mounted) return;
    setState(() {
      _camera = fitted ?? fallback;
      _outOfFocus = false;
    });
  }

  /// Called from build once the viewport is known: fits the ring if no
  /// state change has done it yet (revisits with an unchanged anchor).
  void _scheduleInitialFit(NearbyLinesState state) {
    final anchor = state.anchor;
    if (!_fitPending || anchor == null) return;
    _fitPending = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final points = state.selectedGeometry.length > 1
          ? state.selectedGeometry
          : NearbyGeometry.circlePolygon(anchor, state.radius.meters);
      _fitTo(points, fallbackTarget: anchor);
    });
  }

  void _onCameraChanged(TrufiCameraPosition camera) {
    // Keep the controlled camera current, or every rebuild snaps the map
    // back to the last fit (same reason as the route detail map).
    _camera = camera;
    final nowOutOfFocus = _fitCamera.isOutOfFocus(camera);
    if (nowOutOfFocus != _outOfFocus) {
      setState(() => _outOfFocus = nowOutOfFocus);
    }
  }

  void _reFitCamera() {
    final refitted = _fitCamera.reFitCamera(_camera ?? _initialCamera!);
    if (refitted == null) return;
    setState(() {
      _camera = refitted;
      _outOfFocus = false;
    });
  }

  /// A tap only toggles the line label it lands on; it never moves the pin,
  /// so a mis-tap on a crowded corner cannot relocate the search.
  void _onMapTap(LatLng point) {
    final picks = _mapController.pickMarkersAt(point, hitboxPx: 32);
    for (final marker in picks) {
      if (!marker.id.startsWith(nearbyPointMarkerPrefix)) continue;
      HapticFeedback.selectionClick();
      context.read<NearbyLinesCubit>().toggleLine(
        marker.id.substring(nearbyPointMarkerPrefix.length),
      );
      return;
    }
  }

  void _onMapLongPress(LatLng point) {
    HapticFeedback.mediumImpact();
    context.read<NearbyLinesCubit>().setAnchor(point);
  }

  void _tryOpenDrawer() {
    HapticFeedback.lightImpact();
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) scaffold!.openDrawer();
  }

  void _close() {
    HapticFeedback.lightImpact();
    try {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } catch (_) {
      // Not hosted under GoRouter (embedded usage): plain navigator pop.
      Navigator.of(context).maybePop();
    }
  }

  double _sidePanelWidth(double screenWidth) {
    if (screenWidth >= 1200) return 420;
    if (screenWidth >= 900) return 380;
    return 340;
  }

  @override
  Widget build(BuildContext context) {
    final manager = MapEngineManager.watch(context);
    return BlocConsumer<NearbyLinesCubit, NearbyLinesState>(
      listener: (_, state) => _onStateChanged(state),
      builder: (context, state) {
        _initializeCamera(manager, state);
        return ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= _wideBreakpoint;
              return isWide
                  ? _buildWide(context, manager, state, constraints)
                  : _buildNarrow(context, manager, state, constraints);
            },
          ),
        );
      },
    );
  }

  Widget _buildNarrow(
    BuildContext context,
    MapEngineManager manager,
    NearbyLinesState state,
    BoxConstraints constraints,
  ) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final headerReserve =
        _headerPadding * 2 + NearbyHeaderCard.heightFor(state);
    _fitCamera.updateViewport(
      Size(constraints.maxWidth, constraints.maxHeight),
      EdgeInsets.only(
        top: viewPadding.top + headerReserve,
        bottom: viewPadding.bottom + constraints.maxHeight * _sheetInitialSize,
        left: viewPadding.left,
        right: viewPadding.right,
      ),
    );
    _scheduleInitialFit(state);

    return Stack(
      children: [
        Positioned.fill(child: _buildMap(context, manager, state)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(_headerPadding),
              child: _buildHeader(state, elevated: true),
            ),
          ),
        ),
        Positioned(
          top: viewPadding.top + headerReserve,
          right: 16,
          child: _MapControls(
            manager: manager,
            outOfFocus: _outOfFocus,
            onReFit: _reFitCamera,
          ),
        ),
        TrufiBottomSheet(
          controller: _sheetController,
          initialChildSize: _sheetInitialSize,
          minChildSize: _sheetMinSize,
          maxChildSize: _sheetMaxSize,
          snap: true,
          snapSizes: const [_sheetMinSize, _sheetInitialSize, _sheetMaxSize],
          builder: (context, scrollController) =>
              _buildSheet(state, scrollController),
        ),
      ],
    );
  }

  Widget _buildWide(
    BuildContext context,
    MapEngineManager manager,
    NearbyLinesState state,
    BoxConstraints constraints,
  ) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final sidePanelWidth = _sidePanelWidth(constraints.maxWidth);
    _fitCamera.updateViewport(
      Size(constraints.maxWidth - sidePanelWidth, constraints.maxHeight),
      EdgeInsets.only(
        top: viewPadding.top + _wideFitPadding,
        bottom: viewPadding.bottom + _wideFitPadding,
        left: _wideFitPadding,
        right: viewPadding.right + _wideFitPadding,
      ),
    );
    _scheduleInitialFit(state);

    return Row(
      children: [
        SizedBox(
          width: sidePanelWidth,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 4,
            shadowColor: Colors.black26,
            child: SafeArea(
              right: false,
              child: Column(
                children: [
                  _buildHeader(state, elevated: false),
                  Expanded(child: _buildSheet(state, null)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: _buildMap(context, manager, state)),
              Positioned(
                top: viewPadding.top + _controlsTopInset,
                right: 16,
                child: _MapControls(
                  manager: manager,
                  outOfFocus: _outOfFocus,
                  onReFit: _reFitCamera,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap(
    BuildContext context,
    MapEngineManager manager,
    NearbyLinesState state,
  ) {
    return manager.currentEngine.buildMap(
      controller: _mapController,
      // A new engine builds a fresh map: start it where the rider left the
      // previous one instead of the default city view.
      initialCamera: _camera ?? _initialCamera!,
      camera: _camera,
      onCameraChanged: _onCameraChanged,
      onMapClick: _onMapTap,
      onMapLongClick: _onMapLongPress,
      layers: buildNearbyLayers(
        state: state,
        colorScheme: Theme.of(context).colorScheme,
        formatMeters: (meters) => formatNearbyMeters(context, meters),
      ),
    );
  }

  Widget _buildHeader(NearbyLinesState state, {required bool elevated}) {
    final cubit = context.read<NearbyLinesCubit>();
    return NearbyHeaderCard(
      state: state,
      elevated: elevated,
      onMenu: _tryOpenDrawer,
      onClose: _close,
      onUseMyLocation: cubit.useMyLocation,
    );
  }

  Widget _buildSheet(NearbyLinesState state, ScrollController? controller) {
    final cubit = context.read<NearbyLinesCubit>();
    return NearbyLinesSheet(
      state: state,
      scrollController: controller,
      onRadiusChanged: cubit.setRadius,
      onLineTap: (line) => cubit.toggleLine(line.lineKey),
      onLineDetails: (line) => widget.onLineDetails(context, line),
      onClearSelection: cubit.clearSelection,
      onRetry: cubit.refresh,
    );
  }
}

/// Map type switcher (when the app ships several engines) and the re-fit
/// button that appears once the rider pans away from the search area.
class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.manager,
    required this.outOfFocus,
    required this.onReFit,
  });

  final MapEngineManager manager;
  final bool outOfFocus;
  final VoidCallback onReFit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = TransportListLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (manager.engines.length > 1) ...[
          MapTypeButton.fromEngines(
            engines: manager.engines,
            currentEngineIndex: manager.currentIndex,
            onEngineChanged: manager.setEngine,
            settingsAppBarTitle: l10n.mapSettingsTitle,
            settingsSectionTitle: l10n.mapTypeLabel,
            settingsApplyButtonText: l10n.applyChanges,
          ),
          const SizedBox(height: 8),
        ],
        AnimatedOpacity(
          opacity: outOfFocus ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: outOfFocus ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: outOfFocus ? onReFit : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.crop_free_rounded,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
