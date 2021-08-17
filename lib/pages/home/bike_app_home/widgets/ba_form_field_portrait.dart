import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/home_buttons.dart';
import 'package:trufi_core/pages/home/search_location/default_location_form_field.dart';

class BAFormFieldsPortrait extends StatelessWidget {
  const BAFormFieldsPortrait({
    Key key,
    @required this.onSaveFrom,
    @required this.onSaveTo,
    this.padding = EdgeInsets.zero,
    this.spaceBetween = 0,
  }) : super(key: key);

  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final EdgeInsetsGeometry padding;
  final double spaceBetween;

  @override
  Widget build(BuildContext context) {
    final translations = TrufiLocalization.of(context);
    final homePageCubit = context.read<HomePageCubit>();
    final homePageState = context.read<HomePageCubit>().state;
    final config = context.read<ConfigurationCubit>().state;
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DefaultLocationFormField(
                  isOrigin: true,
                  onSaved: onSaveFrom,
                  hintText: translations.searchPleaseSelectOrigin,
                  textLeadingImage: config.markers.fromMarker,
                  trailing: homePageState.fromPlace != null
                      ? ResetButton(
                          color: Colors.black,
                          onReset: () {
                            homePageCubit.resetFromPlace();
                          })
                      : null,
                  value: homePageState.fromPlace,
                ),
                SizedBox(
                  height: spaceBetween,
                ),
                DefaultLocationFormField(
                  isOrigin: false,
                  onSaved: onSaveTo,
                  hintText: translations.searchPleaseSelectDestination,
                  textLeadingImage: config.markers.toMarker,
                  trailing: homePageState.toPlace != null
                      ? ResetButton(
                          color: Colors.black,
                          onReset: () {
                            homePageCubit.resetToPlace();
                          })
                      : null,
                  value: homePageState.toPlace,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
