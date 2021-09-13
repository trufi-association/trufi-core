import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/bike_app_home/details_screen.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';

import '../../../keys.dart' as keys;
import '../../../models/trufi_place.dart';
import '../../../trufi_app.dart';
import 'widgets/ba_form_field_landscape.dart';
import 'widgets/ba_form_field_portrait.dart';
import 'widgets/card_itinerary.dart';
import 'widgets/date_time_picker/date_selector.dart';

class ResultsScreen extends StatefulWidget {
  static const String route = '/';
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;
  final PlanEntity plan;
  final AdEntity ad;

  const ResultsScreen({
    Key key,
    this.customOverlayWidget,
    this.customBetweenFabWidget,
    @required this.plan,
    this.ad,
  }) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  PlanPageController _planPageController;

  @override
  void initState() {
    super.initState();
    _planPageController = PlanPageController(widget.plan, widget.ad);
    if (_planPageController.plan.itineraries.isNotEmpty) {
      _planPageController.inSelectedItinerary.add(
        _planPageController.plan.itineraries.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final localization = TrufiLocalization.of(context);
    final config = context.read<ConfigurationCubit>().state;
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
    return Scaffold(
      key: const ValueKey(keys.homePage),
      backgroundColor: const Color(0xffEAEAEA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () async {
            // await homePageCubit.reset();
            Navigator.maybePop(context);
          },
        ),
        title: Row(
          children: [
            Flexible(
                child: Text(
              homePageState.fromPlace.displayName(localization),
              style: const TextStyle(fontSize: 17),
            )),
            const Icon(
              Icons.arrow_right_alt,
              color: Colors.white,
              size: 35,
            ),
            Flexible(
                child: Text(
              homePageState.toPlace.displayName(localization),
              style: const TextStyle(fontSize: 17),
            )),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      if (isPortrait)
                        BAFormFieldsPortrait(
                          spaceBetween: 5,
                          onSaveFrom: (TrufiLocation fromPlace) =>
                              homePageCubit.setFromPlace(fromPlace),
                          onSaveTo: (TrufiLocation fromPlace) =>
                              homePageCubit.setToPlace(fromPlace),
                          onSwap: () => homePageCubit
                              .swapLocations()
                              .then((value) => _callFetchPlan(context)),
                          showTitle: false,
                        )
                      else
                        BAFormFieldsLandscape(
                          onSaveFrom: (TrufiLocation fromPlace) =>
                              homePageCubit.setFromPlace(fromPlace),
                          onSaveTo: (TrufiLocation fromPlace) =>
                              homePageCubit.setToPlace(fromPlace),
                          onSwap: () => homePageCubit
                              .swapLocations()
                              .then((value) => _callFetchPlan(context)),
                        ),
                      const SizedBox(height: 15),
                      DateSelector(
                        color: const Color(0xff747474),
                        onFetchPlan: () {
                          _callFetchPlan(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    color: const Color(0xffF4F4F4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: homePageState?.plan?.itineraries?.length,
                      itemBuilder: (_, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index == 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 30),
                                child: Text(
                                  "Es gibt ${homePageState?.plan?.itineraries?.length} mögliche Routen",
                                  style: theme.textTheme.subtitle1
                                      .copyWith(fontSize: 25),
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                _planPageController.inSelectedItinerary.add(
                                  homePageState?.plan?.itineraries[index]
                                      .copyWith(isOnlyShowItinerary: true),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BikeDetailScreen(
                                      planPageController: _planPageController,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                child: CardItinerary(
                                  index: index + 1,
                                  itinerary:
                                      homePageState?.plan?.itineraries[index],
                                ),
                              ),
                            ),
                            if (index ==
                                homePageState.plan.itineraries.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: Center(
                                  child: homePageState.isFetchLater
                                      ? const CircularProgressIndicator()
                                      : OutlinedButton(
                                          onPressed: () async {
                                            _fetchMoreitineraries(
                                                context: context,
                                                isFetchEarlier: false);
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                    EdgeInsets>(
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10)),
                                            side: MaterialStateProperty.all<
                                                BorderSide>(
                                              BorderSide(
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                            ),
                                          ),
                                          child: SizedBox(
                                            width: 140,
                                            child: Text(
                                              // TODO translate
                                              'ZEIG MEHR',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (config.animations.loading != null && homePageState.isFetching)
              Positioned.fill(
                  child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ))
          ],
        ),
      ),
    );
  }

  Future<void> _callFetchPlan(BuildContext context) async {
    final TrufiLocalization localization = TrufiLocalization.of(context);
    final homePageCubit = context.read<HomePageCubit>();
    final appReviewCubit = context.read<AppReviewCubit>();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    await homePageCubit
        .fetchPlan(correlationId, localization,
            advancedOptions: payloadDataPlanCubit.state, removePlan: false)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
    _planPageController =
        PlanPageController(homePageCubit.state.plan, widget.ad);
  }

  Future<void> _fetchMoreitineraries({
    @required BuildContext context,
    @required bool isFetchEarlier,
  }) async {
    final TrufiLocalization localization = TrufiLocalization.of(context);
    final appReviewCubit = context.read<AppReviewCubit>();
    final homePageCubit = context.read<HomePageCubit>();
    final homePageState = homePageCubit.state;
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    final correlationId = context.read<PreferencesCubit>().state.correlationId;
    if (!homePageState.isFetchLater) {
      await homePageCubit
          .fetchMoreDeparturePlan(
            correlationId,
            localization,
            advancedOptions: payloadDataPlanCubit.state,
            isFetchEarlier: isFetchEarlier,
            itineraries: homePageState.plan.itineraries,
          )
          .then((value) => appReviewCubit.incrementReviewWorthyActions())
          .catchError((error) => onFetchError(context, error as Exception));
    }
    _planPageController =
        PlanPageController(homePageCubit.state.plan, widget.ad);
  }
}
