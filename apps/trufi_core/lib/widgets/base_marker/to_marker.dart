import 'package:flutter/material.dart';

class ToMarker extends StatelessWidget {
  final double height;
  const ToMarker({super.key, this.height = 24});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 16,
        ),
      ),
    );
  }
}
