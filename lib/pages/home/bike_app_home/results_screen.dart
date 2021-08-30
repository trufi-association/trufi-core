import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/bike_app_home/details_screen.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';
import 'package:trufi_core/pages/home/plan_map/widget/custom_text_button.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';
import 'package:trufi_core/widgets/trufi_scaffold.dart';

import '../../../keys.dart' as keys;
import '../../../models/trufi_place.dart';
import '../../../trufi_app.dart';
import '../../../widgets/trufi_drawer.dart';
import '../form_fields_landscape.dart';
import '../form_fields_portrait.dart';
import '../setting_payload/date_time_picker/itinerary_date_selector.dart';
import 'widgets/card_itinerary.dart';

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

    final homePageCubit = context.watch<HomePageCubit>();
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    final homePageState = homePageCubit.state;
    return TrufiScaffold(
      key: const ValueKey(keys.homePage),
      appBar: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPortrait)
            FormFieldsPortrait(
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
          else
            FormFieldsLandscape(
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ItineraryDateSelector(
              onFetchPlan: () {
                _callFetchPlan(context);
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: homePageState?.plan?.itineraries?.length,
          itemBuilder: (_, index) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Text(
                        "Es gibt ${homePageState?.plan?.itineraries?.length} mögliche Routen",
                        style: theme.textTheme.subtitle1.copyWith(fontSize: 25),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      _planPageController.inSelectedItinerary.add(
                        homePageState?.plan?.itineraries[index],
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
                        itinerary: homePageState?.plan?.itineraries[index],
                      ),
                    ),
                  ),
                  if (index == homePageState.plan.itineraries.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Center(
                        child: CustomTextButton(
                          text: 'ZEIG MEHR',
                          onPressed: () {},
                          color: theme.accentColor,
                          borderRadius: 10,
                          width: 150,
                          height: 45,
                        ),
                      ),
                    ),
                ]);
          }),
      drawer: const TrufiDrawer(ResultsScreen.route),
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
  }
}
