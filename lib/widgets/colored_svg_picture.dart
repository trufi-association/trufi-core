import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ColoredSvgPicture extends StatelessWidget {
  const ColoredSvgPicture(this.assetName, this.color, {this.package, Key? key})
      : super(key: key);

  final String assetName;
  final Color color;
  final String? package;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.modulate),
      child: SvgPicture.asset(assetName, package: package),
    );
  }
}
