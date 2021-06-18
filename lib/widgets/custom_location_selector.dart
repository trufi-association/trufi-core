
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
class CustomLocationSelector extends StatelessWidget {
  const CustomLocationSelector({
    Key key,
    @required this.locationData,
    @required this.onFetchPlan,
  }) : super(key: key);

  final LocationDetail locationData;
  final void Function() onFetchPlan;
  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final homePageCubit = context.read<HomePageCubit>();
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              await homePageCubit.setFromPlace(
                TrufiLocation(
                  description: locationData.description,
                  address: locationData.street,
                  latitude: locationData.position.latitude,
                  longitude: locationData.position.longitude,
                ),
              );
              onFetchPlan();
            },
            child: Text(
              localization.commonOrigin,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              await homePageCubit.setToPlace(
                TrufiLocation(
                  description: locationData.description,
                  address: locationData.street,
                  latitude: locationData.position.latitude,
                  longitude: locationData.position.longitude,
                ),
              );
              onFetchPlan();
            },
            child: Text(
              localization.commonDestination,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

class LocationDetail {
  final String description;
  final String street;
  final LatLng position;

  LocationDetail(this.description, this.street, this.position);
}
