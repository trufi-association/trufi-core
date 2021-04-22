import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_models.dart';

class HomePageBloc extends Cubit<MapRouteState> {
  LocalRepository localRepository;
  RequestManager requestManager;

  HomePageBloc(this.localRepository)
      : super(MapRouteState(
          isFetching: false,
          showSuccessAnimation: false,
        ));

  Future<void> loadFromSharedPreferences() async {
    final jsonString = await localRepository.getStateHomePage();

    if (jsonString != null && jsonString.isNotEmpty) {
      emit(MapRouteState.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>));
    }
  }

  void reset() {
    emit(MapRouteState(
      isFetching: false,
      showSuccessAnimation: false,
    ));
    localRepository.deleteStateHomePage();
  }

  void updateHomePageStateData(MapRouteState newState) {
    localRepository.saveStateHomePage(
      jsonEncode(newState.toJson()),
    );

    emit(newState);
  }

  void setFromPlace(TrufiLocation fromPlace) {
    updateHomePageStateData(state.copyWith(fromPlace: fromPlace));
  }

  void setPlan(Plan plan) {
    updateHomePageStateData(state.copyWith(
      plan: plan,
      isFetching: false,
      showSuccessAnimation: true,
    ));
  }

  void swapLocations() {
    updateHomePageStateData(
      state.copyWith(
        fromPlace: state.toPlace,
        toPlace: state.fromPlace,
        isFetching: true,
      ),
    );
  }

  void setToPlace(TrufiLocation toPlace) {
    updateHomePageStateData(state.copyWith(toPlace: toPlace, isFetching: true));
  }

  void configSuccessAnimation({bool show}) {
    updateHomePageStateData(state.copyWith(showSuccessAnimation: show));
  }
}
