import 'package:flutter/material.dart';

class SwapButton extends StatelessWidget {
  const SwapButton({
    Key key,
    @required this.orientation,
    @required this.onSwap,
  }) : super(key: key);
  final Orientation orientation;
  final void Function() onSwap;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      splashRadius: 22,
      icon: Icon(
        orientation == Orientation.portrait
            ? Icons.swap_vert
            : Icons.swap_horiz,
        size: 22,
        color: const Color(0xff747474),
      ),
      onPressed: onSwap,
    );
  }
}
