import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinarary_details_collapsed/itinerary_summary_advanced.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinerary_details_expanded/leg_overview_advanced/leg_overview_advanced.dart';

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
    return Theme(
      data: theme,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: currentPlanItinerary == null || !showDetail
            ? ListView.builder(
                itemCount: widget.planPageController.plan.itineraries.length,
                itemBuilder: (buildContext, index) {
                  final itinerary =
                      widget.planPageController.plan.itineraries[index];
                  return GestureDetector(
                    onTap: () {
                      widget.planPageController.inSelectedItinerary
                          .add(itinerary);
                    },
                    child: Container(
                      // for avoid bad behavior of gesture detector
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                              left: 12.0,
                              right: 45.0,
                              top: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if (itinerary.hasAdvencedData)
                                  Text(
                                    "${itinerary.startTimeHHmm} - ${itinerary.endTimeHHmm}    ",
                                    style: theme.primaryTextTheme.bodyText1
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    if (itinerary.hasAdvencedData)
                                      Text(
                                        "${itinerary.durationTripString(localization)} ",
                                        style: theme.primaryTextTheme.bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                      )
                                    else
                                      Text(
                                        "${localization.instructionDurationMinutes(itinerary.time)} ",
                                        style: theme.primaryTextTheme.bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                    Text(
                                      "(${itinerary.getDistanceString(localization)})",
                                      style: theme.primaryTextTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 50,
                                color: currentPlanItinerary == itinerary
                                    ? theme.primaryColor
                                    : Colors.grey[200],
                                margin: const EdgeInsets.only(right: 5),
                              ),
                              Expanded(
                                child: LayoutBuilder(
                                    builder: (builderContext, constrains) {
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
                                  widget.planPageController.inSelectedItinerary
                                      .add(itinerary);
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
                          const Divider(),
                        ],
                      ),
                    ),
                  );
                })
            : ListView(
                children: [
                  LegOverviewAdvanced(
                      onBackPressed: () {
                        setState(() {
                          showDetail = false;
                        });
                      },
                      itinerary: currentPlanItinerary),
                ],
              ),
      ),
    );
  }
}
