import 'package:flutter/material.dart';

class FromMarker extends StatelessWidget {
  final double height;
  const FromMarker({
    Key? key,
    this.height = 15,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
