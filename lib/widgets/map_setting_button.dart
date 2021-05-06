import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';

import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/plan/setting_panel/setting_panel.dart';
import 'package:trufi_core/plan/setting_panel/setting_panel_cubit.dart';
import 'fetch_error_handler.dart';

class MapSettingButton extends StatelessWidget {
  const MapSettingButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).backgroundColor,
      onPressed: () async {
        final oldSettingPanelCubit = context.read<SettingPanelCubit>().state.copyWith();
        final correlationId = context.read<PreferencesCubit>().state.correlationId;
        final SettingPanelState newSettingPanelCubit = await Navigator.of(context).push(
          MaterialPageRoute<SettingPanelState>(
            builder: (BuildContext context) => const SettingPanel(),
          ),
        );
        if (oldSettingPanelCubit != newSettingPanelCubit) {
          final homePageCubit = context.read<HomePageCubit>();
          await homePageCubit.refreshCurrentRoute();
          final appReviewCubit = context.read<AppReviewCubit>();
          await homePageCubit
              .fetchPlan(correlationId, advancedOptions: newSettingPanelCubit)
              .then((value) => appReviewCubit.incrementReviewWorthyActions())
              .catchError((error) => onFetchError(context, error as Exception));
        }
      },
      heroTag: null,
      child: const Icon(Icons.tune, color: Colors.black),
    );
  }
}
