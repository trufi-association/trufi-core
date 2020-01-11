import 'package:flutter/material.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/locations_bloc_base.dart';
import '../location/location_storage.dart';
import '../trufi_models.dart';

class SavedLocationsBloc extends LocationsBlocBase {
  static SavedLocationsBloc of(BuildContext context) {
    return BlocProvider.of<SavedLocationsBloc>(context);
  }

  SavedLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          SharedPreferencesLocationStorage("saved_locations"),
        );
}