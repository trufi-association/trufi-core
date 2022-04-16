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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
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
                Expanded(
                  child: Container(
                    width: 3,
                    color: color,
                  ),
                ),
            ],
          ), 
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(stop.name+"\n"),
            ),
          ),
        ],
      ),
    );
  }
}
