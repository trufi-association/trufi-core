import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/utils/util_icons/icons.dart';

import '../../../choose_location.dart';

class LocationIcon extends StatelessWidget {
  const LocationIcon({
    Key key,
    @required this.location,
    this.margin,
  }) : super(key: key);

  final TrufiLocation location;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
    final config = context.read<ConfigurationCubit>().state;
    return GestureDetector(
      onTap: () async {
        if (!location.isLatLngDefined) {
          await _definePosition(context);
        } else if (homePageState.fromPlace != location &&
            homePageState.toPlace != location) {
          homePageCubit.setPlace(location);
        } else {
          if (homePageState.fromPlace == location) {
            homePageCubit.resetFromPlace();
          } else if (homePageState.toPlace == location) {
            homePageCubit.resetToPlace();
          }
        }
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            margin: margin ?? EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0.0, 1),
                  blurRadius: 2.0,
                ),
              ],
            ),
            child: Icon(
              typeToIconData(location.type) ?? Icons.place,
            ),
          ),
          Positioned(
            bottom: 1,
            right: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!location.isLatLngDefined)
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      Icons.edit_location_alt,
                      color: theme.primaryColor,
                      size: 15,
                    ),
                  )
                else if (homePageState.fromPlace == location)
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: config.markers.fromMarker,
                  )
                else if (homePageState.toPlace == location)
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(1.7),
                    child: config.markers.toMarker,
                  )
                else
                  Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<TrufiLocation> _definePosition(BuildContext context) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final ChooseLocationDetail chooseLocationDetail =
        await ChooseLocationPage.selectPosition(
      context,
      position: location.isLatLngDefined
          ? LatLng(location.latitude, location.longitude)
          : null,
    );
    if (chooseLocationDetail?.location != null) {
      final newLocation = location.copyWith(
        longitude: chooseLocationDetail.location.longitude,
        latitude: chooseLocationDetail.location.latitude,
      );
      if (chooseLocationDetail != null) {
        searchLocationsCubit.updateMyDefaultPlace(
          location,
          newLocation,
        );
      }
      return newLocation;
    }
    return null;
  }
}
