import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/places_store_repository/shared_preferences_place_storage.dart';

import '../../entities/plan_entity/plan_entity.dart';

part 'setting_panel_state.dart';

class SettingPanelCubit extends Cubit<SettingPanelState> {
  final LocalRepository localRepository;

  final SharedPreferencesPlaceStorage myPlacesStorage =
      SharedPreferencesPlaceStorage("myPlacesStorage");

  SettingPanelCubit(this.localRepository) : super(const SettingPanelState()) {
    _load();
  }

  Future<void> _load() async {
    final jsonString = await localRepository.getStateSettingPanel();
    if (jsonString != null && jsonString.isNotEmpty) {
      emit(
        SettingPanelState.fromJson(jsonDecode(jsonString) as Map<String, dynamic>),
      );
    }
  }

  Future<void> updateMapRouteState(SettingPanelState newState) async {
    await localRepository.saveStateSettingPanel(jsonEncode(newState.toJson()));
    emit(newState);
  }

  Future<void> setTransportMode(TransportMode transportMode) async {
    final newList = [...state.transportModes];
    if (newList.contains(transportMode)) {
      newList.remove(transportMode);
    } else {
      newList.add(transportMode);
    }
    await updateMapRouteState(state.copyWith(transportModes: newList));
  }

  Future<void> setBikeRentalNetwork(BikeRentalNetwork bikeRentalNetwork) async {
    final newList = [...state.bikeRentalNetworks];
    if (newList.contains(bikeRentalNetwork)) {
      newList.remove(bikeRentalNetwork);
    } else {
      newList.add(bikeRentalNetwork);
    }
    await updateMapRouteState(state.copyWith(bikeRentalNetworks: newList));
  }

  Future<void> setWalkingSpeed(WalkingSpeed walkingSpeed) async {
    await updateMapRouteState(state.copyWith(typeWalkingSpeed: walkingSpeed));
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAvoidWalking(bool avoidWalking) async {
    await updateMapRouteState(state.copyWith(avoidWalking: avoidWalking));
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAvoidTransfers(bool avoidTransfers) async {
    await updateMapRouteState(state.copyWith(avoidTransfers: avoidTransfers));
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setIncludeBikeSuggestions(bool includeBikeSuggestions) async {
    await updateMapRouteState(state.copyWith(includeBikeSuggestions: includeBikeSuggestions));
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setParkRide(bool parkRide) async {
    await updateMapRouteState(state.copyWith(includeParkAndRideSuggestions: parkRide));
  }

  Future<void> setBikingSpeed(BikingSpeed bikingSpeed) async {
    await updateMapRouteState(state.copyWith(typeBikingSpeed: bikingSpeed));
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setIncludeCarSuggestions(bool includeCarSuggestions) async {
    await updateMapRouteState(state.copyWith(includeCarSuggestions: includeCarSuggestions));
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setWheelChair(bool wheelchair) async {
    await updateMapRouteState(state.copyWith(wheelchair: wheelchair));
  }
}
