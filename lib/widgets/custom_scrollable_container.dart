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
  double panelHeight;
  bool animated = false;
  bool showFullModal = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builderContext, constrains) {
      final minPanelSize = constrains.maxHeight - widget.panelMinSize;
      final minBodySize = constrains.maxHeight - widget.bodyMinSize;
      // height validation
      panelHeight ??= minPanelSize;
      if (panelHeight > minPanelSize) panelHeight = minPanelSize;
      if (panelHeight < 0) panelHeight = 0;

      final bodyHeight = constrains.maxHeight - panelHeight;

      return Container(
        color: Colors.white,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: animated ? 500 : 0),
              curve: Curves.fastOutSlowIn,
              top: 0,
              left: 0,
              right: 0,
              bottom: bodyHeight <= minBodySize ? bodyHeight : minBodySize,
              child: widget.body,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: animated ? 500 : 0),
              curve: Curves.fastOutSlowIn,
              top: panelHeight,
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
                      onVerticalDragEnd: (detail) {
                        if (panelHeight > minPanelSize && !showFullModal) {
                          setState(() {
                            animated = true;
                            panelHeight = minPanelSize;
                            showFullModal = !showFullModal;
                          });
                          return;
                        }

                        setState(() {
                          animated = true;
                          panelHeight = !showFullModal ? 0 : minPanelSize;
                          showFullModal = !showFullModal;
                        });
                      },
                      onVerticalDragUpdate: (detail) {
                        setState(() {
                          animated = false;
                          panelHeight += detail.delta.dy;
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
                    const Divider(height: 1),
                    Expanded(
                      child: Scrollbar(
                        child: widget.panel,
                      ),
                    ),
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
