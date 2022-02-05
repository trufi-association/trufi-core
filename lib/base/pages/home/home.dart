import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_utils.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/custom_itinerary.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/home_app_bar.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/trufi_map_route.dart';
import 'package:trufi_core/base/widgets/custom_scrollable_container.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';

class HomePage extends StatefulWidget {
  static const String route = "/Home";
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final WidgetBuilder drawerBuilder;
  final MapRouteBuilder mapBuilder;

  const HomePage({
    Key? key,
    required this.drawerBuilder,
    required this.mapBuilder,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TrufiMapController trufiMapController = TrufiMapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance?.addPostFrameCallback((duration) {
      final mapRouteCubit = context.read<MapRouteCubit>();
      final mapRouteState = mapRouteCubit.state;
      repaintMap(mapRouteCubit, mapRouteState);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapRouteCubit = context.watch<MapRouteCubit>();
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return Scaffold(
      key: HomePage.scaffoldKey,
      drawer: widget.drawerBuilder(context),
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(
              onSaveFrom: (TrufiLocation fromPlace) =>
                  mapRouteCubit.setFromPlace(fromPlace).then(
                (value) {
                  trufiMapController.move(
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
                  trufiMapController.move(
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
            ),
            Expanded(
              child: BlocListener<MapRouteCubit, MapRouteState>(
                listener: (buildContext, state) {
                  trufiMapController.mapController.onReady.then((_) {
                    repaintMap(mapRouteCubit, state);
                  });
                },
                child: CustomScrollableContainer(
                  openedPosition: 200,
                  body: widget.mapBuilder(
                    context,
                    trufiMapController,
                  ),
                  panel: mapRouteCubit.state.plan != null
                      ? const CustomItinerary()
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void repaintMap(MapRouteCubit mapRouteCubit, MapRouteState mapRouteState) {
    if (mapRouteState.plan != null && mapRouteState.selectedItinerary != null) {
      trufiMapController.selectedItinerary(
          plan: mapRouteState.plan!,
          from: mapRouteState.fromPlace!,
          to: mapRouteState.toPlace!,
          selectedItinerary: mapRouteState.selectedItinerary!,
          tickerProvider: this,
          onTap: (p1) {
            mapRouteCubit.selectItinerary(p1);
          });
    } else {
      trufiMapController.cleanMap();
    }
  }

  Future<void> _callFetchPlan(BuildContext context) async =>
      await callFetchPlan(context);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppReviewProvider().reviewApp(context);
    }
  }
}
