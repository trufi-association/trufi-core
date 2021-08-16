import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/server_type.dart';
import 'package:trufi_core/pages/home/plan_map/widget/custom_text_button.dart';
import 'package:trufi_core/widgets/fetch_error_handler.dart';

import '../../../keys.dart' as keys;
import '../../../models/trufi_place.dart';
import '../../../trufi_app.dart';
import '../../../widgets/trufi_drawer.dart';
import '../form_fields_landscape.dart';
import '../form_fields_portrait.dart';
import '../setting_payload/date_time_picker/itinerary_date_selector.dart';
import 'widgets/card_itinerary.dart';

class ResultsScreen extends StatelessWidget {
  static const String route = '/';
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  const ResultsScreen(
      {Key key, this.customOverlayWidget, this.customBetweenFabWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final config = context.read<ConfigurationCubit>().state;
    final homePageCubit = context.watch<HomePageCubit>();
    final payloadDataPlanCubit = context.read<PayloadDataPlanCubit>();
    final homePageState = homePageCubit.state;
    final isGraphQlEndpoint = config.serverType == ServerType.graphQLServer;
    final transportSelectionHeight =
        homePageState.hasTransportModes || homePageState.isFetchingModes
            ? 50 * MediaQuery.of(context).textScaleFactor
            : 0;
    return Scaffold(
      key: const ValueKey(keys.homePage),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: isPortrait
              ? Size.fromHeight(
                  isGraphQlEndpoint ? (77.0 + transportSelectionHeight) : 90.0)
              : Size.fromHeight(
                  isGraphQlEndpoint ? 33.0 + transportSelectionHeight : 45.0),
          child: Container(),
        ),
        flexibleSpace: Column(
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
              padding: const EdgeInsets.only(left: 50, right: 8),
              child: ItineraryDateSelector(
                onFetchPlan: () {
                  _callFetchPlan(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: homePageState?.plan?.itineraries?.length,
          itemBuilder: (_, index) {
            return Column(children: [
              if (index == 0)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    "Es gibt ${homePageState?.plan?.itineraries?.length} mögliche Routen für dich:",
                    style: theme.textTheme.bodyText2.copyWith(fontSize: 25),
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: CardItinerary(
                  index: index + 1,
                  itinerary: homePageState?.plan?.itineraries[index],
                ),
              ),
              if (index == homePageState.plan.itineraries.length - 1)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: CustomTextButton(
                    text: 'Auf der Karte anzeigen',
                    onPressed: () {},
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
    await homePageCubit
        .fetchPlan(correlationId, localization, removePlan: false)
        .then((value) => appReviewCubit.incrementReviewWorthyActions())
        .catchError((error) => onFetchError(context, error as Exception));
  }
}
