import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

import 'date_time_picker.dart';

class ItineraryDateSelector extends StatelessWidget {
  const ItineraryDateSelector({
    super.key,
    required this.onFetchPlan,
  });

  final void Function() onFetchPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    final localizations = MaterialLocalizations.of(context);
    return InkWell(
      onTap: () async {
        final tempPickedDate = await showTrufiModalBottomSheet<DateTimeConf>(
          context: context,
          isDismissible: false,
          builder: (BuildContext builder) {
            return DateTimePicker(
              dateConf: DateTimeConf(
                routePlannerState.selectedDateTime,
                isArriveBy: false,
              ),
            );
          },
        );
        if (tempPickedDate != null) {
          await routePlannerCubit.setDataDate(
              arriveBy: tempPickedDate.isArriveBy, date: tempPickedDate.date);
          if (routePlannerState.isPlacesDefined) {
            onFetchPlan();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.access_time_rounded,
              color: theme.colorScheme.onBackground,
              size: 20,
            ),
            Expanded(
              child: Text(
                routePlannerState.selectedDateTime == null
                    ? "Leaving now"
                    : DateFormat('HH:mm : dd-MM-yyyy').format(routePlannerState.selectedDateTime!),
                style: TextStyle(
                  fontSize: 15,
                  height: 0,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onBackground,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

extension on DateTime {
  String customFormat(String languageCode) {
    return DateFormat('E dd.MM.  HH:mm', languageCode).format(this);
  }
}
