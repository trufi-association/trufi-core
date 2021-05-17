import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trufi_core/widgets/colored_svg_picture.dart';

class FromMarkerDefault extends StatelessWidget {
  const FromMarkerDefault({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).accentColor;

    return Stack(children: [
      ColoredSvgPicture("assets/images/from_marker.svg", color,
          package: "trufi_core"),
      SvgPicture.asset("assets/images/from_marker_overlay.svg",
          package: "trufi_core"),
    ]);
  }
}
