import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/saved_route.dart';
import '../repository/saved_routes_repository.dart';
import '../repository/saved_routes_repository_impl.dart';

part 'saved_routes_state.dart';

/// Cubit for the saved origin–destination routes (#1005).
///
/// Every write persists first and then emits a new list; [SavedRoutesState.error]
/// is cleared on success. If [repository] is not provided, uses
/// [SavedRoutesRepositoryImpl] by default.
class SavedRoutesCubit extends Cubit<SavedRoutesState> {
  final SavedRoutesRepository _repository;

  SavedRoutesCubit({SavedRoutesRepository? repository})
    : _repository = repository ?? SavedRoutesRepositoryImpl(),
      super(const SavedRoutesState());

  /// Two routes whose endpoints both lie closer than this many metres are
  /// the same trip. Same human-scale rule as
  /// `SavedPlacesCubit.duplicateRadiusMeters` (#898): a map pick or a
  /// geocoder hit differs by a few metres between two attempts at "the same
  /// spot", and 50 m is roughly half a city block. Names never take part,
  /// and the reversed direction is a different trip (see [swapRoute]).
  static const double duplicateRadiusMeters = 50;

  /// Initializes the cubit and loads all saved routes.
  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository.initialize();
      final routes = await _repository.getAllRoutes();
      emit(state.copyWith(routes: routes, isLoading: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// The saved route whose endpoints match [origin] and [destination] within
  /// [duplicateRadiusMeters], or null. Pass [excludeId] when editing so a
  /// route does not collide with itself.
  SavedRoute? findDuplicate({
    required SavedRoutePoint origin,
    required SavedRoutePoint destination,
    String? excludeId,
  }) {
    for (final route in state.routes) {
      if (route.id == excludeId) continue;
      final sameOrigin = route.origin.isNear(
        origin,
        radiusMeters: duplicateRadiusMeters,
      );
      final sameDestination = route.destination.isNear(
        destination,
        radiusMeters: duplicateRadiusMeters,
      );
      if (sameOrigin && sameDestination) return route;
    }
    return null;
  }

  /// Appends [route]. Returns `false`, and persists nothing, when an
  /// equivalent trip is already saved (see [findDuplicate]).
  Future<bool> saveRoute(SavedRoute route) async {
    final duplicate = findDuplicate(
      origin: route.origin,
      destination: route.destination,
      excludeId: route.id,
    );
    if (duplicate != null) return false;
    await _repository.saveRoute(route);
    emit(state.copyWith(routes: [...state.routes, route], clearError: true));
    return true;
  }

  /// Renames the route with [id]; the name is trimmed and an empty name is
  /// ignored.
  Future<void> renameRoute(String id, String name) async {
    final trimmed = name.trim();
    final route = _routeById(id);
    if (trimmed.isEmpty || route == null) return;
    await _replace(route.copyWith(name: trimmed));
  }

  /// Inverts origin and destination of the route with [id]. Returns `false`
  /// when the inverted trip would duplicate another saved route.
  Future<bool> swapRoute(String id) async {
    final route = _routeById(id);
    if (route == null) return false;
    final swapped = route.swapped();
    final duplicate = findDuplicate(
      origin: swapped.origin,
      destination: swapped.destination,
      excludeId: id,
    );
    if (duplicate != null) return false;
    await _replace(swapped);
    return true;
  }

  /// Deletes the route with [id].
  Future<void> deleteRoute(String id) async {
    await _repository.deleteRoute(id);
    emit(
      state.copyWith(
        routes: state.routes.where((r) => r.id != id).toList(),
        clearError: true,
      ),
    );
  }

  /// Stamps [SavedRoute.lastUsedAt] with now. The list order is untouched
  /// so nothing jumps under the user's finger while tapping.
  Future<void> markUsed(String id) async {
    final route = _routeById(id);
    if (route == null) return;
    await _replace(route.copyWith(lastUsedAt: DateTime.now()));
  }

  SavedRoute? _routeById(String id) =>
      state.routes.where((r) => r.id == id).firstOrNull;

  Future<void> _replace(SavedRoute route) async {
    await _repository.updateRoute(route);
    emit(
      state.copyWith(
        routes: state.routes.map((r) => r.id == route.id ? route : r).toList(),
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _repository.dispose();
    return super.close();
  }
}
