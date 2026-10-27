import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import '../../l10n/home_screen_localizations.dart';
import '../services/saved_route_snapshot.dart';

/// Bookmark button that saves the current origin–destination trip as a
/// route (#1005).
///
/// Renders nothing when no [SavedRoutesCubit] is in scope, i.e. the app did
/// not register `SavedRoutesTrufiScreen`, so existing apps see no change.
/// Watches the cubit so the icon turns solid as soon as the trip is saved.
class SaveRouteButton extends StatelessWidget {
  const SaveRouteButton({
    super.key,
    required this.from,
    required this.to,
    this.itinerary,
    this.dense = false,
    this.endSpacing = 0,
  });

  final TrufiLocation from;
  final TrufiLocation to;

  /// Itinerary snapshotted on the saved route (badges and caption of the
  /// card); null saves the endpoints only.
  final routing.Itinerary? itinerary;

  /// `true`: small circle like the results sheet's share button; `false`:
  /// [IconButton.filled] like the side panel's.
  final bool dense;

  /// Trailing gap, owned here so an absent button leaves no stray spacer.
  final double endSpacing;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SavedRoutesCubit?>();
    if (cubit == null) return const SizedBox.shrink();

    final l10n = HomeScreenLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final origin = SavedRoutePoint.fromTrufiLocation(from);
    final destination = SavedRoutePoint.fromTrufiLocation(to);
    final isSaved =
        cubit.findDuplicate(origin: origin, destination: destination) != null;
    final icon = isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined;
    void onTap() => _save(context, cubit, origin, destination);

    final button = dense
        ? Tooltip(
            message: l10n.saveRoute,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: colorScheme.primary),
              ),
            ),
          )
        : IconButton.filled(
            icon: Icon(icon, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              foregroundColor: colorScheme.primary,
            ),
            onPressed: onTap,
            tooltip: l10n.saveRoute,
          );

    return Padding(
      padding: EdgeInsetsDirectional.only(end: endSpacing),
      child: button,
    );
  }

  Future<void> _save(
    BuildContext context,
    SavedRoutesCubit cubit,
    SavedRoutePoint origin,
    SavedRoutePoint destination,
  ) async {
    HapticFeedback.lightImpact();
    final l10n = HomeScreenLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final existing = cubit.findDuplicate(
      origin: origin,
      destination: destination,
    );
    if (existing != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.routeAlreadySaved(existing.name))),
      );
      return;
    }

    // Deep links may set endpoints without a label.
    final fromName = from.description.isNotEmpty
        ? from.description
        : l10n.placeOrigin;
    final toName = to.description.isNotEmpty
        ? to.description
        : l10n.placeDestination;
    final name = await RouteNameDialog.show(
      context,
      title: l10n.saveRoute,
      initialName: '$fromName → $toName',
      fieldLabel: l10n.saveRouteName,
      cancelLabel: l10n.buttonCancel,
      confirmLabel: l10n.buttonSave,
    );
    if (name == null) return;

    final itinerary = this.itinerary;
    final saved = await cubit.saveRoute(
      SavedRoute.create(
        name: name,
        origin: origin,
        destination: destination,
        snapshot: itinerary == null
            ? null
            : savedRouteSnapshotFromItinerary(itinerary),
      ),
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          saved ? l10n.routeSaved(name) : l10n.routeAlreadySaved(name),
        ),
      ),
    );
  }
}
