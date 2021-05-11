import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/widgets/map_setting_button.dart';

import 'itinerary_date_selector.dart';

class SettingPayload extends StatelessWidget {
  const SettingPayload({Key key, @required this.onFetchPlan}) : super(key: key);

  final void Function() onFetchPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homePageState = context.watch<HomePageCubit>().state;
    return Container(
      margin: const EdgeInsets.only(left: 36, right: 7),
      child: Row(
        children: [
          Expanded(
            child: ItineraryDateSelector(
              onFetchPlan: onFetchPlan,
            ),
          ),
          if (homePageState.isSwappable)
            Container(width: 1, height: 25, color: theme.backgroundColor),
          if (homePageState.isSwappable)
            MapSettingButton(onFetchPlan: onFetchPlan)
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }
}
