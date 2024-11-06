import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_card.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/itinerary_details_card.dart';
import 'package:trufi_core/realtime/realtime_routes_cubit/realtime_request_plan.dart';
import 'package:trufi_core/realtime/realtime_routes_cubit/realtime_routes_cubit.dart';

class CustomItinerary extends StatefulWidget {
  final bool Function(TrufiLatLng) moveTo;
  const CustomItinerary({
    super.key,
    required this.moveTo,
  });

  @override
  State<CustomItinerary> createState() => _CustomItineraryState();
}

class _CustomItineraryState extends State<CustomItinerary> {
  late ScrollController _scrollController;
  bool showDetail = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) {
        final routePlannerState = context.read<RoutePlannerCubit>().state;
        final index = routePlannerState.plan?.itineraries
                ?.indexOf(routePlannerState.selectedItinerary!) ??
            0;
        _scrolling(index);
      },
    );
    BackButtonInterceptor.add(myInterceptor, context: context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showDetail) {
      setState(() {
        showDetail = false;
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routePlannerCubit = context.watch<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    return Stack(
      children: [
        Visibility(
          visible: !showDetail,
          maintainState: true,
          child: BlocListener<RoutePlannerCubit, RoutePlannerState>(
            listener: (context, state) {
              if (state.selectedItinerary != null) {
                final index = state.plan?.itineraries
                        ?.indexOf(state.selectedItinerary!) ??
                    0;
                _scrolling(index);
              }
            },
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: routePlannerState.plan?.itineraries?.length ?? 0,
                itemBuilder: (buildContext, index) {
                  final itinerary = routePlannerState.plan!.itineraries![index];
                  return ItineraryCard(
                    itinerary: itinerary,
                    onTap: () {
                      setState(() {
                        showDetail = true;
                      });
                      routePlannerCubit.selectItinerary(itinerary);
                    },
                  );
                },
              ),
            ),
          ),
        ),
        if (showDetail && routePlannerState.selectedItinerary != null)
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            child: ItineraryDetailsCard(
              itinerary: routePlannerState.selectedItinerary!,
              onBackPressed: () {
                setState(() {
                  showDetail = false;
                });
              },
              moveTo: widget.moveTo,
            ),
          )
      ],
    );
  }

  Future<void> _scrolling(int index) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) {
        // _scrollController.animateTo(
        //   105.0 * index,
        //   duration: const Duration(milliseconds: 500),
        //   curve: Curves.easeInOut,
        // );
      },
    );
  }
}
