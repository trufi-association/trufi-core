import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../l10n/saved_places_localizations.dart';
import 'cubit/saved_routes_cubit.dart';
import 'models/saved_route.dart';
import 'repository/saved_routes_repository.dart';
import 'repository/saved_routes_repository_impl.dart';
import 'widgets/route_name_dialog.dart';
import 'widgets/saved_places_header.dart';
import 'widgets/saved_routes_list.dart';

/// Configuration for the Saved Routes screen (#1005).
class SavedRoutesConfig {
  /// Repository for saved routes persistence.
  final SavedRoutesRepository? repository;

  /// Called when the user taps a route. Caller value wins: when set, it
  /// replaces the default launch (pending [SharedRoute] + `go('/')`).
  final ValueChanged<SavedRoute>? onRouteSelected;

  const SavedRoutesConfig({this.repository, this.onRouteSelected});
}

/// "Your Routes" screen module for TrufiApp integration (#1005).
///
/// Lists the saved origin–destination routes; tapping one re-plans the trip
/// on the home screen. Registering this screen also makes the bookmark
/// button of `trufi_core_home_screen` appear on route results.
class SavedRoutesTrufiScreen extends TrufiScreen {
  final SavedRoutesConfig config;
  late final SavedRoutesRepository _repository;

  SavedRoutesTrufiScreen({SavedRoutesConfig? config})
    : config = config ?? const SavedRoutesConfig() {
    _repository = this.config.repository ?? SavedRoutesRepositoryImpl();
  }

  @override
  String get id => 'saved_routes';

  @override
  String get path => '/saved-routes';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => _SavedRoutesScreenWidget(config: config);

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    ...SavedPlacesLocalizations.localizationsDelegates,
  ];

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<SavedRoutesCubit>(
      create: (_) => SavedRoutesCubit(repository: _repository)..initialize(),
    ),
  ];

  /// Right after Your Places (50), before Fares (150).
  @override
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.route_rounded, order: 55);

  @override
  bool get hasOwnAppBar => true;

  @override
  String getLocalizedTitle(BuildContext context) {
    return SavedPlacesLocalizations.of(context).menuSavedRoutes;
  }

  @override
  Future<void> initialize() async {
    await _repository.initialize();
  }

  @override
  Future<void> dispose() async {
    await _repository.dispose();
  }
}

class _SavedRoutesScreenWidget extends StatelessWidget {
  final SavedRoutesConfig config;

  const _SavedRoutesScreenWidget({required this.config});

  /// Launches the trip through the deep-link channel the home screen already
  /// consumes: `HomeScreen` listens to [SharedRouteNotifier], sets origin and
  /// destination and fetches the plan; `go('/')` then reveals the results.
  /// Without a notifier (embedded outside `TrufiApp`) nothing is launched;
  /// without a `GoRouter` the pending route waits for the host to consume it.
  void _launchRoute(BuildContext context, SavedRoute route) {
    HapticFeedback.selectionClick();
    context.read<SavedRoutesCubit>().markUsed(route.id);

    final onRouteSelected = config.onRouteSelected;
    if (onRouteSelected != null) {
      onRouteSelected(route);
      return;
    }

    final notifier = context.read<SharedRouteNotifier?>();
    if (notifier == null) return;
    notifier.setPendingRoute(
      SharedRoute(
        fromLat: route.origin.latitude,
        fromLng: route.origin.longitude,
        fromName: route.origin.name,
        toLat: route.destination.latitude,
        toLng: route.destination.longitude,
        toName: route.destination.name,
      ),
    );
    GoRouter.maybeOf(context)?.go('/');
  }

  Future<void> _showRenameDialog(BuildContext context, SavedRoute route) async {
    final localization = SavedPlacesLocalizations.of(context);
    final cubit = context.read<SavedRoutesCubit>();

    final name = await RouteNameDialog.show(
      context,
      title: localization.renameRoute,
      initialName: route.name,
      fieldLabel: localization.routeName,
      cancelLabel: localization.cancel,
      confirmLabel: localization.save,
    );

    if (name == null) return;
    await cubit.renameRoute(route.id, name);
  }

  Future<void> _swapRoute(BuildContext context, SavedRoute route) async {
    final cubit = context.read<SavedRoutesCubit>();
    // Looked up here (not just the cubit's bool) so the warning can name
    // the route the inverted trip collides with.
    final existing = cubit.findDuplicate(
      origin: route.destination,
      destination: route.origin,
      excludeId: route.id,
    );
    if (existing != null) {
      _showDuplicateWarning(context, existing);
      return;
    }
    await cubit.swapRoute(route.id);
  }

  void _showDuplicateWarning(BuildContext context, SavedRoute existing) {
    final localization = SavedPlacesLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.routeAlreadySaved(existing.name))),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SavedRoute route) {
    final localization = SavedPlacesLocalizations.of(context);
    final cubit = context.read<SavedRoutesCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localization.removeRoute,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localization.removeRouteConfirmation(route.name),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(localization.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        cubit.deleteRoute(route.id);
                        Navigator.of(dialogContext).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(localization.remove),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Try to open the drawer from the nearest ancestor Scaffold.
  void _tryOpenDrawer(BuildContext context) {
    HapticFeedback.lightImpact();
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      scaffold!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Routes are saved from the home screen results: no "+" action.
            SavedPlacesHeader(
              title: localization.menuSavedRoutes,
              onMenuPressed: () => _tryOpenDrawer(context),
            ),
            Expanded(
              child: SavedRoutesList(
                onRouteTap: (route) => _launchRoute(context, route),
                onRouteRename: (route) => _showRenameDialog(context, route),
                onRouteSwap: (route) => _swapRoute(context, route),
                onRouteDelete: (route) =>
                    _showDeleteConfirmation(context, route),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
