import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class CustomLocationSelector extends StatelessWidget {
  const CustomLocationSelector({
    super.key,
    required this.locationData,
    required this.onFetchPlan,
  });

  final LocationDetail locationData;
  final void Function() onFetchPlan;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    return Row(
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final location = TrufiLocation(
                description: locationData.description,
                address: locationData.street,
                latitude: locationData.position.latitude,
                longitude: locationData.position.longitude,
              );
              await routePlannerCubit.setFromPlace(location);
              searchLocationsCubit.insertHistoryPlace(location);
              onFetchPlan();
            },
            child: Text(
              localization.commonOrigin,
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final location = TrufiLocation(
                description: locationData.description,
                address: locationData.street,
                latitude: locationData.position.latitude,
                longitude: locationData.position.longitude,
              );
              await routePlannerCubit.setToPlace(location);
              searchLocationsCubit.insertHistoryPlace(location);
              onFetchPlan();
            },
            child: Text(
              localization.commonDestination,
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
