import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

part './svg_definitions/other_svg_definitions.dart';
part './svg_definitions/social_svg_definitions.dart';
part './svg_definitions/transport_svg_definitions.dart';

// other svg icons

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

// Social media svg icons

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

// trasnport svg icons
Widget waitIcon({Color? color}) {
  return SvgPicture.string(wait(
    color: decodeFillColor(color),
  ));
}

Widget walkIcon({Color? color}) {
  return SvgPicture.string(walk(
    color: decodeFillColor(color),
  ));
}

Widget bikeIcon({Color? color}) {
  return SvgPicture.string(bike(
    color: decodeFillColor(color),
  ));
}

Widget busIcon({Color? color}) {
  return SvgPicture.string(bus(
    color: decodeFillColor(color),
  ));
}

Widget railIcon({Color? color}) {
  return SvgPicture.string(rail(
    color: decodeFillColor(color),
  ));
}

Widget subwayIcon({Color? color}) {
  return SvgPicture.string(subway(
    color: decodeFillColor(color),
  ));
}

Widget gondolaIcon({Color? color}) {
  return SvgPicture.string(gondola(
    color: decodeFillColor(color),
  ));
}

Widget carIcon({Color? color}) {
  return SvgPicture.string(car(
    color: decodeFillColor(color),
  ));
}

Widget carpoolIcon({Color? color}) {
  return SvgPicture.string(carpool(
    color: decodeFillColor(color),
  ));
}

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
