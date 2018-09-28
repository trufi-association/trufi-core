import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/locations_bloc.dart';
import 'package:trufi_app/location/location_storage.dart';

class HistoryLocationsBloc extends LocationsBloc {
  HistoryLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          SharedPreferencesLocationStorage("history_locations"),
        );
}
