import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/setting_payload/setting_panel/setting_panel.dart';

class MapSettingButton extends StatelessWidget {
  const MapSettingButton({Key key, @required this.onFetchPlan})
      : super(key: key);

  final void Function() onFetchPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: InkWell(
        onTap: () async {
          final oldPayloadDataPlanState =
              context.read<PayloadDataPlanCubit>().state;

          final PayloadDataPlanState newPayloadDataPlanState =
              await Navigator.of(context).push(
            MaterialPageRoute<PayloadDataPlanState>(
              builder: (BuildContext context) => const SettingPanel(),
            ),
          );

          if (oldPayloadDataPlanState != newPayloadDataPlanState) {
            onFetchPlan();
          }
        },
        child: Row(
          children: [
            Icon(Icons.tune, color: theme.backgroundColor),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                localization.commonSettings,
                style: theme.textTheme.headline6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
