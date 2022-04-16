import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_copyright.dart';
import 'package:trufi_core/base/widgets/maps/markers/marker_configuration.dart';

part 'map_configuration.dart';

class MapConfigurationCubit extends Cubit<MapConfiguration> {
  MapConfigurationCubit(
    MapConfiguration initialState,
  ) : super(initialState);
}
