import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;
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
import 'nearby_street_anchor.dart';
import 'widgets/nearby_header_card.dart';
import 'widgets/nearby_lines_sheet.dart';
import 'widgets/nearby_locate_feedback.dart';
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
///
/// [showAlongStreet] opens the same screen on the lines along a street
/// (trufi-sanaa#20): the host app wires it to the search screen's
/// `onLinesAlongStreet` callback.
class NearbyLinesTrufiScreen extends TrufiScreen {
  NearbyLinesTrufiScreen({
    this.dataSourceBuilder,
    this.onLineDetails,
    this.showStops = true,
    this.initialRadius = NearbyRadius.m300,
    LocationService? locationService,
  }) : _locationService = locationService ?? LocationService();

  /// Replaces the default lookup (first local `TrufiPlannerProvider`).
  final NearbyLinesDataSource Function(BuildContext context)? dataSourceBuilder;

  /// Replaces the default detail navigation, e.g. to route through
  /// `/routes/:id` with the code the app's list provider understands.
  final NearbyLineDetailsCallback? onLineDetails;

  /// [TransportDetailScreen.showStops] for the default detail navigation
  /// ([showNearbyLineDetails]): `false` for feeds whose stops are
  /// synthetic (trufi-sanaa#18). Not applied when [onLineDetails] is
  /// given — that callback decides what it opens.
  final bool showStops;

  final NearbyRadius initialRadius;
  final LocationService _locationService;

  /// Route of the screen; [showAlongStreet] pushes it.
  static const String routePath = '/nearby';

  @override
  String get id => 'nearby_lines';

  @override
  String get path => routePath;

  /// Pushes the screen on the lines along [street] (trufi-sanaa#20): the
  /// street travels as the route's `extra`, so a drawer visit (no extra)
  /// keeps locating the rider as before. [context] must be under the app's
  /// `GoRouter` — the search screen's is.
  static void showAlongStreet(BuildContext context, NearbyStreetAnchor street) {
    context.push(routePath, extra: street);
  }

  @override
  Widget Function(BuildContext context) get builder =>
      (context) => _NearbyLinesScreenWidget(
        onLineDetails:
            onLineDetails ??
            (context, line) =>
                showNearbyLineDetails(context, line, showStops: showStops),
        initialStreet: _streetExtra(context),
        locationService: _locationService,
      );

  /// The street passed by [showAlongStreet]; null on a drawer visit and
  /// when the screen is not hosted by `GoRouter` (package examples, tests).
  static NearbyStreetAnchor? _streetExtra(BuildContext context) {
    try {
      final extra = GoRouterState.of(context).extra;
      return extra is NearbyStreetAnchor ? extra : null;
    } catch (_) {
      return null;
    }
  }

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
        locate: () => locateDeviceOrThrow(_locationService),
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
/// merely denied, then wait up to 10 s for a fix.
///
/// With no position it throws a [NearbyLocateException] that says why —
/// denied, denied for good, location switched off, no fix. The cubit
/// falls back to the pin in every case, and the "use my location" button
/// explains the reason to the rider (trufi-app#78).
Future<LatLng> locateDeviceOrThrow(LocationService service) async {
  final LocationPermissionStatus status;
  try {
    final current = await service.checkPermission();
    status = current == LocationPermissionStatus.denied
        ? await service.requestPermission()
        : current;
  } catch (_) {
    // No location plugin on this platform, or it failed to answer.
    throw const NearbyLocateException(NearbyLocateFailure.noFix);
  }
  switch (status) {
    case LocationPermissionStatus.granted:
      break;
    case LocationPermissionStatus.denied:
      throw const NearbyLocateException(NearbyLocateFailure.permissionDenied);
    case LocationPermissionStatus.deniedForever:
      throw const NearbyLocateException(
        NearbyLocateFailure.permissionDeniedForever,
      );
    case LocationPermissionStatus.serviceDisabled:
      throw const NearbyLocateException(NearbyLocateFailure.serviceDisabled);
  }
  try {
    final location = await service.getCurrentLocation(
      timeout: const Duration(seconds: 10),
    );
    if (location != null) {
      return LatLng(location.latitude, location.longitude);
    }
  } catch (_) {
    // Timeout or geolocator failure: no fix.
  }
  throw const NearbyLocateException(NearbyLocateFailure.noFix);
}

/// [locateDeviceOrThrow] for callers that only want a position: null
/// whatever the reason there is none.
Future<LatLng?> locateDevice(LocationService service) async {
  try {
    return await locateDeviceOrThrow(service);
  } on NearbyLocateException {
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
/// [showStops] is [TransportDetailScreen.showStops].
void showNearbyLineDetails(
  BuildContext context,
  NearbyLine line, {
  bool showStops = true,
}) {
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
        showStops: showStops,
      ),
    ),
  );
}

