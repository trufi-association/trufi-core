import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/request_manager.dart';

class HomePageBloc extends Cubit<MapRouteState> {
  LocalRepository sharedPreferencesRepository;
  RequestManager requestManager;

  HomePageBloc(this.sharedPreferencesRepository) : super(MapRouteState());

  Future<void> loadFromSharedPreferences() async {
    final jsonString = await sharedPreferencesRepository.getStateHomePage();

    if (jsonString != null && jsonString.isNotEmpty) {
      emit(MapRouteState.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>));
    }
  }

  void reset() {
    emit(MapRouteState());
    sharedPreferencesRepository.deleteStateHomePage();
  }

  void updateHomePageStateData(MapRouteState newState) {
    sharedPreferencesRepository.saveStateHomePage(
      jsonEncode(newState.toJson()),
    );

    emit(newState);
  }

  void swapLocations() {
    emit(
      state.copyWith(fromPlace: state.toPlace, toPlace: state.fromPlace),
    );
  }
}
