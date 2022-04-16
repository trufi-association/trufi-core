import 'package:flutter/material.dart';

class CustomScrollableContainer extends StatefulWidget {
  final Widget body;
  final Widget? panel;
  final double openedPosition;
  final double bottomPadding;
  final void Function()? onClose;

  const CustomScrollableContainer({
    Key? key,
    required this.body,
    this.panel,
    required this.openedPosition,
    this.bottomPadding = 0,
    this.onClose,
  }) : super(key: key);

  @override
  _CustomScrollableContainerState createState() =>
      _CustomScrollableContainerState();
}

class _CustomScrollableContainerState extends State<CustomScrollableContainer> {
  double? panelHeight;
  bool animated = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builderContext, constrains) {
      const topLimit = 0.0;
      final openedPosition = constrains.maxHeight - widget.openedPosition;
      final bottomLimit = constrains.maxHeight -
          (35 + MediaQuery.of(context).padding.bottom + widget.bottomPadding);
      // height validation
      panelHeight ??= openedPosition;
      // limits validations
      if (panelHeight! < topLimit) panelHeight = topLimit;
      if (panelHeight! > bottomLimit) panelHeight = bottomLimit;

      final reversePanelHeight = constrains.maxHeight - panelHeight!;

      return Container(
        color: Colors.white,
        // margin: EdgeInsets.all(20),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: animated ? 300 : 0),
              curve: Curves.fastOutSlowIn,
              top: 0,
              left: 0,
              right: 0,
              bottom: widget.panel == null
                  ? 0
                  : reversePanelHeight < openedPosition
                      ? reversePanelHeight
                      : openedPosition,
              child: widget.body,
            ),
            if (widget.panel != null)
              AnimatedPositioned(
                duration: Duration(milliseconds: animated ? 300 : 0),
                curve: Curves.fastOutSlowIn,
                top: panelHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        GestureDetector(
                          onVerticalDragEnd: (detail) {
                            if (detail.primaryVelocity != null) {
                              if (detail.primaryVelocity! < 0) {
                                setState(() {
                                  animated = true;
                                  panelHeight = panelHeight! < openedPosition
                                      ? topLimit
                                      : openedPosition;
                                });
                              } else if (detail.primaryVelocity! > 0) {
                                setState(() {
                                  animated = true;
                                  panelHeight = panelHeight! > openedPosition
                                      ? bottomLimit
                                      : openedPosition;
                                });
                              }
                            }
                          },
                          onVerticalDragUpdate: (detail) {
                            setState(() {
                              animated = false;
                              if (panelHeight != null) {
                                panelHeight = panelHeight! + detail.delta.dy;
                              }
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
                              mainAxisAlignment: widget.onClose == null
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if (widget.onClose != null)
                                  const SizedBox(
                                    height: 30,
                                    width: 30,
                                  ),
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
                                if (widget.onClose != null)
                                  GestureDetector(
                                    onTap: widget.onClose,
                                    child: Container(
                                      height: 26,
                                      width: 26,
                                      margin: const EdgeInsets.all(2),
                                      color: Colors.transparent,
                                      child: const Center(
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                        ),
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
                            child: widget.panel ?? Container(),
                          ),
                        ),
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
