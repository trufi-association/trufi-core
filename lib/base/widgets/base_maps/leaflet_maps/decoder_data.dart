import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/src/node/marker_node.dart';

class ShowOverlappingData extends StatelessWidget {
  final Key keyData;
  final MarkerNode markerNode;
  const ShowOverlappingData({
    super.key,
    required this.keyData,
    required this.markerNode,
  });

  @override
  Widget build(BuildContext context) {
    final keyString = (keyData as ValueKey).value.toString();
    final name = keyString.split("---")[1];
    return Container(
        height: 50,
        padding: const EdgeInsets.only(top: 5),
        child: InkWell(
          onTap: () {
            final data = markerNode.builder(context) as GestureDetector;
            data.onTap!();
            Navigator.of(context).pop();
          },
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: EdgeInsets.all(5),
                child: markerNode.builder(context),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios)
            ],
          ),
        ));
  }
}
