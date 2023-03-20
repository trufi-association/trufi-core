import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/custom_itinerary.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/home_app_bar.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/base_build_alert.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';
import 'package:trufi_core/base/widgets/custom_scrollable_container.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class HomePage extends StatefulWidget {
  static const String route = "/Home";
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final WidgetBuilder drawerBuilder;
  final MapRouteProvider mapRouteProvider;
  final MapChooseLocationProvider mapChooseLocationProvider;
  final AsyncExecutor asyncExecutor;

  const HomePage({
    Key? key,
    required this.drawerBuilder,
    required this.mapRouteProvider,
    required this.mapChooseLocationProvider,
    required this.asyncExecutor,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      final mapRouteCubit = context.read<MapRouteCubit>();
      final mapRouteState = mapRouteCubit.state;
      repaintMap(mapRouteCubit, mapRouteState);
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) => processUniLink(),
    );
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) => processUniLink(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapRouteCubit = context.watch<MapRouteCubit>();
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final theme = Theme.of(context);
    return Scaffold(
      key: HomePage.scaffoldKey,
      drawer: widget.drawerBuilder(context),
      appBar: AppBar(
        backgroundColor: ThemeCubit.isDarkMode(theme)
            ? theme.appBarTheme.backgroundColor
            : theme.colorScheme.primary,
        toolbarHeight: 0,
        elevation: 0,
      ),
      extendBody: true,
      body: Column(
        children: [
          HomeAppBar(
            onSaveFrom: (TrufiLocation fromPlace) =>
                mapRouteCubit.setFromPlace(fromPlace).then(
              (value) {
                widget.mapRouteProvider.trufiMapController.move(
                  center: fromPlace.latLng,
                  zoom: mapConfiguratiom.chooseLocationZoom,
                  tickerProvider: this,
                );
                _callFetchPlan(context);
              },
            ),
            onSaveTo: (TrufiLocation toPlace) =>
                mapRouteCubit.setToPlace(toPlace).then(
              (value) {
                widget.mapRouteProvider.trufiMapController.move(
                  center: toPlace.latLng,
                  zoom: mapConfiguratiom.chooseLocationZoom,
                  tickerProvider: this,
                );
                _callFetchPlan(context);
              },
            ),
            onBackButton: () {
              HomePage.scaffoldKey.currentState?.openDrawer();
            },
            onFetchPlan: () => _callFetchPlan(context),
            onReset: () => mapRouteCubit.reset(),
            onSwap: () => mapRouteCubit
                .swapLocations()
                .then((value) => _callFetchPlan(context)),
            selectPositionOnPage: _selectPosition,
          ),
          Expanded(
            child: Stack(
              children: [
                BlocListener<MapRouteCubit, MapRouteState>(
                  listener: (buildContext, state) {
                    widget.mapRouteProvider.trufiMapController.onReady
                        .then((_) {
                      repaintMap(mapRouteCubit, state);
                    });
                  },
                  child: CustomScrollableContainer(
                    openedPosition: 200,
                    body: widget.mapRouteProvider.mapRouteBuilder(
                      context,
                      widget.asyncExecutor,
                    ),
                    panel: mapRouteCubit.state.plan != null
                        ? CustomItinerary(
                            moveTo: (center) {
                              widget.mapRouteProvider.trufiMapController.move(
                                  center: center,
                                  zoom: 16,
                                  tickerProvider: this);
                            },
                          )
                        : null,
                  ),
                ),
                Positioned(
                  top: -3.5,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xaa000000),
                          offset: Offset(0, 1.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void repaintMap(MapRouteCubit mapRouteCubit, MapRouteState mapRouteState) {
    if (mapRouteState.plan != null && mapRouteState.selectedItinerary != null) {
      widget.mapRouteProvider.trufiMapController.selectedItinerary(
        plan: mapRouteState.plan!,
        from: mapRouteState.fromPlace!,
        to: mapRouteState.toPlace!,
        selectedItinerary: mapRouteState.selectedItinerary!,
        tickerProvider: this,
        onTap: (p1) {
          mapRouteCubit.selectItinerary(p1);
        },
      );
    } else {
      widget.mapRouteProvider.trufiMapController.cleanMap();
    }
  }

  Future<void> _callFetchPlan(BuildContext context, {int? numItinerary}) async {
    final mapRouteCubit = context.read<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    if (mapRouteState.toPlace == null || mapRouteState.fromPlace == null) {
      return;
    }
    widget.asyncExecutor.run(
      context: context,
      onExecute: () => mapRouteCubit.fetchPlan(numItinerary: numItinerary),
      onFinish: (_) {
        AppReviewProvider().incrementReviewWorthyActions();
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> processUniLink() async {
    final queryParameters = RouteData.of(context).queryParameters;
    final mapRouteCubit = context.read<MapRouteCubit>();
    if (queryParameters['from'] != null && queryParameters['to'] != null) {
      final originData = queryParameters['from']!.split(",");
      final destinyData = queryParameters['to']!.split(",");
      final originLocation = TrufiLocation(
        description: originData[0],
        latitude: double.tryParse(originData[1])!,
        longitude: double.tryParse(originData[2])!,
      );
      final destinyLocation = TrufiLocation(
        description: destinyData[0],
        latitude: double.tryParse(destinyData[1])!,
        longitude: double.tryParse(destinyData[2])!,
      );
      final numItinerary = int.tryParse(queryParameters['itinerary'] ?? '0');
      await mapRouteCubit.setToPlace(destinyLocation);
      await mapRouteCubit.setFromPlace(originLocation);
      if (!mounted) return;
      await _callFetchPlan(context, numItinerary: numItinerary);
    } else if (queryParameters['googlePoint'] != null) {
      final destinyData = queryParameters['googlePoint']!.split(",");
      final location = TrufiLocation(
        description: destinyData[0].trim(),
        latitude: double.tryParse(destinyData[1])!,
        longitude: double.tryParse(destinyData[2])!,
      );
      await ErrorAlert.showNotification(
        context: context,
        defineStartLocation: () async {
          await mapRouteCubit.setFromPlace(location);
          if (!mounted) return;
          await _callFetchPlan(context, numItinerary: 0);
        },
        defineToLocation: () async {
          await mapRouteCubit.setToPlace(location);
          if (!mounted) return;
          await _callFetchPlan(context, numItinerary: 0);
        },
      );
    }
  }

  Future<LocationDetail?> _selectPosition(
    BuildContext context, {
    bool? isOrigin,
    TrufiLatLng? position,
  }) async {
    return await ChooseLocationPage.selectPosition(
      context,
      mapChooseLocationProvider: widget.mapChooseLocationProvider,
      position: position,
      isOrigin: isOrigin,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppReviewProvider().reviewApp(context, mounted);
    }
  }
}

class ErrorAlert extends StatelessWidget {
  static Future<void> showNotification({
    required BuildContext context,
    required Future Function() defineStartLocation,
    required Future Function() defineToLocation,
  }) async {
    await showTrufiDialog<void>(
      context: context,
      onWillPop: false,
      builder: (_) {
        return ErrorAlert(
          defineFromLocation: defineStartLocation,
          defineToLocation: defineToLocation,
        );
      },
    );
  }

  final Future Function() defineFromLocation;
  final Future Function() defineToLocation;
  const ErrorAlert({
    Key? key,
    required this.defineFromLocation,
    required this.defineToLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
      iconPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      title: Text(
        // TODO translate
        TrufiBaseLocalization.of(context).localeName == "en"
            ? "Set location on map"
            : "Establecer ubicación en el mapa",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.secondary,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              // TODO translate
              TrufiBaseLocalization.of(context).localeName == "en"
                  ? 'You can set the location as an origin or destination point'
                  : "Puede establecer la ubicación como un punto de origen o de destino",
              style: theme.textTheme.bodyText2?.copyWith(fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              defineFromLocation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              // TODO translate
              TrufiBaseLocalization.of(context).localeName == "en"
                  ? 'Set location as origin'
                  : "Establecer como origen",
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              defineToLocation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              // TODO translate
              TrufiBaseLocalization.of(context).localeName == "en"
                  ? 'Set location as destiny'
                  : "Establecer como destino",
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 0),
        ],
      ),
      actions: const [
        CancelButton(),
      ],
    );
  }
}
