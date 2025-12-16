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

  SavedPlacesCubit({
    SavedPlacesRepository? repository,
  })  : _repository = repository ?? SavedPlacesRepositoryImpl(),
        super(const SavedPlacesState());

  /// Initializes the cubit and loads all saved places.
  Future<void> initialize() async {
    emit(state.copyWith(status: SavedPlacesStatus.loading));
    try {
      await _repository.initialize();
      await _loadAllPlaces();
    } catch (e) {
      emit(state.copyWith(
        status: SavedPlacesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _loadAllPlaces() async {
    final home = await _repository.getHome();
    final work = await _repository.getWork();
    final otherPlaces = await _repository.getOtherPlaces();
    final history = await _repository.getHistory();

    emit(state.copyWith(
      status: SavedPlacesStatus.loaded,
      home: home,
      work: work,
      otherPlaces: otherPlaces,
      history: history,
      clearHome: home == null,
      clearWork: work == null,
    ));
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

  /// Adds a place to other places.
  Future<void> addOtherPlace(SavedPlace place) async {
    final otherPlace = place.copyWith(type: SavedPlaceType.other);
    await _repository.savePlace(otherPlace);
    emit(state.copyWith(otherPlaces: [...state.otherPlaces, otherPlace]));
  }

  /// Removes a place from other places.
  Future<void> removeOtherPlace(String id) async {
    await _repository.deletePlace(id);
    emit(state.copyWith(
      otherPlaces: state.otherPlaces.where((p) => p.id != id).toList(),
    ));
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
    emit(state.copyWith(
      history: state.history.where((p) => p.id != id).toList(),
    ));
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    emit(state.copyWith(history: []));
  }

  /// Saves a place based on its type.
  /// Handles type changes correctly (e.g., other -> home).
  Future<void> savePlace(SavedPlace place, {SavedPlaceType? originalType}) async {
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
          emit(state.copyWith(
            otherPlaces: state.otherPlaces.where((p) => p.id != place.id).toList(),
          ));
          break;
        case SavedPlaceType.history:
          emit(state.copyWith(
            history: state.history.where((p) => p.id != place.id).toList(),
          ));
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
          emit(state.copyWith(
            otherPlaces: state.otherPlaces.map((p) => p.id == place.id ? place : p).toList(),
          ));
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
  Future<void> updatePlace(SavedPlace updatedPlace) async {
    // Find original place to detect type change
    SavedPlaceType? originalType;

    if (state.home?.id == updatedPlace.id) {
      originalType = SavedPlaceType.home;
    } else if (state.work?.id == updatedPlace.id) {
      originalType = SavedPlaceType.work;
    } else if (state.otherPlaces.any((p) => p.id == updatedPlace.id)) {
      originalType = SavedPlaceType.other;
    } else if (state.history.any((p) => p.id == updatedPlace.id)) {
      originalType = SavedPlaceType.history;
    }

    await savePlace(updatedPlace, originalType: originalType);
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
