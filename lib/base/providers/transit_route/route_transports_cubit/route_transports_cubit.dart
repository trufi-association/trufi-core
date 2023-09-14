import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:trufi_core/base/models/transit_route/transit_route.dart';

import '../repository/hive_local_repository.dart';
import '../repository/local_repository.dart';
import '../services/route_transports_service.dart';

part 'route_transports_state.dart';

class RouteTransportsCubit extends Cubit<RouteTransportsState> {
  final RouteTransportsLocalRepository localRepository =
      RouteTransportsHiveLocalRepository();
  final RouteTransportsServices routeTransportsRepository;

  RouteTransportsCubit(String otpEndpoint)
      : routeTransportsRepository = RouteTransportsServices(otpEndpoint),
        super(const RouteTransportsState()) {
    load().catchError((error) {});
  }

  Future<void> load() async {
    if (state.transports.isNotEmpty) return;
    await localRepository.loadRepository();
    final transports = await localRepository.getTransports();
    emit(state.copyWith(transports: transports, filterTransports: transports));
    if (state.transports.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true));
    try {
      final transports = await routeTransportsRepository.fetchPatterns();
      transports.sort((a, b) {
        int res = -1;
        final aShortName = int.tryParse(a.route?.shortName ?? '');
        final bShortName = int.tryParse(b.route?.shortName ?? '');
        if (aShortName != null && bShortName != null) {
          res = aShortName.compareTo(bShortName);
        } else if (aShortName == null && bShortName == null) {
          res = a.route?.shortName?.compareTo(b.route?.shortName ?? '') ?? 1;
        } else if (aShortName != null) {
          res = 1;
        }
        return res;
      });
      emit(state.copyWith(
        transports: transports,
        filterTransports: transports,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
    await localRepository.saveTransports(state.transports);
  }

  Future<TransitRoute> fetchDataPattern(TransitRoute pattern) async {
    if (pattern.geometry != null) return pattern;
    emit(state.copyWith(isGeometryLoading: true));
    final newPattern =
        await routeTransportsRepository.fetchDataPattern(pattern.code);
    final newPatterns = _updateItem(state.transports, pattern, newPattern);
    emit(
      state.copyWith(
        transports: newPatterns,
        isGeometryLoading: false,
      ),
    );
    await localRepository.saveTransports(newPatterns);
    return pattern.copyWith(
      geometry: newPattern.geometry,
      stops: newPattern.stops,
    );
  }

  List<TransitRoute> _updateItem(
    List<TransitRoute> list,
    TransitRoute oldLocation,
    TransitRoute newLocation,
  ) {
    final tempList = [...list];
    final int index = tempList.indexOf(oldLocation);
    if (index != -1) {
      tempList.replaceRange(index, index + 1, [
        oldLocation.copyWith(
          geometry: newLocation.geometry,
          stops: newLocation.stops,
        )
      ]);
    }
    return tempList;
  }

  void filterTransports(String query) {
    if (query == "") {
      emit(
        state.copyWith(
          filterTransports: state.transports,
        ),
      );
    } else {
      final newFilterTransports = state.transports
          .where((element) =>
              "${element.name.toLowerCase()} ${element.route!.longNameData.toLowerCase()}"
                  .contains(query))
          .toList();

      emit(
        state.copyWith(
          filterTransports: newFilterTransports,
        ),
      );
    }
  }
}
