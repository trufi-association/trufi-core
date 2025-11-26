import 'package:flutter/widgets.dart';

abstract class SearchBarUtils {
  static Widget getDots(Color color) {
    final dot = Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Container(
        width: 2.5,
        height: 2.5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
    return SizedBox(
      width: 24,
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [dot, dot, dot],
      ),
    );
  }
}
