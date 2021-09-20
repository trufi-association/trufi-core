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
    final theme = Theme.of(context);
    return IconButton(
      padding: EdgeInsets.zero,
      splashRadius: 22,
      icon: Icon(
        orientation == Orientation.portrait
            ? Icons.swap_vert
            : Icons.swap_horiz,
        size: 22,
        color: theme.textTheme.subtitle1.color,
      ),
      onPressed: onSwap,
    );
  }
}

class ResetButton extends StatelessWidget {
  const ResetButton({
    Key key,
    @required this.onReset,
  }) : super(key: key);
  final void Function() onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      padding: EdgeInsets.zero,
      splashRadius: 22,
      icon: Icon(
        Icons.clear,
        size: 22,
        color: theme.textTheme.subtitle1.color,
      ),
      onPressed: onReset,
    );
  }
}
