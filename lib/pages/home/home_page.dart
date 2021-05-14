import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/models/enums/server_type.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';
import 'package:trufi_core/pages/home/plan_map/plan_empty.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';

import '../../keys.dart' as keys;
import '../../trufi_app.dart';
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

    final config = context.read<ConfigurationCubit>().state;
    final homePageCubit = context.watch<HomePageCubit>();
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    final homePageState = homePageCubit.state;
    final isGraphQlEndpoint = config.serverType == ServerType.graphQLServer;
    return Scaffold(
      key: const ValueKey(keys.homePage),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: isPortrait
              ? Size.fromHeight(isGraphQlEndpoint ? 77.0 : 45.0)
              : Size.fromHeight(isGraphQlEndpoint ? 33.0 : 0.0),
          child: Container(),
        ),
        flexibleSpace: isPortrait
            ? FormFieldsPortrait(
                onFetchPlan: () {
                  _callFetchPlan(context);
                },
                onReset: () async {
                  await homePageCubit.reset();
                  await payloadDataPlanCubit.resetDataDate();
                },
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
                onFetchPlan: () {
                  _callFetchPlan(context);
                },
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
                      onFetchPlan: () {
                        _callFetchPlan(context);
                      },
                      customOverlayWidget: customOverlayWidget,
                      customBetweenFabWidget: customBetweenFabWidget,
                    ),
            ),
          ),
          if (config.animations.loading != null && homePageState.isFetching)
            Positioned.fill(child: config.animations.loading)
        ],
      ),
      drawer: const TrufiDrawer(HomePage.route),
    );
  }

  Future<void> _callFetchPlan(BuildContext context) async {
    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    await homePageCubit
        .fetchPlan(correlationId, advancedOptions: payloadDataPlanCubit.state)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
  }
}
