import 'package:flutter/material.dart';

String decodeFillColor(Color? color) {
  // Default color is black
  String stringColor = '#000000';
  if (color != null) {
    if (color == Colors.transparent) {
      stringColor = 'none';
    } else {
      // Extract ARGB components
      int value = color.value;
      // Format to #RRGGBB (skip alpha value)
      stringColor = '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    }
  }
  return stringColor;
}

Color hexToColor(String? hex) {
  String hexAux = hex ?? "000000";
  hexAux = hexAux.replaceFirst('#', '');
  if (hexAux.length == 6) {
    hexAux = 'FF$hexAux';
  }
  return Color(int.parse('0x$hexAux'));
}
