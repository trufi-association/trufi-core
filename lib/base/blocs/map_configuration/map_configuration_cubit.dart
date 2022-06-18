import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_copyright.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/marker_configuration.dart';

part 'map_configuration.dart';

class MapConfigurationCubit extends Cubit<MapConfiguration> {
  MapConfigurationCubit(
    MapConfiguration initialState,
  ) : super(initialState);
}