class _NearbyLinesScreenWidget extends StatefulWidget {
  const _NearbyLinesScreenWidget({
    required this.onLineDetails,
    required this.locationService,
    this.initialStreet,
  });

  final NearbyLineDetailsCallback onLineDetails;

  /// The service the cubit locates with: its settings pages are where
  /// the rider fixes a denied permission or a switched-off location.
  final LocationService locationService;

  /// Anchors this visit on a street instead of locating the rider.
  final NearbyStreetAnchor? initialStreet;

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

  /// The lowest the collapsed sheet goes; it grows past this to keep the
  /// grabber and the pinned header above the navigation bar
  /// ([_sheetMinSizeFor]).
  static const double _sheetMinSize = 0.14;

  /// The highest the collapsed sheet goes, below the mid snap.
  static const double _sheetMinCap = 0.3;

  /// [TrufiBottomSheet]'s grabber: 4 px with 12 above and 8 below.
  static const double _sheetGrabberHeight = 24;
  static const double _sheetInitialSize = 0.35;
  static const double _sheetMaxSize = 0.85;
  static const double _controlsTopInset = 12;

  /// The map controls' distance from the right edge (the home screen's).
  static const double _controlsRight = 16;

  /// Room between the header card and the map controls on phones.
  static const double _controlsGap = 12;
  static const double _wideFitPadding = 24;

  /// Side margin of the camera fit along a street: half a line label. The
  /// framed area ends on the street's outermost corners, and each carries
  /// its dot and often the label of the line passing there, centred on
  /// the corner: flush with the screen edge both were cut in half (#1054).
  static final EdgeInsets _streetFitMargin = EdgeInsets.symmetric(
    horizontal: nearbyPointMarkerSize.width / 2,
  );

  final TrufiMapController _mapController = TrufiMapController();
  final FitCameraUtil _fitCamera = FitCameraUtil();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  /// Height of the radius pills pinned in the phone sheet's header, as
  /// last laid out (0 until then).
  double _sheetHeaderHeight = 0;

  TrufiCameraPosition? _initialCamera;
  TrufiCameraPosition? _camera;
  bool _outOfFocus = false;

  /// A fit the next build has to run: the one a state change asked for,
  /// the first one of a visit (no viewport before the first layout), or
  /// the one of a revisit whose anchor was already known.
  bool _fitPending = true;
  NearbyLinesState? _lastState;

  /// How much of the map's top the last phone fit kept clear of the title
  /// card (null before the first one). The side panel's card is not over
  /// the map, so its fits do not set it.
  double? _fittedHeaderReserve;

