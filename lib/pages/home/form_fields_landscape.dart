import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/widgets/from_marker.dart';
import 'package:trufi_core/widgets/to_marker.dart';

import '../../trufi_models.dart';
import 'home_buttons.dart';
import 'search_location/location_form_field.dart';

class FormFieldsLandscape extends StatelessWidget {
  const FormFieldsLandscape({
    Key key,
    @required this.onSaveFrom,
    @required this.onSaveTo,
    @required this.onReset,
    @required this.onSwap,
  }) : super(key: key);

  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final void Function() onReset;
  final void Function() onSwap;

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final homePageState = context.read<HomePageCubit>().state;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
        child: Form(
          // key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SizedBox(
                width: 40.0,
              ),
              Flexible(
                child: LocationFormField(
                  hintText: localization.searchPleaseSelectOrigin,
                  textLeadingImage: const FromMarker(),
                  onSaved: onSaveFrom,
                  value: homePageState.fromPlace,
                ),
              ),
              SizedBox(
                width: 40.0,
                child: homePageState.isSwappable
                    ? SwapButton(
                        orientation: Orientation.landscape,
                        onSwap: onSwap,
                      )
                    : null,
              ),
              Flexible(
                child: LocationFormField(
                  hintText: localization.searchPleaseSelectDestination,
                  textLeadingImage: const ToMarker(),
                  onSaved: onSaveTo,
                  value: homePageState.toPlace,
                ),
              ),
              SizedBox(
                width: 40.0,
                child: homePageState.isResettable
                    ? ResetButton(onReset: onReset)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
