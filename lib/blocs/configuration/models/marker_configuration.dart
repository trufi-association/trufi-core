import 'package:flutter/material.dart';
import 'package:trufi_core/widgets/from_marker_default.dart';
import 'package:trufi_core/widgets/to_marker_default.dart';

class MarkerConfiguration {
  final Widget toMarker;
  final Widget fromMarker;

  const MarkerConfiguration({
    this.toMarker = const ToMarkerDefault(),
    this.fromMarker = const FromMarkerDefault(),
  });
}
