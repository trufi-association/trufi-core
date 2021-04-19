import 'package:flutter/material.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/locations_bloc_base.dart';
import '../location/location_storage.dart';

class HistoryLocationsBloc extends LocationsBlocBase {
  static HistoryLocationsBloc of(BuildContext context) {
    return TrufiBlocProvider.of<HistoryLocationsBloc>(context);
  }

  HistoryLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          SharedPreferencesLocationStorage("history_locations"),
        );
}
