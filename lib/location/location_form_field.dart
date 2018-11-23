import 'package:flutter/material.dart';

import 'package:trufi_app/location/location_search_delegate.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

class LocationFormField extends FormField<TrufiLocation> {
  LocationFormField({
    Key key,
    FormFieldSetter<TrufiLocation> onSaved,
    String hintText,
    String searchHintText,
  }) : super(
          key: key,
          onSaved: onSaved,
          builder: (FormFieldState<TrufiLocation> state) {
            final theme = Theme.of(state.context);
            final textStyle = theme.textTheme.body1;
            final hintStyle = theme.textTheme.body1.copyWith(
              color: theme.textTheme.caption.color,
            );
            return Container(
              padding: EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () async {
                  TrufiMaterialLocalizations materialLocalizations =
                      TrufiMaterialLocalizations.of(state.context);
                  materialLocalizations.setSearchHintText(searchHintText);
                  TrufiLocation location = await showSearch(
                    context: state.context,
                    delegate: LocationSearchDelegate(
                      currentLocation: state.value,
                    ),
                  );
                  if (location != null) {
                    state.didChange(location);
                    state.save();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  decoration: new BoxDecoration(
                    color: Colors.transparent,
                    border: new Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: SizedBox(
                    height: 32.0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: RichText(
                          text: state.value != null
                              ? TextSpan(
                                  style: textStyle,
                                  text: state.value.description,
                                )
                              : TextSpan(
                                  style: hintStyle,
                                  text: hintText,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
}
