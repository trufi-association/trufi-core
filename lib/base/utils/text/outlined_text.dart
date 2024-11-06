import 'dart:collection';

import 'package:flutter/material.dart';

List<Shadow> outlinedText({
  double strokeWidth = 2,
  Color strokeColor = Colors.black,
  int precision = 5,
}) {
  final Set<Shadow> result = HashSet();
  for (int x = 1; x < strokeWidth + precision; x++) {
    for (int y = 1; y < strokeWidth + precision; y++) {
      final double offsetX = x.toDouble();
      final double offsetY = y.toDouble();
      result.add(Shadow(
          offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY),
          color: strokeColor));
    }
  }
  return result.toList();
}

Color getContrastColor(Color backgroundColor) {
  // Calculate the relative luminance of the background color
  double luminance = backgroundColor.computeLuminance();

  // Choose black or white text based on the luminance
  // Threshold of 0.5 is commonly used, but you can adjust for your specific needs
  return luminance > 0.5 ? Colors.black : Colors.white;
}

double calculateTextWidth(
  String text,
  TextStyle style,
) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
    strutStyle: StrutStyle(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      height: style.height,
    ),
  );
  textPainter.layout();
  return textPainter.size.width;
}
