import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';

import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/pages/home/plan_map/setting_panel/setting_panel.dart';
import 'fetch_error_handler.dart';

class MapSettingButton extends StatelessWidget {
  const MapSettingButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).backgroundColor,
      onPressed: () async {
        final oldPayloadDataPlanState = context.read<PayloadDataPlanCubit>().state;
        final correlationId =
            context.read<PreferencesCubit>().state.correlationId;
        final PayloadDataPlanState newPayloadDataPlanState =
            await Navigator.of(context).push(
          MaterialPageRoute<PayloadDataPlanState>(
            builder: (BuildContext context) => const SettingPanel(),
          ),
        );
        if (oldPayloadDataPlanState != newPayloadDataPlanState) {
          final homePageCubit = context.read<HomePageCubit>();
          await homePageCubit.refreshCurrentRoute();
          final appReviewCubit = context.read<AppReviewCubit>();
          await homePageCubit
              .fetchPlan(correlationId, advancedOptions: newPayloadDataPlanState)
              .then((value) => appReviewCubit.incrementReviewWorthyActions())
              .catchError((error) => onFetchError(context, error as Exception));
        }
      },
      heroTag: null,
      child: const Icon(Icons.tune, color: Colors.black),
    );
  }
}
