import 'package:flutter/material.dart';

abstract class LifecycleReactorHandler {
  onInitState(BuildContext context);
  onDispose();
}

class LifecycleReactorWrapper extends StatefulWidget {
  const LifecycleReactorWrapper({
    super.key,
    required this.child,
    required this.lifecycleReactorHandler,
  });

  final WidgetBuilder child;
  final LifecycleReactorHandler? lifecycleReactorHandler;

  @override
  State<LifecycleReactorWrapper> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LifecycleReactorWrapper> {
  @override
  Widget build(BuildContext context) {
    return widget.child(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      widget.lifecycleReactorHandler?.onInitState(context);
    });
  }

  @override
  void dispose() {
    widget.lifecycleReactorHandler?.onDispose();
    super.dispose();
  }
}
