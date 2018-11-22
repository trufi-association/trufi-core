import 'package:flutter/material.dart';
import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/locations_bloc.dart';
import 'package:trufi_app/location/location_storage.dart';

class OfflineLocationsBloc extends LocationsBloc {
  static OfflineLocationsBloc of(BuildContext context) {
    return BlocProvider.of<OfflineLocationsBloc>(context);
  }

  OfflineLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          JSONLocationStorage("assets/data/locations.json"),
        );
}
