import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/setting_payload/date_time_picker/date_time_picker.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
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
      height: 40,
      child: GestureDetector(
        onTap: () async {
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 9.5,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.access_time_rounded,
                    color: color ?? theme.backgroundColor,
                    size: 22,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        payloadDataPlanCubit.state.date == null
                            ? localization.commonLeavingNow
                            : payloadDataPlanCubit.state.arriveBy
                                ? "${localization.commonArrival} ${payloadDataPlanCubit.state.date.customFormat(languageCode)}"
                                : "${localization.commonDeparture}  ${payloadDataPlanCubit.state.date.customFormat(languageCode)}",
                        style: theme.textTheme.subtitle1
                            .copyWith(fontSize: 17, color: color),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: color ?? theme.backgroundColor,
                    size: 22,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Container(
                color: color ?? const Color(0xff747474),
                height: 1.5,
              ),
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
