import 'package:flutter/material.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';

class StopItemTile extends StatelessWidget {
  final Stop stop;
  final Color color;
  final bool isLastElement;

  const StopItemTile({
    Key? key,
    required this.stop,
    required this.color,
    this.isLastElement = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: color, width: 3.5),
                  shape: BoxShape.circle),
            ),
            if (!isLastElement)
              Container(
                width: 4,
                height: 15,
                color: color,
              )
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: SizedBox(
            height: !isLastElement ? 20 : 50,
            child: Row(
              crossAxisAlignment: !isLastElement
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(stop.name)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
