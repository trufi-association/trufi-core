import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/saved_place.dart';
import '../repository/saved_places_repository.dart';
import '../repository/saved_places_repository_impl.dart';

part 'saved_places_state.dart';

/// Cubit for managing saved places.
///
/// Home and Work are special singleton places - only one of each can exist.
/// When setting a new Home/Work, it replaces any existing one.
///
/// If [repository] is not provided, uses [SavedPlacesRepositoryImpl] by default.
class SavedPlacesCubit extends Cubit<SavedPlacesState> {
  final SavedPlacesRepository _repository;

  SavedPlacesCubit({SavedPlacesRepository? repository})
    : _repository = repository ?? SavedPlacesRepositoryImpl(),
      super(const SavedPlacesState());

  /// Initializes the cubit and loads all saved places.
  Future<void> initialize() async {
    emit(state.copyWith(status: SavedPlacesStatus.loading));
    try {
      await _repository.initialize();
      await _loadAllPlaces();
    } catch (e) {
      emit(
        state.copyWith(
          status: SavedPlacesStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadAllPlaces() async {
    final home = await _repository.getHome();
    final work = await _repository.getWork();
    final otherPlaces = await _repository.getOtherPlaces();
    final history = await _repository.getHistory();

    emit(
      state.copyWith(
        status: SavedPlacesStatus.loaded,
        home: home,
        work: work,
        otherPlaces: otherPlaces,
        history: history,
        clearHome: home == null,
        clearWork: work == null,
      ),
    );
  }

  /// Sets the home location. Replaces any existing home.
  Future<void> setHome(SavedPlace place) async {
    // Delete old home if exists
    if (state.home != null) {
      await _repository.deletePlace(state.home!.id);
    }

    final homePlace = place.copyWith(
      id: 'home', // Use fixed ID for home
      type: SavedPlaceType.home,
    );
    await _repository.savePlace(homePlace);
    emit(state.copyWith(home: homePlace));
  }

  /// Sets the work location. Replaces any existing work.
  Future<void> setWork(SavedPlace place) async {
    // Delete old work if exists
    if (state.work != null) {
      await _repository.deletePlace(state.work!.id);
    }

    final workPlace = place.copyWith(
      id: 'work', // Use fixed ID for work
      type: SavedPlaceType.work,
    );
    await _repository.savePlace(workPlace);
    emit(state.copyWith(work: workPlace));
  }

  /// Removes the home location.
  Future<void> removeHome() async {
    if (state.home != null) {
      await _repository.deletePlace(state.home!.id);
      emit(state.copyWith(clearHome: true));
    }
  }

  /// Removes the work location.
  Future<void> removeWork() async {
    if (state.work != null) {
      await _repository.deletePlace(state.work!.id);
      emit(state.copyWith(clearWork: true));
    }
  }

  /// Two saved places closer than this many metres count as "the same spot"
  /// when their names match (#898).
  ///
  /// The map picker returns the raw camera centre, so two taps on the same
  /// building differ by a few metres — a sub-metre epsilon only ever matched
  /// when the map was not moved at all. 50 m is roughly half a city block:
  /// inside it, a same-named entry is a duplicate; beyond it, the user may
  /// legitimately have two "Farmacia" in different neighbourhoods.
  static const double duplicateRadiusMeters = 50;

  /// Great-circle distance in metres between two coordinates (haversine).
  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLon = rad(lon2 - lon1);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Normalises a place name for comparison: trimmed, lower-cased, accents
  /// folded ("Café" == "cafe", also when the accent arrives as a combining
  /// mark), inner whitespace collapsed.
  static String normalizeName(String name) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final buffer = StringBuffer();
    for (final rune in name.toLowerCase().trim().runes) {
      // Combining diacritical marks (U+0300–U+036F): decomposed accents.
      if (rune >= 0x0300 && rune <= 0x036F) continue;
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Whether two places share the same identity: same name (see
  /// [normalizeName]) within [duplicateRadiusMeters] of each other.
  static bool hasSameIdentity(SavedPlace a, SavedPlace b) =>
      normalizeName(a.name) == normalizeName(b.name) &&
      distanceMeters(a.latitude, a.longitude, b.latitude, b.longitude) <=
          duplicateRadiusMeters;

  /// Whether an equivalent place is already saved — see [hasSameIdentity].
  /// Pass [excludeId] when editing so a place doesn't collide with
  /// itself (#898). History entries never count.
  bool isDuplicatePlace(SavedPlace place, {String? excludeId}) {
    bool same(SavedPlace other) =>
        other.id != excludeId && hasSameIdentity(other, place);
    return [
      if (state.home != null) state.home!,
      if (state.work != null) state.work!,
      ...state.otherPlaces,
    ].any(same);
  }

  /// Adds a place to other places.
  Future<void> addOtherPlace(SavedPlace place) async {
    final otherPlace = place.copyWith(type: SavedPlaceType.other);
    await _repository.savePlace(otherPlace);
    emit(state.copyWith(otherPlaces: [...state.otherPlaces, otherPlace]));
  }

  /// Removes a place from other places.
  Future<void> removeOtherPlace(String id) async {
    await _repository.deletePlace(id);
    emit(
      state.copyWith(
        otherPlaces: state.otherPlaces.where((p) => p.id != id).toList(),
      ),
    );
  }

  /// Adds a place to history.
  Future<void> addToHistory(SavedPlace place) async {
    await _repository.addToHistory(place);
    final updatedHistory = await _repository.getHistory();
    emit(state.copyWith(history: updatedHistory));
  }

  /// Removes a place from history.
  Future<void> removeFromHistory(String id) async {
    await _repository.deletePlace(id);
    emit(
      state.copyWith(history: state.history.where((p) => p.id != id).toList()),
    );
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    emit(state.copyWith(history: []));
  }

  /// Saves a place based on its type.
  /// Handles type changes correctly (e.g., other -> home).
  ///
  /// Returns `false` — and persists nothing — when an equivalent place is
  /// already saved (#898). The guard lives here, on the path every screen
  /// saves through, instead of in each screen's dialog wiring; history
  /// entries are never checked. ([addOtherPlace], [setHome] and [setWork]
  /// stay unguarded low-level writers.)
  Future<bool> savePlace(
    SavedPlace place, {
    SavedPlaceType? originalType,
  }) async {
    if (place.type != SavedPlaceType.history &&
        isDuplicatePlace(place, excludeId: place.id)) {
      return false;
    }
    await _savePlace(place, originalType: originalType);
    return true;
  }

  Future<void> _savePlace(
    SavedPlace place, {
    SavedPlaceType? originalType,
  }) async {
    final newType = place.type;

    // If type changed, handle the transition
    if (originalType != null && originalType != newType) {
      // Remove from original location
      switch (originalType) {
        case SavedPlaceType.home:
          emit(state.copyWith(clearHome: true));
          break;
        case SavedPlaceType.work:
          emit(state.copyWith(clearWork: true));
          break;
        case SavedPlaceType.other:
          emit(
            state.copyWith(
              otherPlaces: state.otherPlaces
                  .where((p) => p.id != place.id)
                  .toList(),
            ),
          );
          break;
        case SavedPlaceType.history:
          emit(
            state.copyWith(
              history: state.history.where((p) => p.id != place.id).toList(),
            ),
          );
          break;
      }
      // Delete old record
      await _repository.deletePlace(place.id);
    }

    // Save to new location
    switch (newType) {
      case SavedPlaceType.home:
        await setHome(place);
        break;
      case SavedPlaceType.work:
        await setWork(place);
        break;
      case SavedPlaceType.other:
        if (originalType == newType) {
          // Just updating, not changing type
          await _repository.updatePlace(place);
          emit(
            state.copyWith(
              otherPlaces: state.otherPlaces
                  .map((p) => p.id == place.id ? place : p)
                  .toList(),
            ),
          );
        } else {
          await addOtherPlace(place);
        }
        break;
      case SavedPlaceType.history:
        await addToHistory(place);
        break;
    }
  }

  /// Updates any saved place. Handles type changes.
  ///
  /// Returns `false` when the edit would turn the place into a duplicate of
  /// another saved place. An edit that keeps the place's own identity (icon,
  /// type, a nudge of a few metres) is always accepted, so entries that were
  /// duplicated before the guard existed stay editable.
  Future<bool> updatePlace(SavedPlace updatedPlace) async {
    // Find original place to detect type change
    SavedPlace? original;
    SavedPlaceType? originalType;

    if (state.home?.id == updatedPlace.id) {
      original = state.home;
      originalType = SavedPlaceType.home;
    } else if (state.work?.id == updatedPlace.id) {
      original = state.work;
      originalType = SavedPlaceType.work;
    } else if (state.otherPlaces.any((p) => p.id == updatedPlace.id)) {
      original = state.otherPlaces.firstWhere((p) => p.id == updatedPlace.id);
      originalType = SavedPlaceType.other;
    } else if (state.history.any((p) => p.id == updatedPlace.id)) {
      original = state.history.firstWhere((p) => p.id == updatedPlace.id);
      originalType = SavedPlaceType.history;
    }

    final identityChanged =
        original == null || !hasSameIdentity(updatedPlace, original);
    if (identityChanged) {
      return savePlace(updatedPlace, originalType: originalType);
    }
    await _savePlace(updatedPlace, originalType: originalType);
    return true;
  }

  /// Deletes any saved place.
  Future<void> deletePlace(SavedPlace place) async {
    switch (place.type) {
      case SavedPlaceType.home:
        await removeHome();
        break;
      case SavedPlaceType.work:
        await removeWork();
        break;
      case SavedPlaceType.other:
        await removeOtherPlace(place.id);
        break;
      case SavedPlaceType.history:
        await removeFromHistory(place.id);
        break;
    }
  }

  @override
  Future<void> close() async {
    await _repository.dispose();
    return super.close();
  }
}
