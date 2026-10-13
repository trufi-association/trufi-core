import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/saved_places_localizations.dart';
import '../cubit/saved_routes_cubit.dart';
import '../models/saved_route.dart';
import 'saved_route_card.dart';

/// Saved routes as a list of [SavedRouteCard]s with loading, error and empty
/// states. Needs a [SavedRoutesCubit] above it (the screen provides one).
class SavedRoutesList extends StatelessWidget {
  const SavedRoutesList({
    super.key,
    this.onRouteTap,
    this.onRouteRename,
    this.onRouteSwap,
    this.onRouteDelete,
  });

  final ValueChanged<SavedRoute>? onRouteTap;
  final ValueChanged<SavedRoute>? onRouteRename;
  final ValueChanged<SavedRoute>? onRouteSwap;
  final ValueChanged<SavedRoute>? onRouteDelete;

  /// Null stays null so the card hides what the screen did not wire.
  static VoidCallback? _bind(
    ValueChanged<SavedRoute>? callback,
    SavedRoute route,
  ) => callback == null ? null : () => callback(route);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedRoutesCubit, SavedRoutesState>(
      builder: (context, state) {
        if (state.isLoading && state.routes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return _ErrorState(
            onRetry: () => context.read<SavedRoutesCubit>().initialize(),
          );
        }
        if (state.routes.isEmpty) {
          return const _SavedRoutesEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.routes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final route = state.routes[index];
            return SavedRouteCard(
              route: route,
              onTap: _bind(onRouteTap, route),
              onRename: _bind(onRouteRename, route),
              onSwap: _bind(onRouteSwap, route),
              onDelete: _bind(onRouteDelete, route),
            );
          },
        );
      },
    );
  }
}

/// Empty state: icon, title and a hint pointing at the bookmark button.
class _SavedRoutesEmptyState extends StatelessWidget {
  const _SavedRoutesEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localization = SavedPlacesLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.route_rounded,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localization.noRoutesSaved,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localization.noRoutesSavedHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry option.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localization = SavedPlacesLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localization.errorLoadingRoutes,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(localization.retry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
