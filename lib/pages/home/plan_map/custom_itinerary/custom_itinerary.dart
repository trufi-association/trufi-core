import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/entities/plan_entity/enum/plan_info_box.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/modes_transport_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinarary_details_collapsed/itinerary_summary_advanced.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinerary_details_expanded/leg_overview_advanced/leg_overview_advanced.dart';
import 'package:trufi_core/pages/home/plan_map/widget/info_message.dart';
import 'package:trufi_core/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../plan.dart';

class CustomItinerary extends StatefulWidget {
  final PlanPageController planPageController;

  const CustomItinerary({Key key, @required this.planPageController})
      : super(key: key);

  @override
  _CustomItineraryState createState() => _CustomItineraryState();
}

class _CustomItineraryState extends State<CustomItinerary> {
  PlanItinerary currentPlanItinerary;
  bool showDetail = false;

  @override
  void initState() {
    currentPlanItinerary = widget.planPageController.selectedItinerary;
    super.initState();
    widget.planPageController.outSelectedItinerary.listen((selectedItinerary) {
      if (mounted) {
        setState(() {
          currentPlanItinerary = selectedItinerary;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>().state.bottomBarTheme;
    final localization = TrufiLocalization.of(context);
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
    return Theme(
        data: theme,
        child: !showDetail
            ? widget.planPageController.plan.isOnlyWalk &&
                    widget.planPageController.plan.type != 'walkPlan'
                ? ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: InfoMessage(
                          message: homePageState.plan.planInfoBox
                              .translateValue(localization),
                          isErrorMessage:
                              !homePageState.plan.isTypeMessageInformation,
                          widget: homePageState.plan.isOutSideLocation
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 21),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        style: theme.textTheme.bodyText1
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                        text: localization
                                            .infoMessageUseNationalServicePrefix,
                                      ),
                                      TextSpan(
                                        style: theme.primaryTextTheme.bodyText2
                                            .copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                        text: ' Fahrplanauskunft efa-bw',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launch('https://www.efa-bw.de');
                                          },
                                      )
                                    ]),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount:
                        widget.planPageController.plan.itineraries.length,
                    itemBuilder: (buildContext, index) {
                      final itinerary =
                          widget.planPageController.plan.itineraries[index];
                      int lengthBikePark;
                      if (widget.planPageController.plan.type ==
                          'bikeAndPublicPlan') {
                        lengthBikePark = filterOnlyBikeAndWalk(homePageState
                                    .modesTransport
                                    ?.bikeParkPlan
                                    ?.itineraries ??
                                [])
                            ?.length;
                      }
                      return GestureDetector(
                        onTap: () {
                          if (currentPlanItinerary != itinerary) {
                            widget.planPageController.inSelectedItinerary
                                .add(itinerary);
                          } else {
                            setState(() {
                              showDetail = true;
                            });
                            widget.planPageController.inSelectedItinerary.add(
                              itinerary.copyWith(
                                isOnlyShowItinerary: true,
                              ),
                            );
                          }
                        },
                        child: Container(
                          // for avoid bad behavior of gesture detector
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (index == 0 &&
                                  widget?.planPageController?.plan
                                          ?.planInfoBox !=
                                      PlanInfoBox.undefined)
                                Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    child: InfoMessage(
                                      message: homePageState.plan.planInfoBox
                                          .translateValue(localization),
                                      closeInfo: () {
                                        homePageCubit.updateMapRouteState(
                                          homePageState.copyWith(
                                            plan: homePageState.plan.copyWith(
                                              planInfoBox:
                                                  PlanInfoBox.undefined,
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                              if (index == 0 &&
                                  lengthBikePark != null &&
                                  lengthBikePark > 0)
                                Container(
                                  color: Colors.grey[200],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 10),
                                    child: Text(
                                      localization
                                          .itinerarySummaryBikeParkTitle,
                                      style: theme.primaryTextTheme.bodyText1
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              if (lengthBikePark != null &&
                                  lengthBikePark == index &&
                                  lengthBikePark <
                                      widget.planPageController.plan.itineraries
                                          .length)
                                Container(
                                  color: Colors.grey[200],
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 10),
                                        child: Text(
                                          localization
                                              .itinerarySummaryBikeAndPublicRailSubwayTitle,
                                          style: theme
                                              .primaryTextTheme.bodyText1
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                padding: EdgeInsets.only(
                                    top: Insets.sm,
                                    bottom: Insets.sm,
                                    right: Insets.xl),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    if (itinerary.hasAdvencedData)
                                      Text(
                                        "${itinerary.futureText(localization)} ${itinerary.startTimeHHmm} - ${itinerary.endTimeHHmm}",
                                        style: theme.primaryTextTheme.bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                    RichText(
                                      textScaleFactor: MediaQuery.of(context)
                                          .textScaleFactor,
                                      text: TextSpan(
                                        style: theme.primaryTextTheme.bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                        text: itinerary.hasAdvencedData
                                            ? itinerary.durationTripString(
                                                localization)
                                            : localization
                                                .instructionDurationMinutes(
                                                    itinerary.time),
                                        children: [
                                          TextSpan(
                                            text:
                                                " (${itinerary.getDistanceString(localization)})",
                                            style: theme
                                                .primaryTextTheme.bodyText2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 50 *
                                          MediaQuery.of(context)
                                              .textScaleFactor,
                                      color: currentPlanItinerary == itinerary
                                          ? theme.primaryColor
                                          : Colors.grey[200],
                                      margin: const EdgeInsets.only(right: 5),
                                    ),
                                    Expanded(
                                      child: LayoutBuilder(builder:
                                          (builderContext, constrains) {
                                        return ItinerarySummaryAdvanced(
                                          maxWidth: constrains.maxWidth,
                                          itinerary: itinerary,
                                        );
                                      }),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showDetail = true;
                                        });
                                        widget.planPageController
                                            .inSelectedItinerary
                                            .add(itinerary.copyWith(
                                                isOnlyShowItinerary: true));
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        width: 30,
                                        height: 50,
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      );
                    })
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  children: [
                    LegOverviewAdvanced(
                        onBackPressed: () {
                          setState(() {
                            showDetail = false;
                          });
                          widget.planPageController.inSelectedItinerary.add(
                              currentPlanItinerary.copyWith(
                                  isOnlyShowItinerary: false));
                        },
                        itinerary: currentPlanItinerary),
                  ],
                ),
              ));
  }
}
