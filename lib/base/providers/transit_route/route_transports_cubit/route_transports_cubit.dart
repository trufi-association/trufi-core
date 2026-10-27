import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:trufi_core/base/models/transit_route/transit_route.dart';

import '../repository/hive_local_repository.dart';
import '../repository/local_repository.dart';
import '../services/route_transports_service.dart';

part 'route_transports_state.dart';

class RouteTransportsCubit extends Cubit<RouteTransportsState> {
  final RouteTransportsLocalRepository localRepository;
  final RouteTransportsRemoteRepository routeTransportsRepository;

  RouteTransportsCubit(
    String otpEndpoint, {
    RouteTransportsLocalRepository? localRepository,
    RouteTransportsRemoteRepository? routeTransportsRepository,
  })  : localRepository = localRepository ?? RouteTransportsHiveLocalRepository(),
        routeTransportsRepository =
            routeTransportsRepository ?? RouteTransportsServices(otpEndpoint),
        super(const RouteTransportsState()) {
    load().catchError((error) {});
  }

  /// Shows the cached list at once and, when there is one, fetches the feed
  /// again in the background so a server update reaches installed apps
  /// without the refresh button (trufi-arequipa#74). Offline or on error the
  /// cached list simply stays.
  Future<void> load() async {
    if (state.transports.isNotEmpty) return;
    await localRepository.loadRepository();
    final cached = await localRepository.getTransports();
    emit(state.copyWith(transports: cached, filterTransports: cached));
    if (cached.isEmpty) {
      await refresh();
      return;
    }
    await refresh(silent: true);
  }

  /// Fetches the patterns from the server. With [silent] the loading overlay
  /// is not shown and a failure is swallowed (the current list is kept).
  Future<void> refresh({bool silent = false}) async {
    if (!silent) emit(state.copyWith(isLoading: true));
    try {
      final transports = await routeTransportsRepository.fetchPatterns();
      sortTransitRoutesByAgencyNameAndShortName(transports);
      // transports.sort((a, b) {
      //   int res = -1;
      //   final aShortName = int.tryParse(a.route?.shortName ?? '');
      //   final bShortName = int.tryParse(b.route?.shortName ?? '');
      //   if (aShortName != null && bShortName != null) {
      //     res = aShortName.compareTo(bShortName);
      //   } else if (aShortName == null && bShortName == null) {
      //     res = a.route?.shortName?.compareTo(b.route?.shortName ?? '') ?? 1;
      //   } else if (aShortName != null) {
      //     res = 1;
      //   }
      //   return res;
      // });
      emit(state.copyWith(
        transports: transports,
        filterTransports: transports,
        isLoading: false,
      ));
    } catch (e) {
      if (silent) return;
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
    await localRepository.saveTransports(state.transports);
  }

  void sortTransitRoutesByAgencyNameAndShortName(List<TransitRoute> routes) {
    routes.sort((a, b) {
      final nameA = a.route?.agency?.name.toLowerCase() ?? '';
      final nameB = b.route?.agency?.name.toLowerCase() ?? '';
      final shortNameA = a.route?.shortName?.toLowerCase() ?? '';
      final shortNameB = b.route?.shortName?.toLowerCase() ?? '';

      // First compare by Agency name
      final agencyNameComparison = nameA.compareTo(nameB);
      if (agencyNameComparison != 0) {
        return agencyNameComparison;
      }

      // If Agency names are the same, compare by shortName
      return shortNameA.compareTo(shortNameB);
    });
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
