import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/pages/about/about.dart';
import 'package:trufi_core/pages/feedback/feedback.dart';
import 'package:trufi_core/pages/saved_places/saved_places.dart';
import 'package:trufi_core/pages/tickets/tickets_page.dart';

/// Default app drawer with navigation menu for Trufi apps
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.appName = 'Trufi Transit',
    this.headerImageUrl =
        'https://www.trufi-association.org/wp-content/uploads/2021/11/Delhi-autorickshaw-CC-BY-NC-ND-ai_enlarged-tweaked-1800x1200px.jpg',
    this.logoUrl = 'https://trufi.app/wp-content/uploads/2019/02/48.png',
    this.showTickets = true,
    this.additionalMenuItems,
  });

  final String appName;
  final String headerImageUrl;
  final String logoUrl;
  final bool showTickets;
  final List<Widget>? additionalMenuItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(headerImageUrl),
                fit: BoxFit.cover,
              ),
              color: theme.colorScheme.primary,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(logoUrl),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.search, color: theme.colorScheme.onSurface),
            title: Text(
              'Buscar rutas',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.bookmark,
              color: theme.colorScheme.onSurface,
            ),
            title: Text(
              localization.translate(LocalizationKey.yourPlacesMenu),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/${SavedPlacesPage.route}');
            },
          ),
          if (showTickets)
            ListTile(
              leading: Icon(
                CupertinoIcons.tickets,
                color: theme.colorScheme.onSurface,
              ),
              title: Text(
                'Tickets',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.go('/${TicketsPage.route}');
              },
            ),
          if (additionalMenuItems != null) ...additionalMenuItems!,
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.feedback_outlined,
              color: theme.colorScheme.onSurface,
            ),
            title: Text(
              localization.translate(LocalizationKey.feedbackMenu),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/${FeedbackPage.route}');
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: theme.colorScheme.onSurface),
            title: Text(
              localization.translate(LocalizationKey.aboutUsMenu),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/${AboutPage.route}');
            },
          ),
        ],
      ),
    );
  }
}
