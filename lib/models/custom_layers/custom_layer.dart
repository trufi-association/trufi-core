import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/blocs/custom_layer/custom_layers_cubit.dart';

import 'package:latlong/latlong.dart';

abstract class CustomLayer {
  final String id;
  CustomLayersCubit customLayersCubit;
  Function onRefresh;
  CustomLayer(this.id);
  void refresh() {
    if (onRefresh != null) onRefresh();
  }

  LayerOptions get layerOptions;
}
