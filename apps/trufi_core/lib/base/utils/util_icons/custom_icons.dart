import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

part './svg_definitions/other_svg_definitions.dart';
part './svg_definitions/social_svg_definitions.dart';

// App-specific icons (not in trufi_core_routing_ui)

Widget busStopIcon({Color? color}) {
  return SvgPicture.string(busStop(
    color: decodeFillColor(color),
  ));
}

Widget trufiIcon({Color? color}) {
  return SvgPicture.string(trufi(
    color: decodeFillColor(color),
  ));
}

// Social media icons

Widget whatsappIcon({Color? color}) {
  return SvgPicture.string(whatsapp(
    color: decodeFillColor(color),
  ));
}

Widget facebookIcon({Color? color}) {
  return SvgPicture.string(facebook(
    color: decodeFillColor(color),
  ));
}

Widget instagramIcon({Color? color}) {
  return SvgPicture.string(instagram(
    color: decodeFillColor(color),
  ));
}

Widget twitterIcon({Color? color}) {
  return SvgPicture.string(twitter(
    color: decodeFillColor(color),
  ));
}

Widget tiktokIcon({Color? color}) {
  return SvgPicture.string(tiktok(
    color: decodeFillColor(color),
  ));
}

String decodeFillColor(Color? color) {
  String stringColor = '#000000';
  if (color != null) {
    stringColor = color == Colors.transparent
        ? 'none'
        : "#${color.value.toRadixString(16)}";
  }
  return stringColor;
}

// Transport icons are now in trufi_core_routing_ui package
// Import from: package:trufi_core_routing_ui/trufi_core_routing_ui.dart
// Available: waitIcon, walkIcon, bikeIcon, busIcon, railIcon, subwayIcon, gondolaIcon, carIcon, carpoolIcon