  @override
  void initState() {
    super.initState();
    // The cubit is app-scoped: every visit re-locates and re-queries (or
    // re-anchors on the street it was opened for).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<NearbyLinesCubit>();
      final street = widget.initialStreet;
      if (street != null) {
        cubit.startAlongStreet(street);
      } else {
        cubit.start();
      }
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

  /// Camera side effects: fit the search area when the anchor or radius
  /// moves. Highlighting a line, or clearing it, leaves the camera where
  /// the rider has it: the line's label is already inside the framed ring,
  /// and zooming out to the whole route took the rider away from the
  /// streets they were looking at.
  ///
  /// The fit is only asked for here and runs after the next build
  /// ([_scheduleInitialFit]). This listener runs before the rebuild for
  /// [state], and what the header keeps clear of the map is set on build:
  /// fitting here framed the new state under the previous one's header.
  /// A visit starts on the fallback header, the tallest, so with a fix
  /// its first ring came out smaller than it then stays — 268 px instead
  /// of 334 on a 360x640 phone.
  void _onStateChanged(NearbyLinesState state) {
    final previous = _lastState;
    _lastState = state;
    final anchor = state.anchor;
    if (anchor == null) return;

    final anchorChanged =
        previous?.anchor != anchor || previous?.street != state.street;
    final radiusChanged = previous?.radius != state.radius;
    if (anchorChanged || radiusChanged) _fitPending = true;
  }

  /// Frames the search area: the ring, or the street's corners.
  void _fitState(NearbyLinesState state, LatLng anchor) {
    _fitTo(
      _searchArea(state, anchor),
      fallbackTarget: anchor,
      margin: _framesStreet(state) ? _streetFitMargin : EdgeInsets.zero,
    );
  }

  /// Whether the search area is a street's corners rather than a ring (a
  /// one-corner street is a ring again).
  static bool _framesStreet(NearbyLinesState state) =>
      (state.street?.corners.length ?? 0) > 1;

  /// What the camera frames: the selected ring, or every corner of the
  /// street.
  static List<LatLng> _searchArea(NearbyLinesState state, LatLng anchor) {
    if (_framesStreet(state)) return state.street!.corners;
    return NearbyGeometry.circlePolygon(anchor, state.radius.meters);
  }

  /// [margin] is kept clear around [points] on top of what the layout
  /// already keeps clear of the header, the sheet or the side panel.
  void _fitTo(
    List<LatLng> points, {
    required LatLng fallbackTarget,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    _fitCamera.updatePadding(margin);
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

  /// Called from build once the viewport and this state's insets are
  /// known: runs the pending fit after the frame.
  void _scheduleInitialFit(NearbyLinesState state) {
    final anchor = state.anchor;
    if (!_fitPending || anchor == null) return;
    _fitPending = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitState(state, anchor);
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

  /// The "use my location" button. The locate of a visit is silent; this
  /// one the rider asked for, so when it finds no position it says why
  /// instead of leaving the screen as it was (trufi-app#78).
  Future<void> _useMyLocation() async {
    final failure = await context.read<NearbyLinesCubit>().useMyLocation();
    if (failure == null || !mounted) return;
    showNearbyLocateFailure(
      context,
      failure,
      locationService: widget.locationService,
    );
  }

  void _tryOpenDrawer() {
    HapticFeedback.lightImpact();
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) scaffold!.openDrawer();
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
    // The card changed height since the last fit without the anchor
    // moving: the pin hint came with a locate that failed on an anchor
    // that stays ("Use my location" with location off, a revisit without
    // a fix). Frame again, or the top of the ring, where its distance
    // label is, sits under the taller card.
    if (_fittedHeaderReserve != null && _fittedHeaderReserve != headerReserve) {
      _fitPending = true;
    }
    // Nothing covers the map's sides on a phone; what a street needs
    // there is added per fit (see [_streetFitMargin]).
    _fitCamera.updateViewport(
      Size(constraints.maxWidth, constraints.maxHeight),
      EdgeInsets.only(
        top: viewPadding.top + headerReserve,
        bottom: viewPadding.bottom + constraints.maxHeight * _sheetInitialSize,
        left: viewPadding.left,
        right: viewPadding.right,
      ),
    );
    if (_fitPending && state.anchor != null) {
      _fittedHeaderReserve = headerReserve;
    }
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
              // The controls hang under the card whatever height its text
              // takes (a long label, a larger font size), right-aligned
              // 16 px from the edge like the home screen's.
              child: Column(
                // The controls stay on the physical right in every
                // language, like the home screen's (`Positioned(right:
                // 16)`) and this screen's side-panel layout. Without this,
                // `end` is the left edge in Arabic and the 4 px below lands
                // on the wrong side. Only this column's alignment: the
                // header row keeps the app's direction.
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildHeader(state, elevated: true),
                  const SizedBox(height: _controlsGap),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: _controlsRight - _headerPadding,
                    ),
                    child: _buildControls(manager, state),
                  ),
                ],
              ),
            ),
          ),
        ),
        TrufiBottomSheet(
          controller: _sheetController,
          initialChildSize: _sheetInitialSize,
          minChildSize: _sheetMinSizeFor(
            // The sheet's sizes are fractions of what TrufiBottomSheet's
            // SafeArea leaves under the status bar, not of the screen.
            constraints.maxHeight - MediaQuery.paddingOf(context).top,
            viewPadding.bottom,
          ),
          maxChildSize: _sheetMaxSize,
          snap: true,
          // The min and the max snap implicitly. The list stays the same
          // instance on every build: on a new one the sheet runs
          // goBallistic(0) on its positions after the frame
          // (DraggableScrollableSheet.didUpdateWidget), which stops a
          // reveal under way in the list.
          snapSizes: const [_sheetInitialSize],
          // Pinned like the home screen's results summary (#1055): the
          // pills stay in view while the list scrolls, and dragging them
          // resizes the sheet even when the list is scrolled (after a
          // reveal) and swallows the drags on the rows.
          header: _MeasureHeight(
            onChanged: _onSheetHeaderHeight,
            child: _buildListHeader(state),
          ),
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
                  // Inset like the route detail's side-panel header.
                  Padding(
                    padding: const EdgeInsets.all(_headerPadding),
                    child: _buildHeader(state, elevated: false),
                  ),
                  _buildListHeader(state),
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
                right: _controlsRight,
                child: _buildControls(manager, state),
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
    return NearbyHeaderCard(
      state: state,
      elevated: elevated,
      onMenu: _tryOpenDrawer,
      // A street visit is pushed from the search screen: back, not menu.
      onBack: widget.initialStreet == null ? null : _back,
    );
  }

  void _back() {
    HapticFeedback.lightImpact();
    Navigator.of(context).maybePop();
  }

  Widget _buildControls(MapEngineManager manager, NearbyLinesState state) {
    return _MapControls(
      manager: manager,
      outOfFocus: _outOfFocus,
      onReFit: _reFitCamera,
      isLocating: state.isLocating,
      anchoredOnDevice: state.anchorSource == NearbyAnchorSource.device,
      onUseMyLocation: _useMyLocation,
    );
  }

  /// The collapsed sheet's size: the grabber and the pinned header whole
  /// above the navigation bar, which the sheet runs under. [sheetHeight] is
  /// the height the sheet's fractions apply to.
  double _sheetMinSizeFor(double sheetHeight, double bottomInset) {
    final needed = _sheetGrabberHeight + _sheetHeaderHeight + bottomInset;
    return (needed / sheetHeight).clamp(_sheetMinSize, _sheetMinCap);
  }

  void _onSheetHeaderHeight(double height) {
    if (!mounted || height == _sheetHeaderHeight) return;
    setState(() => _sheetHeaderHeight = height);
  }

  /// The radius pills, pinned above the rows in both layouts.
  Widget _buildListHeader(NearbyLinesState state) {
    return NearbyLinesHeader(
      state: state,
      onRadiusChanged: context.read<NearbyLinesCubit>().setRadius,
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
      onRetry: cubit.refresh,
      showHeader: false,
    );
  }
}

