import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/locations_bloc.dart';
import 'package:trufi_app/location/location_storage.dart';

class ImportantLocationsBloc extends LocationsBloc {
  static ImportantLocationsBloc of(BuildContext context) {
    return BlocProvider.of<ImportantLocationsBloc>(context);
  }

  ImportantLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          JSONLocationStorage("assets/data/places.json"),
        );
}
