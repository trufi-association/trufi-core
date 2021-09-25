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
import '../../../trufi_app.dart';
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
    final localization = TrufiLocalization.of(context);
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
    final config = context.read<ConfigurationCubit>().state;
    return Scaffold(
      key: const ValueKey(keys.homePage),
      backgroundColor: const Color(0xffEAEAEA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () async {
            await homePageCubit.resetPlan();
            await Navigator.maybePop(context);
          },
        ),
        actions: const [
          Icon(
            Icons.update,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 20)
        ],
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
      body: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: homePageState?.plan?.itineraries?.length ?? 0,
        itemBuilder: (_, index) {
          return Stack(
            children: [
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 30),
                        child: Center(
                          child: Text(
                            "Es gibt ${homePageState?.plan?.itineraries?.length} mögliche Routen",
                            style: theme.textTheme.subtitle1
                                .copyWith(fontSize: 25),
                          ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: CardItinerary(
                          itinerary: homePageState?.plan?.itineraries[index],
                        ),
                      ),
                    ),
                    if (index == homePageState.plan.itineraries.length - 1)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 50,
                              bottom: 10,
                            ),
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
                                            color:
                                                theme.textTheme.subtitle1.color,
                                          ),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            OutlinedBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                          const Size(200, 50),
                                        ),
                                      ),
                                      child: Text(
                                        // TODO translate
                                        "MEHR ANZEIGEN",
                                        style:
                                            theme.textTheme.subtitle1.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                    ),
                            ),
                          ),
                          if (isPortrait)
                            Column(
                              children: [
                                SizedBox(
                                  height:
                                      homePageState.plan.itineraries.length > 3
                                          ? 0
                                          : ((4 -
                                                      homePageState.plan
                                                          .itineraries.length) *
                                                  110.0) -
                                              80,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Image.asset(
                                    config.pageBackgroundAssetPath,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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
