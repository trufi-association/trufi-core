import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:trufi_core/widgets/buttons/trufi_icon_button.dart';

class HeaderBottomSheet extends StatelessWidget {
  final VoidCallback onClose;
  const HeaderBottomSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Public transport",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          TrufiIconButton(
            onPressed: () {},
            icon: Transform.rotate(angle: math.pi / 2, child: Icon(Icons.tune)),
            isCompact: true,
          ),
          SizedBox(width: 4),
          TrufiIconButton(
            onPressed: () {},
            icon: Icon(Icons.ios_share),
            isCompact: true,
          ),
          SizedBox(width: 4),
          TrufiIconButton(
            onPressed: onClose,
            icon: Icon(Icons.close),
            isCompact: true,
          ),
        ],
      ),
    );
  }
}
