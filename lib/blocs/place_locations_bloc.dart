import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/locations_bloc_base.dart';
import 'package:trufi_app/location/location_storage.dart';

class PlaceLocationsBloc extends LocationsBlocBase {
  static PlaceLocationsBloc of(BuildContext context) {
    return BlocProvider.of<PlaceLocationsBloc>(context);
  }

  PlaceLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          JSONLocationStorage("assets/data/places.json"),
        );
}
