import 'package:flutter/material.dart';

class FromMarker extends StatelessWidget {
  final double height;
  const FromMarker({
    super.key,
    this.height = 15,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: FittedBox(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 5.2,
              height: 5.2,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
