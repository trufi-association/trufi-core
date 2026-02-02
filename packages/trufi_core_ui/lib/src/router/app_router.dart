import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:url_launcher/url_launcher.dart';

/// Application router using GoRouter with dynamic screen support
class AppRouter {
  final List<TrufiScreen> screens;
  final List<SocialMediaLink> socialMediaLinks;
  final GlobalKey<NavigatorState> rootNavigatorKey;
  final GlobalKey<NavigatorState> shellNavigatorKey;

  /// Initial route to navigate to (for web deep linking)
  final String? initialRoute;

  GoRouter? _router;

  AppRouter({
    required this.screens,
    this.socialMediaLinks = const [],
    this.initialRoute,
    GlobalKey<NavigatorState>? rootNavigatorKey,
    GlobalKey<NavigatorState>? shellNavigatorKey,
  }) : rootNavigatorKey = rootNavigatorKey ?? GlobalKey<NavigatorState>(),
       shellNavigatorKey = shellNavigatorKey ?? GlobalKey<NavigatorState>();

  /// Get or create the router
  GoRouter get router {
    _router ??= _createRouter();
    return _router!;
  }

  GoRouter _createRouter() {
    // Convert screens directly to GoRoutes
    final routes = screens
        .map(
          (s) => GoRoute(
            path: s.path,
            name: s.id,
            builder: (context, state) => s.builder(context),
          ),
        )
        .toList();

    // Add the /route deep link handler to the routes list
    final allRoutes = [
      ...routes,
      // Special route for web deep linking (shared routes)
      GoRoute(
        path: '/route',
        name: 'shared_route',
        redirect: (context, state) {
          // Parse and store the shared route
          if (state.uri.queryParameters.isNotEmpty) {
            final route = SharedRoute.fromUri(state.uri);
            if (route != null) {
              final notifier = Provider.of<SharedRouteNotifier>(
                context,
                listen: false,
              );
              notifier.setPendingRoute(route);
            }
          }
          // Always redirect to home
          return '/';
        },
      ),
    ];

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialRoute ?? '/',
      routes: [
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return AppShell(
              currentPath: state.uri.path,
              screens: screens,
              socialMediaLinks: socialMediaLinks,
              child: child,
            );
          },
          routes: allRoutes.isEmpty ? [_defaultHomeRoute()] : allRoutes,
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
      builder: (context, state) =>
          const Center(child: Text('No screens registered')),
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
  final List<SocialMediaLink> socialMediaLinks;

  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
    required this.screens,
    this.socialMediaLinks = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Verificar si la pantalla actual tiene su propio AppBar
    final currentScreen = screens.firstWhere(
      (s) => s.path == currentPath,
      orElse: () => screens.first,
    );
    final hasOwnAppBar = currentScreen.hasOwnAppBar;

    return Scaffold(
      appBar: hasOwnAppBar
          ? null // La pantalla maneja su propio AppBar
          : AppBar(
              title: Text(_getTitle(context)),
              elevation: 2,
              actions: [
                // Placeholder para acciones adicionales si se necesitan
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'About',
                  onPressed: () {
                    // Navegar a la pantalla de About si existe
                    final aboutScreen = screens.firstWhere(
                      (s) => s.id == 'about',
                      orElse: () => screens.first,
                    );
                    context.go(aboutScreen.path);
                  },
                ),
              ],
            ),
      drawer: AppDrawer(
        currentPath: currentPath,
        screens: screens,
        socialMediaLinks: socialMediaLinks,
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

/// Modern navigation drawer with Material 3 design
class AppDrawer extends StatelessWidget {
  final String currentPath;
  final List<TrufiScreen> screens;
  final List<SocialMediaLink> socialMediaLinks;

  const AppDrawer({
    super.key,
    required this.currentPath,
    required this.screens,
    this.socialMediaLinks = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // Modern header with layered design
          _DrawerHeader(theme: theme),

          const SizedBox(height: 8),

          // Menu items with Material 3 styling
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _buildMenuItems(context, theme),
            ),
          ),

          // Modern footer
          _DrawerFooter(
            theme: theme,
            socialMediaLinks: socialMediaLinks,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, ThemeData theme) {
    final widgets = <Widget>[];

    // Collect screens with menu items
    final menuScreens = screens.where((s) => s.menuItem != null).toList();

    // Sort by order
    menuScreens.sort((a, b) => a.menuItem!.order.compareTo(b.menuItem!.order));

    for (int i = 0; i < menuScreens.length; i++) {
      final screen = menuScreens[i];
      final item = screen.menuItem!;

      if (item.showDividerBefore) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        );
      }

      widgets.add(
        _DrawerMenuItem(
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

/// Modern drawer header with layered design
class _DrawerHeader extends StatelessWidget {
  final ThemeData theme;

  const _DrawerHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo/Avatar with modern styling
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  size: 32,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // App name
              Text(
                'Trufi App',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              // Tagline
              Text(
                'Tu compañero de transporte público',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Material 3 styled drawer menu item
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.secondaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern drawer footer with version and optional actions
class _DrawerFooter extends StatelessWidget {
  final ThemeData theme;
  final List<SocialMediaLink> socialMediaLinks;

  const _DrawerFooter({
    required this.theme,
    this.socialMediaLinks = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          // Version info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Versión 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          if (socialMediaLinks.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Social media icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < socialMediaLinks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _SocialIconButton(
                    icon: socialMediaLinks[i].icon,
                    url: socialMediaLinks[i].url,
                    label: socialMediaLinks[i].label,
                    colorScheme: colorScheme,
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Powered by text
          Text(
            'Powered by Trufi Association',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Social media icon button for the drawer footer
class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String url;
  final String? label;
  final ColorScheme colorScheme;

  const _SocialIconButton({
    required this.icon,
    required this.url,
    this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 20,
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      onPressed: () => launchUrl(Uri.parse(url)),
      tooltip: label ?? url,
      constraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      padding: EdgeInsets.zero,
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
            const Text('Page not found', style: TextStyle(fontSize: 24)),
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
