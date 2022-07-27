import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';

class ShareItineraryButton extends StatelessWidget {
  const ShareItineraryButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapRouteCubit = context.watch<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    return FloatingActionButton(
      onPressed: () async {
        final index = mapRouteState.plan?.itineraries
                ?.indexOf(mapRouteState.selectedItinerary!) ??
            0;
        final from =
            "${mapRouteState.fromPlace?.description},${mapRouteState.fromPlace?.latLng.latitude},${mapRouteState.fromPlace?.latLng.longitude}";
        final to =
            "${mapRouteState.toPlace?.description},${mapRouteState.toPlace?.latLng.latitude},${mapRouteState.toPlace?.latLng.longitude}";
        Share.share(Uri(
          scheme: "https",
          host: "cbba.trufi.dev",
          path: "/app/Home",
          queryParameters: {
            "from": from,
            "to": to,
            "itinerary": index.toString(),
          },
        ).toString());
      },
      heroTag: null,
      child: const Icon(
        Icons.share,
      ),
    );
  }
}
