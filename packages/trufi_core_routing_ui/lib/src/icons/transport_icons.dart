import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'transport_svg_definitions.dart';

/// Creates a walk icon widget.
Widget walkIcon({Color? color}) {
  return SvgPicture.string(walkSvg(color: _colorToHex(color)));
}

/// Creates a bike/bicycle icon widget.
Widget bikeIcon({Color? color}) {
  return SvgPicture.string(bikeSvg(color: _colorToHex(color)));
}

/// Creates a bus icon widget.
Widget busIcon({Color? color}) {
  return SvgPicture.string(busSvg(color: _colorToHex(color)));
}

/// Creates a rail/train icon widget.
Widget railIcon({Color? color}) {
  return SvgPicture.string(railSvg(color: _colorToHex(color)));
}

/// Creates a subway/metro icon widget.
Widget subwayIcon({Color? color}) {
  return SvgPicture.string(subwaySvg(color: _colorToHex(color)));
}

/// Creates a gondola/cable car icon widget.
Widget gondolaIcon({Color? color}) {
  return SvgPicture.string(gondolaSvg(color: _colorToHex(color)));
}

/// Creates a car icon widget.
Widget carIcon({Color? color}) {
  return SvgPicture.string(carSvg(color: _colorToHex(color)));
}

/// Creates a carpool icon widget.
Widget carpoolIcon({Color? color}) {
  return SvgPicture.string(carpoolSvg(color: _colorToHex(color)));
}

/// Creates a wait icon widget.
Widget waitIcon({Color? color}) {
  return SvgPicture.string(waitSvg(color: _colorToHex(color)));
}

String _colorToHex(Color? color) {
  if (color == null) return '#000000';
  if (color == Colors.transparent) return 'none';
  return "#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}";
}
