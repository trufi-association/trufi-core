import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_card.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/itinerary_details_card.dart';

class CustomItinerary extends StatefulWidget {
  const CustomItinerary({
    Key? key,
  }) : super(key: key);

  @override
  _CustomItineraryState createState() => _CustomItineraryState();
}

class _CustomItineraryState extends State<CustomItinerary> {
  bool showDetail = false;

  @override
  Widget build(BuildContext context) {
    final mapRouteCubit = context.watch<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    return !showDetail
        ? ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: mapRouteState.plan?.itineraries?.length ?? 0,
            itemBuilder: (buildContext, index) {
              final itinerary = mapRouteState.plan!.itineraries![index];
              return ItineraryCard(
                itinerary: itinerary,
                onTap: () {
                  setState(() {
                    showDetail = true;
                  });
                },
              );
            },
          )
        : mapRouteState.selectedItinerary != null
            ? ItineraryDetailsCard(
                itinerary: mapRouteState.selectedItinerary!,
                onBackPressed: () {
                  setState(() {
                    showDetail = false;
                  });
                },
              )
            : Container();
  }
}
