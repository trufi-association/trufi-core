import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';

import '../../keys.dart' as keys;
import '../../plan/plan.dart';
import '../../plan/plan_empty.dart';
import '../../trufi_app.dart';
import '../../trufi_configuration.dart';
import '../../trufi_models.dart';
import '../../widgets/trufi_drawer.dart';
import 'form_fields_landscape.dart';
import 'form_fields_portrait.dart';

class HomePage extends StatelessWidget {
  static const String route = '/';
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  const HomePage(
      {Key key, this.customOverlayWidget, this.customBetweenFabWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final cfg = TrufiConfiguration();
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
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
                onReset: () => homePageCubit.reset(),
                onSaveFrom: (TrufiLocation fromPlace) => homePageCubit
                    .setFromPlace(fromPlace)
                    .then((value) => _callFetchPlan(context)),
                onSaveTo: (TrufiLocation fromPlace) => homePageCubit
                    .setToPlace(fromPlace)
                    .then((value) => _callFetchPlan(context)),
                onSwap: () => homePageCubit
                    .swapLocations()
                    .then((value) => _callFetchPlan(context)),
              )
            : FormFieldsLandscape(
                onReset: () => homePageCubit.reset(),
                onSaveFrom: (TrufiLocation fromPlace) => homePageCubit
                    .setFromPlace(fromPlace)
                    .then((value) => _callFetchPlan(context)),
                onSaveTo: (TrufiLocation fromPlace) => homePageCubit
                    .setToPlace(fromPlace)
                    .then((value) => _callFetchPlan(context)),
                onSwap: () => homePageCubit
                    .swapLocations()
                    .then((value) => _callFetchPlan(context)),
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
                      customOverlayWidget,
                      customBetweenFabWidget,
                    )
                  : PlanEmptyPage(
                      onLongPress: (LatLng point) => homePageCubit
                          .mapLongPress(point)
                          .then((value) => _callFetchPlan(context)),
                      customOverlayWidget: customOverlayWidget,
                      customBetweenFabWidget: customBetweenFabWidget,
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

  Future<void> _callFetchPlan(BuildContext context) async {
    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    await homePageCubit
        .fetchPlan(correlationId)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
  }
}
