import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/saved_places_localizations.dart';
import '../cubit/saved_routes_cubit.dart';
import '../models/saved_route.dart';
import 'saved_places_list.dart';
import 'saved_route_card.dart';

/// Saved routes as a list of [SavedRouteCard]s with loading, error and empty
/// states, in the shape of the saved places list: section label, staggered
/// entrance, shimmer while loading. Needs a [SavedRoutesCubit] above it (the
/// screen provides one).
class SavedRoutesList extends StatefulWidget {
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

  @override
  State<SavedRoutesList> createState() => _SavedRoutesListState();
}

class _SavedRoutesListState extends State<SavedRoutesList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _staggerController.forward();
    }
  }

  /// Null stays null so the card hides what the screen did not wire.
  static VoidCallback? _bind(
    ValueChanged<SavedRoute>? callback,
    SavedRoute route,
  ) => callback == null ? null : () => callback(route);

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalizations.of(context);

    return BlocBuilder<SavedRoutesCubit, SavedRoutesState>(
      builder: (context, state) {
        if (state.isLoading && state.routes.isEmpty) {
          return const SavedPlacesShimmerList(sections: 1);
        }
        if (state.error != null) {
          return _ErrorState(
            onRetry: () => context.read<SavedRoutesCubit>().initialize(),
          );
        }
        if (state.routes.isEmpty) {
          return const _SavedRoutesEmptyState();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _triggerAnimation();
        });

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildAnimatedItem(
              index: 0,
              child: SavedPlacesSectionHeader(
                title: localization.savedRoutesSection,
                icon: Icons.route_rounded,
              ),
            ),
            const SizedBox(height: 12),
            for (final (index, route) in state.routes.indexed)
              _buildAnimatedItem(
                index: index + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SavedRouteCard(
                    route: route,
                    onTap: _bind(widget.onRouteTap, route),
                    onRename: _bind(widget.onRouteRename, route),
                    onSwap: _bind(widget.onRouteSwap, route),
                    onDelete: _bind(widget.onRouteDelete, route),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// The saved places list's entrance: each item slides up 20 px and fades
  /// in on its own slice of the 800 ms stagger.
  Widget _buildAnimatedItem({
    required int index,
    required Widget child,
    int totalItems = 10,
  }) {
    final startTime = (index / totalItems).clamp(0.0, 0.6);
    final endTime = ((index / totalItems) + 0.4).clamp(0.0, 1.0);

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

/// Empty state in the transport list's shape: a neutral 80 px circle, a
/// title and a hint pointing at the bookmark button.
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
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.route_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localization.noRoutesSaved,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localization.noRoutesSavedHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
