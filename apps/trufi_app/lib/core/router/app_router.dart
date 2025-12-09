import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Application router using GoRouter with dynamic screen support
class AppRouter {
  final List<TrufiScreen> screens;
  final GlobalKey<NavigatorState> rootNavigatorKey;
  final GlobalKey<NavigatorState> shellNavigatorKey;

  GoRouter? _router;

  AppRouter({
    required this.screens,
    GlobalKey<NavigatorState>? rootNavigatorKey,
    GlobalKey<NavigatorState>? shellNavigatorKey,
  })  : rootNavigatorKey = rootNavigatorKey ?? GlobalKey<NavigatorState>(),
        shellNavigatorKey = shellNavigatorKey ?? GlobalKey<NavigatorState>();

  /// Get or create the router
  GoRouter get router {
    _router ??= _createRouter();
    return _router!;
  }

  GoRouter _createRouter() {
    // Convert screens directly to GoRoutes
    final routes = screens.map((s) => GoRoute(
      path: s.path,
      name: s.id,
      builder: (context, state) => s.builder(context),
    )).toList();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return AppShell(
              currentPath: state.uri.path,
              screens: screens,
              child: child,
            );
          },
          routes: routes.isEmpty ? [_defaultHomeRoute()] : routes,
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(error: state.error),
    );
  }

  /// Default home route if no screens registered
  GoRoute _defaultHomeRoute() {
    return GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Center(
        child: Text('No screens registered'),
      ),
    );
  }

  /// Rebuild router when screens change
  void rebuild() {
    _router?.refresh();
  }
}

/// Main app shell with navigation drawer
class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;
  final List<TrufiScreen> screens;

  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(context)),
      ),
      drawer: AppDrawer(
        currentPath: currentPath,
        screens: screens,
      ),
      body: child,
    );
  }

  String _getTitle(BuildContext context) {
    for (final screen in screens) {
      if (screen.path == currentPath) {
        return screen.getLocalizedTitle(context);
      }
    }
    return 'Trufi App';
  }
}

/// Navigation drawer with dynamic menu items
class AppDrawer extends StatelessWidget {
  final String currentPath;
  final List<TrufiScreen> screens;

  const AppDrawer({
    super.key,
    required this.currentPath,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Trufi App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Modular Architecture',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ..._buildMenuItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final widgets = <Widget>[];

    // Collect screens with menu items
    final menuScreens = screens.where((s) => s.menuItem != null).toList();

    // Sort by order
    menuScreens.sort((a, b) => a.menuItem!.order.compareTo(b.menuItem!.order));

    for (final screen in menuScreens) {
      final item = screen.menuItem!;

      if (item.showDividerBefore) {
        widgets.add(const Divider());
      }

      widgets.add(
        DrawerMenuItem(
          icon: item.icon,
          title: screen.getLocalizedTitle(context),
          isSelected: currentPath == screen.path,
          onTap: () {
            Navigator.pop(context);
            context.go(screen.path);
          },
        ),
      );
    }

    return widgets;
  }
}

/// Drawer menu item widget
class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.green : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.green : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}

/// Error screen for unknown routes
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
