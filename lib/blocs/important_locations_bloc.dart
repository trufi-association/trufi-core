import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/locations_bloc.dart';
import 'package:trufi_app/location/location_storage.dart';

class ImportantLocationsBloc extends LocationsBloc {
  ImportantLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          ImportantLocationStorage("assets/data/places.json"),
        );
}
