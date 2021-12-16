import 'package:flutter/material.dart';

abstract class BlocBase {
  void dispose();
}

class TrufiBlocProvider<T extends BlocBase> extends StatefulWidget {
  const TrufiBlocProvider({
    Key? key,
    required this.child,
    required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _TrufiBlocProviderState<T> createState() => _TrufiBlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    final TrufiBlocProvider<T> provider =
        context.findAncestorWidgetOfExactType<TrufiBlocProvider<T>>()!;
    return provider.bloc;
  }
}

class _TrufiBlocProviderState<T> extends State<TrufiBlocProvider<BlocBase>> {
  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
