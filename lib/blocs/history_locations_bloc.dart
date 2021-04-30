import 'package:flutter/material.dart';
import 'package:trufi_core/repository/location_storage_repository/shared_preferences_location_storage.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/locations_bloc_base.dart';

class HistoryLocationsBloc extends LocationsBlocBase {
  static HistoryLocationsBloc of(BuildContext context) {
    return TrufiBlocProvider.of<HistoryLocationsBloc>(context);
  }

  HistoryLocationsBloc(
  ) : super(
          SharedPreferencesLocationStorage("history_locations"),
        );
}
