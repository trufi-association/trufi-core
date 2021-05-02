import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';

import '../../blocs/location_provider_cubit.dart';
import '../../keys.dart' as keys;
import '../../plan/plan.dart';
import '../../plan/plan_empty.dart';
import '../../trufi_app.dart';
import '../../trufi_configuration.dart';
import '../../trufi_models.dart';
import '../../widgets/trufi_drawer.dart';
import 'form_fields_landscape.dart';
import 'form_fields_portrait.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  const HomePage(
      {Key key, this.customOverlayWidget, this.customBetweenFabWidget})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  CancelableOperation<PlanEntity> currentFetchPlanOperation;
  CancelableOperation<AdEntity> currentFetchAdOperation;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final cfg = TrufiConfiguration();
    final homePageState = context.watch<HomePageCubit>().state;
    return Scaffold(
      key: const ValueKey(keys.homePage),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: isPortrait
              ? const Size.fromHeight(45.0)
              : const Size.fromHeight(0.0),
          child: Container(),
        ),
        flexibleSpace: isPortrait
            ? FormFieldsPortrait(
                onReset: _reset,
                onSaveFrom: _setFromPlace,
                onSaveTo: _setToPlace,
                onSwap: _swap,
              )
            : FormFieldsLandscape(
                onReset: _reset,
                onSaveFrom: _setFromPlace,
                onSaveTo: _setToPlace,
                onSwap: _swap,
              ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: homePageState.plan != null &&
                      homePageState.plan.error == null &&
                      !homePageState.isFetching
                  ? PlanPage(
                      homePageState.plan,
                      homePageState.ad,
                      widget.customOverlayWidget,
                      widget.customBetweenFabWidget,
                    )
                  : PlanEmptyPage(
                      onLongPress: _mapLongPress,
                      customOverlayWidget: widget.customOverlayWidget,
                      customBetweenFabWidget: widget.customBetweenFabWidget,
                    ),
            ),
          ),
          if (cfg.animation.loading != null && homePageState.isFetching)
            Positioned.fill(child: cfg.animation.loading)
        ],
      ),
      drawer: const TrufiDrawer(HomePage.route),
    );
  }

  void _mapLongPress(LatLng point) {
    final homePageBloc = context.read<HomePageCubit>();
    if (homePageBloc.state.fromPlace == null) {
      _setFromPlace(
        TrufiLocation.fromLatLng(
          TrufiLocalization.of(context).searchMapMarker,
          point,
        ),
      );
    } else if (homePageBloc.state.toPlace == null) {
      _setToPlace(
        TrufiLocation.fromLatLng(
          TrufiLocalization.of(context).searchMapMarker,
          point,
        ),
      );
    }
  }

  void _reset() {
    context.read<HomePageCubit>().reset();
    // TODO: improve location provider management
    // context.read<LocationProviderCubit>().stop();
  }

  Future<void> _swap() async {
    final homePageBloc = context.read<HomePageCubit>();
    await homePageBloc.swapLocations();
    await _callFetchPlan();
  }

  Future<void> _setFromPlace(TrufiLocation fromPlace) async {
    final homePageBloc = context.read<HomePageCubit>();
    await homePageBloc.setFromPlace(fromPlace);
    await _callFetchPlan();
  }

  // TODO: connect gps location with "From" location
  // ignore: unused_element
  Future<void> _setFromPlaceToCurrentPosition() async {
    final localization = TrufiLocalization.of(context);
    final location =
        await context.read<LocationProviderCubit>().getCurrentLocation();
    if (location != null) {
      _setFromPlace(
        TrufiLocation.fromLatLng(
          localization.searchItemYourLocation,
          location,
        ),
      );
    }
  }

  Future<void> _setToPlace(TrufiLocation toPlace) async {
    final homePageBloc = context.read<HomePageCubit>();
    await homePageBloc.setToPlace(toPlace);
    await _callFetchPlan();
  }

  Future<void> _callFetchPlan() async {
    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    // TODO: the location provider should not start here
    // final locationProviderCubit = context.read<LocationProviderCubit>();
    // locationProviderCubit.start();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    await homePageCubit
        .fetchPlan(correlationId)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
  }
}
