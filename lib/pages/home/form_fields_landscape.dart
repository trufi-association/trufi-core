import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/server_type.dart';

import '../../trufi_models.dart';
import 'home_buttons.dart';
import 'search_location/location_form_field.dart';
import 'setting_payload/setting_payload.dart';

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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
        child: Form(
          // key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const SizedBox(
                    width: 40.0,
                  ),
                  Flexible(
                    child: LocationFormField(
                      isOrigin: true,
                      hintText: localization.searchPleaseSelectOrigin,
                      textLeadingImage: config.markers.fromMarker,
                      onSaved: onSaveFrom,
                      value: homePageState.fromPlace,
                    ),
                  ),
                  SizedBox(
                    width: 40.0,
                    child: homePageState.isPlacesDefined
                        ? SwapButton(
                            orientation: Orientation.landscape,
                            onSwap: onSwap,
                          )
                        : null,
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
                  SizedBox(
                    width: 40.0,
                    child: homePageState.isPlacesDefined
                        ? ResetButton(onReset: onReset)
                        : null,
                  ),
                ],
              ),
              if (config.serverType == ServerType.graphQLServer)
                SettingPayload(
                  onFetchPlan: onFetchPlan,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
