import 'package:flutter/material.dart';

class FromMarker extends StatelessWidget {
  final double height;
  const FromMarker({
    super.key,
    this.height = 24,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.my_location,
          color: Colors.green,
          size: 16,
        ),
      ),
    );
  }
}
