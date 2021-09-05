import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/custom_buttons.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/default_location_form_field.dart';

class BAFormFieldsLandscape extends StatelessWidget {
  const BAFormFieldsLandscape({
    Key key,
    @required this.onSaveFrom,
    @required this.onSaveTo,
    @required this.onSwap,
  }) : super(key: key);

  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final void Function() onSwap;

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final homePageCubit = context.read<HomePageCubit>();
    final homePageState = homePageCubit.state;
    final config = context.read<ConfigurationCubit>().state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
          child: DefaultLocationFormField(
            isOrigin: true,
            hintText: localization.searchPleaseSelectOrigin,
            textLeadingImage: config.markers.fromMarker,
            onSaved: onSaveFrom,
            value: homePageState.fromPlace,
          ),
        ),
        if (homePageState.toPlace != null && homePageState.fromPlace != null)
          SwapButton(
            orientation: Orientation.landscape,
            onSwap: onSwap,
          )
        else
          const SizedBox(
            width: 48.0,
          ),
        Flexible(
          child: DefaultLocationFormField(
            isOrigin: false,
            hintText: localization.searchPleaseSelectDestination,
            textLeadingImage: config.markers.toMarker,
            onSaved: onSaveTo,
            value: homePageState.toPlace,
          ),
        ),
      ],
    );
  }
}
