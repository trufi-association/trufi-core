import 'package:flutter/material.dart';

class CustomScrollableContainer extends StatefulWidget {
  final Widget body;
  final Widget panel;
  final double bodyMinSize;
  final double panelMinSize;
  const CustomScrollableContainer({
    Key key,
    @required this.body,
    @required this.panel,
    @required this.bodyMinSize,
    @required this.panelMinSize,
  }) : super(key: key);

  @override
  _CustomScrollableContainerState createState() =>
      _CustomScrollableContainerState();
}

class _CustomScrollableContainerState extends State<CustomScrollableContainer> {
  double height;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builderContext, constrains) {
      final minPanelSize = constrains.maxHeight - widget.panelMinSize;
      final minBodySize = constrains.maxHeight - widget.panelMinSize;
      // height validation
      height ??= minPanelSize;
      if (height > minPanelSize) height = minPanelSize;
      if (height < 0) height = 0;

      final bodyHeight = constrains.maxHeight - height;
      return Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: bodyHeight <= minBodySize ? bodyHeight : minBodySize,
              child: widget.body,
            ),
            Positioned(
              top: height,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1.0,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onVerticalDragUpdate: (detail) {
                        setState(() {
                          height += detail.delta.dy;
                        });
                      },
                      child: Container(
                        height: 30,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: widget.panel),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
