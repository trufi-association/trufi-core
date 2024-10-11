import 'package:flutter/material.dart';

import 'package:async_executor/async_executor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/panel/panel_cubit.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:trufi_core/base/blocs/providers/uni_link_provider/geo_location.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/custom_itinerary.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/home_app_bar.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/base_build_alert.dart';
import 'package:trufi_core/base/widgets/alerts/error_base_alert.dart';
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
    super.key,
    required this.drawerBuilder,
    required this.mapRouteProvider,
    required this.mapChooseLocationProvider,
    required this.asyncExecutor,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<CustomScrollableContainerState> scrollController =
      GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    final routePlannerCubit = context.watch<RoutePlannerCubit>();
    final panelCubit = context.watch<PanelCubit>();
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final theme = Theme.of(context);
    widget.mapRouteProvider.trufiMapController.onReady.then((value) {
      if (panelCubit.state.panel != null &&
          routePlannerCubit.state.plan == null) {
        widget.mapRouteProvider.trufiMapController.move(
          center: panelCubit.state.panel!.position,
          zoom: 17,
          tickerProvider: this,
        );
      }
    });
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
      body: Container(
        color: theme.cardColor,
        child: SafeArea(
          child: Column(
            children: [
              HomeAppBar(
                onSaveFrom: (TrufiLocation fromPlace) =>
                    routePlannerCubit.setFromPlace(fromPlace).then(
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
                    routePlannerCubit.setToPlace(toPlace).then(
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
                onReset: () {
                  widget.mapRouteProvider.trufiMapController.cleanMap();
                  routePlannerCubit.reset();
                },
                onSwap: () => routePlannerCubit
                    .swapLocations()
                    .then((value) => _callFetchPlan(context)),
                selectPositionOnPage: _selectPosition,
              ),
              Expanded(
                child: Stack(
                  children: [
                    CustomScrollableContainer(
                      key: scrollController,
                      openedPosition: 200,
                      body: widget.mapRouteProvider.mapRouteBuilder(
                        context,
                        widget.asyncExecutor,
                      ),
                      bottomPadding: panelCubit.state.panel?.minSize ?? 0,
                      panel: panelCubit.state.panel == null
                          ? routePlannerCubit.state.plan != null
                              ? CustomItinerary(
                                  moveTo: (center) {
                                    final callResize = scrollController
                                                .currentState?.panelHeight !=
                                            null &&
                                        scrollController
                                                .currentState!.panelHeight ==
                                            0;
                                    if (callResize) {
                                      scrollController.currentState
                                          ?.scrollFunction(
                                        scrollValue: 0.7,
                                      );
                                    }
                                    widget.mapRouteProvider.trufiMapController
                                        .move(
                                            center: center,
                                            zoom: 16,
                                            tickerProvider: this);
                                    return callResize;
                                  },
                                )
                              : null
                          : panelCubit.state.panel?.panel(context, () {
                              panelCubit.cleanPanel();
                              _callFetchPlan(context);
                            }),
                      onClose: panelCubit.state.panel == null
                          ? null
                          : panelCubit.cleanPanel,
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
                    Positioned(
                      top: 22.0,
                      left: 8.0,
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: CitySelectionManager().currentCity ==
                                  CityInstance.zitacuaro
                              ? theme.floatingActionButtonTheme.backgroundColor
                              : CitySelectionManager().currentCity ==
                                      CityInstance.zamora
                                  ? theme.colorScheme.primary
                                  : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xaa000000),
                              offset: Offset(0, 1.5),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              CitySelectionManager().assignNextCity();
                              setState(() {});
                              widget.mapRouteProvider.trufiMapController.onReady
                                  .then((value) {
                                widget.mapRouteProvider.trufiMapController.move(
                                  center:
                                      CitySelectionManager().currentCity.center,
                                  zoom: 13,
                                );
                              });
                              widget.mapRouteProvider.trufiMapController
                                  .cleanMap();
                              routePlannerCubit.reset();
                            },
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    CitySelectionManager().currentCity ==
                                            CityInstance.zitacuaro
                                        ? "Zitácuaro"
                                        : CitySelectionManager().currentCity ==
                                                CityInstance.zamora
                                            ? "Zamora"
                                            : "Uruapan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          CitySelectionManager().currentCity ==
                                                  CityInstance.zitacuaro
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.surface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Tooltip(
                                  triggerMode: TooltipTriggerMode.tap,
                                  message:
                                      "Press the button for change the city, current support Zitacuaro and Zamora",
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  verticalOffset: 18,
                                  showDuration: const Duration(seconds: 10),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 11,
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callFetchPlan(BuildContext context, {int? numItinerary}) async {
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    if (routePlannerState.toPlace == null ||
        routePlannerState.fromPlace == null) {
      return;
    }
    widget.asyncExecutor.run(
      context: context,
      onExecute: () => routePlannerCubit.fetchPlan(numItinerary: numItinerary),
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
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    if (queryParameters['hasError'] != null) {
      ErrorAlert.showError(
        context: context,
        // TODO translation
        error: "This link cannot be used to set it as a point.",
      );
    } else if (queryParameters['from'] != null &&
        queryParameters['to'] != null) {
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
      await routePlannerCubit.setToPlace(destinyLocation);
      await routePlannerCubit.setFromPlace(originLocation);
      if (!mounted) return;
      await _callFetchPlan(context, numItinerary: numItinerary);
    } else if (queryParameters['type'] == GeoLocation.type) {
      final location = GeoLocation.fromJson(queryParameters).trufiLocation;
      await UniLinkAlert.showNotification(
        context: context,
        defineStartLocation: () async {
          await routePlannerCubit.setFromPlace(location);
          if (!mounted) return;
          await _callFetchPlan(context, numItinerary: 0);
        },
        defineToLocation: () async {
          await routePlannerCubit.setToPlace(location);
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

class UniLinkAlert extends StatelessWidget {
  static Future<void> showNotification({
    required BuildContext context,
    required Future Function() defineStartLocation,
    required Future Function() defineToLocation,
  }) async {
    await showTrufiDialog<void>(
      context: context,
      onWillPop: false,
      builder: (_) {
        return UniLinkAlert(
          defineFromLocation: defineStartLocation,
          defineToLocation: defineToLocation,
        );
      },
    );
  }

  final Future Function() defineFromLocation;
  final Future Function() defineToLocation;
  const UniLinkAlert({
    super.key,
    required this.defineFromLocation,
    required this.defineToLocation,
  });

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
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
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
