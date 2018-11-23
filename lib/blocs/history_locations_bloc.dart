import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/locations_bloc_base.dart';
import 'package:trufi_app/location/location_storage.dart';

class HistoryLocationsBloc extends LocationsBlocBase {
  static HistoryLocationsBloc of(BuildContext context) {
    return BlocProvider.of<HistoryLocationsBloc>(context);
  }

  HistoryLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          SharedPreferencesLocationStorage("history_locations"),
        );
}
