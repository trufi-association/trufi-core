import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/time_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class CardItinerary extends StatelessWidget {
  const CardItinerary({
    Key key,
    @required this.itinerary,
  }) : super(key: key);
  final PlanItinerary itinerary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final payloadDataPlanState = context.read<PayloadDataPlanCubit>().state;
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            itinerary.firstDeparture()?.headSign ?? localization.instructionVehicleBike,
            style: theme.textTheme.bodyText1.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${localization.instructionDurationMinutes(itinerary.time)} ",
                style: theme.textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffADADAD),
                    fontSize: 16),
              ),
              Text(
                '${durationToHHmm(itinerary.startTime)} - ${durationToHHmm(itinerary.endTime)}',
                style: theme.primaryTextTheme.subtitle1.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                itinerary.getDistanceString(localization),
                style: theme.textTheme.subtitle1.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
              Text(
                payloadDataPlanState.triangleFactor
                    .translateValue(localization),
                style: theme.textTheme.bodyText2
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
