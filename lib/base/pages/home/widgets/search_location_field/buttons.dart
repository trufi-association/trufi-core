import 'package:flutter/material.dart';

class SwapButton extends StatelessWidget {
  const SwapButton({
    super.key,
    required this.orientation,
    required this.onSwap,
  });
  final Orientation orientation;
  final void Function() onSwap;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: IconButton(
        icon: Icon(
          orientation == Orientation.portrait
              ? Icons.swap_vert
              : Icons.swap_horiz,
          color: Colors.white,
        ),
        onPressed: onSwap,
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  const ResetButton({
    super.key,
    required this.onReset,
  });
  final void Function() onReset;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: IconButton(
        icon: const Icon(
          Icons.clear,
          color: Colors.white,
        ),
        onPressed: onReset,
      ),
    );
  }
}
