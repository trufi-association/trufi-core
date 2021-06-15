import 'package:flutter/material.dart';

class CustomScrollableContainer extends StatefulWidget {
  final Widget body;
  final Widget panel;
  final double openedPosition;

  const CustomScrollableContainer({
    Key key,
    @required this.body,
    @required this.panel,
    @required this.openedPosition,
  }) : super(key: key);

  @override
  _CustomScrollableContainerState createState() =>
      _CustomScrollableContainerState();
}

class _CustomScrollableContainerState extends State<CustomScrollableContainer> {
  double panelHeight;
  bool animated = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builderContext, constrains) {
      const topLimit = 0.0;
      final openedPosition = constrains.maxHeight - widget.openedPosition;
      final bottomLimit =
          constrains.maxHeight - (35 + MediaQuery.of(context).padding.bottom);
      // height validation
      panelHeight ??= openedPosition;
      // limits validations
      if (panelHeight < topLimit) panelHeight = topLimit;
      if (panelHeight > bottomLimit) panelHeight = bottomLimit;

      final reversePanelHeight = constrains.maxHeight - panelHeight;

      return Container(
        color: Colors.white,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: animated ? 300 : 0),
              curve: Curves.fastOutSlowIn,
              top: 0,
              left: 0,
              right: 0,
              bottom: reversePanelHeight < openedPosition
                  ? reversePanelHeight
                  : openedPosition,
              child: widget.body,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: animated ? 300 : 0),
              curve: Curves.fastOutSlowIn,
              top: panelHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1.0,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      GestureDetector(
                        onVerticalDragEnd: (detail) {
                          if (detail.primaryVelocity < 0) {
                            setState(() {
                              animated = true;
                              panelHeight = panelHeight < openedPosition
                                  ? topLimit
                                  : openedPosition;
                            });
                          } else if (detail.primaryVelocity > 0) {
                            setState(() {
                              animated = true;
                              panelHeight = panelHeight > openedPosition
                                  ? bottomLimit
                                  : openedPosition;
                            });
                          }
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
                      Expanded(child: widget.panel),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
