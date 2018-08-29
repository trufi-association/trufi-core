import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_search_delegate.dart';

class LocationFormField extends FormField<TrufiLocation> {
  LocationFormField({
    Key key,
    FormFieldSetter<TrufiLocation> onSaved,
    FormFieldValidator<TrufiLocation> validator,
    TrufiLocation initialValue,
    bool autovalidate = false,
    String hintText,
    String labelText,
    String helperText,
    LatLng position,
  }) : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidate: autovalidate,
            builder: (FormFieldState<TrufiLocation> state) {
              // Open location search
              FocusNode focusNode = new FocusNode();
              focusNode.addListener(() async {
                if (focusNode.hasFocus) {
                  focusNode.unfocus();
                  TrufiLocation location = await showSearch(
                    context: state.context,
                    delegate: new LocationSearchDelegate(position: position),
                  );
                  if (location != null) {
                    state.didChange(location);
                    state.save();
                  }
                }
              });
              return new TextField(
                style: Theme.of(state.context).textTheme.body1,
                focusNode: focusNode,
                controller: new TextEditingController(
                    text: state.value?.description ?? ''),
                decoration: new InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  hintText: hintText,
                  labelText: labelText,
                  helperText: helperText,
                ),
              );
            });
}
