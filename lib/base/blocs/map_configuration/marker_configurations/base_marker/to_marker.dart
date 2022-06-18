import 'package:flutter/material.dart';

class ToMarker extends StatelessWidget {
  final double height;
  const ToMarker({
    Key? key,
    this.height = 35,
  }) : super(key: key);
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
              margin: const EdgeInsets.only(bottom: 5),
              width: 7,
              height: 7,
              color: Colors.white,
            ),
            const Icon(Icons.location_on, size: 23, color: Colors.white),
            Icon(
              Icons.location_on,
              color: theme.colorScheme.secondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
