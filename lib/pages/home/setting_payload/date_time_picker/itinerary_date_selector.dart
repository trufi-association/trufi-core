import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import 'date_time_picker.dart';

class ItineraryDateSelector extends StatelessWidget {
  const ItineraryDateSelector({
    Key key,
    @required this.onFetchPlan,
    this.color,
  }) : super(key: key);

  final void Function() onFetchPlan;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final localization = TrufiLocalization.of(context);
    final theme = Theme.of(context);
    final homePageState = context.watch<HomePageCubit>().state;
    final payloadDataPlanCubit = context.watch<PayloadDataPlanCubit>();
    return SizedBox(
      height: 34,
      child: TextButton(
        onPressed: () async {
          final tempPickedDate = await showModalBottomSheet<DateTimeConf>(
            context: context,
            isDismissible: false,
            builder: (BuildContext builder) {
              return DateTimePicker(
                dateConf: DateTimeConf(
                  payloadDataPlanCubit.state.date,
                  isArriveBy: payloadDataPlanCubit.state.arriveBy,
                ),
              );
            },
          );
          if (tempPickedDate != null) {
            await payloadDataPlanCubit.setDataDate(
                arriveBy: tempPickedDate.isArriveBy, date: tempPickedDate.date);
            if (homePageState.isPlacesDefined) {
              onFetchPlan();
            }
          }
        },
        child: Row(
          children: <Widget>[
            Icon(
              Icons.access_time_rounded,
              color: color ?? theme.backgroundColor,
              size: 20,
            ),
            Expanded(
              child: Text(
                payloadDataPlanCubit.state.date == null
                    ? localization.commonLeavingNow
                    : payloadDataPlanCubit.state.arriveBy
                        ? "${localization.commonArrival} ${payloadDataPlanCubit.state.date.customFormat(languageCode)}"
                        : "${localization.commonDeparture}  ${payloadDataPlanCubit.state.date.customFormat(languageCode)}",
                style: color != null
                    ? theme.textTheme.bodyText1.copyWith(fontSize: 15)
                    : theme.textTheme.subtitle1.copyWith(fontSize: 15),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: color ?? theme.backgroundColor,
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
