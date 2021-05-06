import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';

import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/pages/home/plan_map/setting_panel/setting_panel.dart';
import 'package:trufi_core/pages/home/plan_map/setting_panel/setting_panel_cubit.dart';
import 'fetch_error_handler.dart';

class MapSettingButton extends StatelessWidget {
  const MapSettingButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).backgroundColor,
      onPressed: () async {
        final oldSettingPanelState = context.read<SettingPanelCubit>().state;
        final correlationId = context.read<PreferencesCubit>().state.correlationId;
        final SettingPanelState newSettingPanelState = await Navigator.of(context).push(
          MaterialPageRoute<SettingPanelState>(
            builder: (BuildContext context) => const SettingPanel(),
          ),
        );
        if (oldSettingPanelState != newSettingPanelState) {
          final homePageCubit = context.read<HomePageCubit>();
          await homePageCubit.refreshCurrentRoute();
          final appReviewCubit = context.read<AppReviewCubit>();
          await homePageCubit
              .fetchPlan(correlationId, advancedOptions: newSettingPanelState)
              .then((value) => appReviewCubit.incrementReviewWorthyActions())
              .catchError((error) => onFetchError(context, error as Exception));
        }
      },
      heroTag: null,
      child: const Icon(Icons.tune, color: Colors.black),
    );
  }
}
