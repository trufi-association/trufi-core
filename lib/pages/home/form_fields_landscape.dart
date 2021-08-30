import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import '../../models/trufi_place.dart';
import 'home_buttons.dart';
import 'search_location/location_form_field.dart';

class FormFieldsLandscape extends StatelessWidget {
  const FormFieldsLandscape({
    Key key,
    @required this.onSaveFrom,
    @required this.onSaveTo,
    @required this.onFetchPlan,
    @required this.onReset,
    @required this.onSwap,
  }) : super(key: key);

  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final void Function() onFetchPlan;
  final void Function() onReset;
  final void Function() onSwap;

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final homePageState = context.read<HomePageCubit>().state;
    final config = context.read<ConfigurationCubit>().state;
    return Column(
      children: [
        Form(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    child: LocationFormField(
                      isOrigin: true,
                      hintText: localization.searchPleaseSelectOrigin,
                      textLeadingImage: config.markers.fromMarker,
                      onSaved: onSaveFrom,
                      value: homePageState.fromPlace,
                    ),
                  ),
                  if (homePageState.isPlacesDefined)
                    SwapButton(
                      orientation: Orientation.landscape,
                      onSwap: onSwap,
                    ),
                  Flexible(
                    child: LocationFormField(
                      isOrigin: false,
                      hintText: localization.searchPleaseSelectDestination,
                      textLeadingImage: config.markers.toMarker,
                      onSaved: onSaveTo,
                      value: homePageState.toPlace,
                    ),
                  ),
                  if (homePageState.isPlacesDefined)
                    ResetButton(onReset: onReset),
                ],
              ),
              // if (config.serverType == ServerType.graphQLServer)
              //   SettingPayload(
              //     onFetchPlan: onFetchPlan,
              //   ),
            ],
          ),
        ),
        // const TransportSelector(),
      ],
    );
  }
}
