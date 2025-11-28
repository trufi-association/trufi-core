import 'package:flutter/material.dart';

/// Converts a hex string to a Flutter Color.
Color hexToColor(String? hex) {
  String hexAux = hex ?? '000000';
  hexAux = hexAux.replaceFirst('#', '');
  if (hexAux.length == 6) {
    hexAux = 'FF$hexAux';
  }
  return Color(int.parse('0x$hexAux'));
}

/// Converts a Flutter Color to a hex string format for map styling.
String decodeFillColor(Color? color) {
  // Default color is black
  String stringColor = '#000000';
  if (color != null) {
    if (color == Colors.transparent) {
      stringColor = 'none';
    } else {
      // Convert to ARGB32 and extract RGB components
      final argb = color.toARGB32();
      stringColor =
          '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';
    }
  }
  return stringColor;
}
