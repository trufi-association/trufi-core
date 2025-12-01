import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/buttons.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/location_form_field.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';

class FormFieldsPortrait extends StatelessWidget {
  const FormFieldsPortrait({
    super.key,
    required this.onSaveFrom,
    required this.onSaveTo,
    required this.onFetchPlan,
    required this.onReset,
    required this.onSwap,
    required this.selectPositionOnPage,
  });

  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final void Function() onFetchPlan;
  final void Function() onReset;
  final void Function() onSwap;
  final SelectLocationData selectPositionOnPage;
  
  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final routePlannerState = context.watch<RoutePlannerCubit>().state;
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return Container(
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          LocationFormField(
            isOrigin: true,
            onSaved: onSaveFrom,
            hintText: localization.searchPleaseSelectOrigin,
            textLeadingImage: Container(
              padding: const EdgeInsets.all(3.5),
              child: mapConfiguratiom.markersConfiguration.fromMarker,
            ),
            trailing: routePlannerState.isPlacesDefined
                ? ResetButton(onReset: onReset)
                : null,
            value: routePlannerState.fromPlace,
            selectPositionOnPage: selectPositionOnPage,
          ),
          LocationFormField(
            isOrigin: false,
            onSaved: onSaveTo,
            hintText: localization.searchPleaseSelectDestination,
            textLeadingImage: mapConfiguratiom.markersConfiguration.toMarker,
            trailing: routePlannerState.isPlacesDefined
                ? SwapButton(
                    orientation: Orientation.portrait,
                    onSwap: onSwap,
                  )
                : null,
            value: routePlannerState.toPlace,
            selectPositionOnPage: selectPositionOnPage,
          ),
        ],
      ),
    );
  }
}
