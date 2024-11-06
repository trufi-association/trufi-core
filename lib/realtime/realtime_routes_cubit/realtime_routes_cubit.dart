import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:async/async.dart';
import 'package:equatable/equatable.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/pages/home/repository/hive_local_repository.dart';
import 'package:trufi_core/base/providers/transit_route/route_transports_cubit/route_transports_cubit.dart';
import 'package:trufi_core/realtime/realtime_routes_cubit/realtime_request_plan.dart';

part 'realtime_routes_state.dart';

class RealtimeRoutesCubit extends Cubit<RealtimeRoutesState> {
  final _localRepository = MapRouteHiveLocalRepository();
  final RouteTransportsCubit routeTransportsCubit;

  final RealtimeRequestService _requestManager;

  CancelableOperation<Plan?>? currentFetchPlanOperation;

  RealtimeRoutesCubit({
    required String otpEndpoint,
    required this.routeTransportsCubit,
  })  : _requestManager = RealtimeRequestService(otpEndpoint: otpEndpoint),
        super(const RealtimeRoutesState(
          hasRealtime: false,
          transitRoute: null,
        ));

  Future<void> enableRealtime({
    required String routeId,
    required String patternCode,
  }) async {
    emit(state.copyWith(hasRealtime: true));
    TransitRoute? transitRoute = await getTransitRoute(patternCode: patternCode);
    if (transitRoute != null) {
      emit(
        state.copyWith(transitRoute: transitRoute),
      );
    }
  }

  Future<TransitRoute?> getTransitRoute({required String patternCode}) async {
    TransitRoute? transitRoute =
        routeTransportsCubit.state.transports.firstWhereOrNull(
      (element) => element.code == patternCode,
    );
    if (transitRoute == null) {
      await routeTransportsCubit.load();
      transitRoute = routeTransportsCubit.state.transports.firstWhereOrNull(
        (element) => element.code == patternCode,
      );
    }
    if (transitRoute != null) {
      transitRoute = await routeTransportsCubit.fetchDataPattern(transitRoute);
    }
    return transitRoute;
  }

  Future<void> disableRealtime() async {
    emit(const RealtimeRoutesState(
      hasRealtime: false,
      transitRoute: null,
    ));
  }
}
