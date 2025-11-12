import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';

class ShareItineraryButton extends StatelessWidget {
  final Uri shareBaseItineraryUri;

  const ShareItineraryButton({
    super.key,
    required this.shareBaseItineraryUri,
  });

  @override
  Widget build(BuildContext context) {
    final routePlannerCubit = context.watch<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    return FloatingActionButton(
      onPressed: () async {
        final index = routePlannerState.plan?.itineraries
                ?.indexOf(routePlannerState.selectedItinerary!) ??
            0;
        final from =
            "${routePlannerState.fromPlace?.description},${routePlannerState.fromPlace?.latLng.latitude},${routePlannerState.fromPlace?.latLng.longitude}";
        final to =
            "${routePlannerState.toPlace?.description},${routePlannerState.toPlace?.latLng.latitude},${routePlannerState.toPlace?.latLng.longitude}";

        final box = context.findRenderObject() as RenderBox?;
        Share.share(
          shareBaseItineraryUri.replace(
            queryParameters: {
              "from": from,
              "to": to,
              "itinerary": index.toString(),
            },
          ).toString(),
          sharePositionOrigin: !kIsWeb && Platform.isIOS && box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        );
      },
      heroTag: null,
      child: const Icon(
        Icons.share,
      ),
    );
  }
}
