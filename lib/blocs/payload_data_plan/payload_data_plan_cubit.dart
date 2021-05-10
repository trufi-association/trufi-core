import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/places_store_repository/shared_preferences_place_storage.dart';

part 'payload_data_plan_state.dart';

class PayloadDataPlanCubit extends Cubit<PayloadDataPlanState> {
  final LocalRepository localRepository;

  final SharedPreferencesPlaceStorage myPlacesStorage =
      SharedPreferencesPlaceStorage("myPlacesStorage");

  PayloadDataPlanCubit(this.localRepository)
      : super(const PayloadDataPlanState()) {
    _load();
  }

  Future<void> _load() async {
    final jsonString = await localRepository.getStateSettingPanel();
    if (jsonString != null && jsonString.isNotEmpty) {
      emit(
        PayloadDataPlanState.fromJson(
            jsonDecode(jsonString) as Map<String, dynamic>),
      );
    }
  }

  Future<void> updateMapRouteState(PayloadDataPlanState newState) async {
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

  Future<void> setAvoidWalking({@required bool avoidWalking}) async {
    await updateMapRouteState(state.copyWith(avoidWalking: avoidWalking));
  }

  Future<void> setAvoidTransfers({@required bool avoidTransfers}) async {
    await updateMapRouteState(state.copyWith(avoidTransfers: avoidTransfers));
  }

  Future<void> setIncludeBikeSuggestions(
      {@required bool includeBikeSuggestions}) async {
    await updateMapRouteState(
        state.copyWith(includeBikeSuggestions: includeBikeSuggestions));
  }

  Future<void> setParkRide({@required bool parkRide}) async {
    await updateMapRouteState(
        state.copyWith(includeParkAndRideSuggestions: parkRide));
  }

  Future<void> setBikingSpeed(BikingSpeed bikingSpeed) async {
    await updateMapRouteState(state.copyWith(typeBikingSpeed: bikingSpeed));
  }

  Future<void> setIncludeCarSuggestions(
      {@required bool includeCarSuggestions}) async {
    await updateMapRouteState(
        state.copyWith(includeCarSuggestions: includeCarSuggestions));
  }

  Future<void> setWheelChair({@required bool wheelchair}) async {
    await updateMapRouteState(state.copyWith(wheelchair: wheelchair));
  }
}
