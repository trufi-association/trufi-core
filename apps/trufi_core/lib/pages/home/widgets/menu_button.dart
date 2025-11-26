import 'package:flutter/material.dart';

/// Menu button that opens the app drawer.
/// This widget assumes the parent Scaffold has a drawer configured.
/// For GoRouter navigation, use AppDrawer from the example app.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: const Icon(Icons.menu),
        style:  ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            theme.colorScheme.surface,
          ),
          elevation: WidgetStatePropertyAll(2.0),
          shadowColor: WidgetStatePropertyAll(Colors.black87),
        ),
      ),
    );
  }
}
