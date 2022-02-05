import 'package:async_executor/async_executor.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/animation_configuration.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/widgets/alerts/fetch_error_handler.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

Future<void> callFetchPlan(
  BuildContext context, {
  bool car = false,
}) async {
  final mapRouteCubit = context.read<MapRouteCubit>();
  final mapRouteState = mapRouteCubit.state;
  final animations = AnimationConfiguration();
  if (mapRouteState.toPlace == null || mapRouteState.fromPlace == null) {
    return;
  }
  _asyncFetchRoute.run(
    context: context,
    onExecute: () async {
      await mapRouteCubit.fetchPlan(car: car);
    },
    onFinish: (value) {
      AppReviewProvider().incrementReviewWorthyActions();
      showTrufiDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (_) {
          return FlareActor(
            animations.success.filename,
            animation: animations.success.animation,
            callback: (t) => Navigator.maybePop(context),
          );
        },
      );
    },
  );
}

final AsyncExecutor _asyncFetchRoute = AsyncExecutor(
  loadingMessage: (
    BuildContext context,
  ) async {
    return await showTrufiDialog(
      context: context,
      barrierDismissible: false,
      onWillPop: false,
      builder: (context) {
        return AnimationConfiguration().loading;
      },
    );
  },
  errorMessage: (BuildContext context, dynamic error) async {
    return await onFetchError(context, error);
  },
);
