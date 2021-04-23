import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_models.dart';

class HomePageCubit extends Cubit<MapRouteState> {
  LocalRepository localRepository;
  RequestManager requestManager;

  HomePageCubit(this.localRepository)
      : super(MapRouteState(
          isFetching: false,
          showSuccessAnimation: false,
        )) {
    _load();
  }

  Future<void> _load() async {
    final jsonString = await localRepository.getStateHomePage();

    if (jsonString != null && jsonString.isNotEmpty) {
      emit(
        MapRouteState.fromJson(jsonDecode(jsonString) as Map<String, dynamic>),
      );
    }
  }

  void reset() {
    emit(MapRouteState(
      isFetching: false,
      showSuccessAnimation: false,
    ));
    localRepository.deleteStateHomePage();
  }

  Future<void> updateHomePageStateData(MapRouteState newState) async {
    await localRepository.saveStateHomePage(jsonEncode(newState.toJson()));

    emit(newState);
  }

  Future<void> setFromPlace(TrufiLocation fromPlace) async {
    await updateHomePageStateData(state.copyWith(fromPlace: fromPlace));
  }

  Future<void> setPlan(Plan plan) async {
    await updateHomePageStateData(state.copyWith(
      plan: plan,
      isFetching: false,
      showSuccessAnimation: true,
    ));
  }

  Future<void> swapLocations() async {
    await updateHomePageStateData(
      state.copyWith(
        fromPlace: state.toPlace,
        toPlace: state.fromPlace,
        isFetching: true,
      ),
    );
  }

  Future<void> setToPlace(TrufiLocation toPlace) async {
    await updateHomePageStateData(
        state.copyWith(toPlace: toPlace, isFetching: true));
  }

  Future<void> configSuccessAnimation({bool show}) async {
    await updateHomePageStateData(state.copyWith(showSuccessAnimation: show));
  }
}
