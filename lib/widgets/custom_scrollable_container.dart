import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';

class CustomScrollableContainer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builderContext, constrains) {
      return Column(
        children: [
          Flexible(
            child: OverflowBox(
              // TODO fix overflow warnings
              minHeight: bodyMinSize,
              child: body,
            ),
          ),
          _PanelContainer(
            maxSize: constrains.maxHeight,
            minSize: panelMinSize,
            child: panel,
          ),
        ],
      );
    });
  }
}

class _PanelContainer extends StatefulWidget {
  final Widget child;
  final double maxSize;
  final double minSize;
  const _PanelContainer({
    Key key,
    @required this.child,
    @required this.maxSize,
    @required this.minSize,
  }) : super(key: key);

  @override
  _PanelContainerState createState() => _PanelContainerState();
}

class _PanelContainerState extends State<_PanelContainer> {
  double height = 100;
  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>().state.bottomBarTheme;
    if (height > widget.maxSize - 30) height = widget.maxSize - 30;
    if (height < widget.minSize) height = widget.minSize;
    return Container(
      decoration: BoxDecoration(
          color: theme.backgroundColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: theme.accentColor.withOpacity(0.5), blurRadius: 4.0)
          ],
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onVerticalDragUpdate: (detail) {
              setState(() {
                height -= detail.delta.dy;
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
          // ignore: sized_box_for_whitespace
          Container(
            height: height,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