/// The map's control column, in the home screen's order and style: the map
/// type switcher (when the app ships several engines), "use my location",
/// and the re-fit button that appears once the rider pans away from the
/// search area.
class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.manager,
    required this.outOfFocus,
    required this.onReFit,
    required this.isLocating,
    required this.anchoredOnDevice,
    required this.onUseMyLocation,
  });

  final MapEngineManager manager;
  final bool outOfFocus;
  final VoidCallback onReFit;

  /// The locate button spins and ignores taps meanwhile.
  final bool isLocating;

  /// The search is anchored on the device position: filled glyph, as the
  /// home screen's button while it tracks the rider.
  final bool anchoredOnDevice;
  final VoidCallback onUseMyLocation;

  @override
  Widget build(BuildContext context) {
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
        _MapControlButton(
          icon: anchoredOnDevice
              ? Icons.my_location_rounded
              : Icons.my_location_outlined,
          tooltip: l10n.nearbyUseMyLocation,
          onPressed: onUseMyLocation,
          isLoading: isLocating,
        ),
        const SizedBox(height: 8),
        AnimatedOpacity(
          opacity: outOfFocus ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: outOfFocus ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 200),
            child: _MapControlButton(
              icon: Icons.crop_free_rounded,
              onPressed: outOfFocus ? onReFit : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// The home screen's 48 px map control: card colour, 12 px corners,
/// elevation 4 and a `primary` glyph — the same size as [MapTypeButton]
/// above it.
class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Shows a spinner instead of [icon] and ignores taps.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null && !isLoading;
    final button = Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  icon,
                  size: 22,
                  color: onPressed != null
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
        ),
      ),
    );
    final message = tooltip;
    return message == null ? button : Tooltip(message: message, child: button);
  }
}

/// Reports its child's height after each layout that changes it.
class _MeasureHeight extends SingleChildRenderObjectWidget {
  const _MeasureHeight({required this.onChanged, required super.child});

  final ValueChanged<double> onChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureHeight(onChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureHeight renderObject,
  ) {
    renderObject.onChanged = onChanged;
  }
}

class _RenderMeasureHeight extends RenderProxyBox {
  _RenderMeasureHeight(this.onChanged);

  ValueChanged<double> onChanged;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _reported) return;
    _reported = height;
    // Not during layout: the callback rebuilds the screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(height));
  }
}
