import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_map.dart';
import 'package:trufi_app/location/location_search_delegate.dart';

class LocationFormField extends FormField<TrufiLocation> {
  LocationFormField(
      {FormFieldSetter<TrufiLocation> onSaved,
      FormFieldValidator<TrufiLocation> validator,
      TrufiLocation initialValue,
      bool autovalidate = false,
      String hintText,
      String labelText,
      String helperText,
      MapView mapView})
      : super(
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
                  state.didChange(await showSearch(
                      context: state.context,
                      delegate: new LocationSearchDelegate()));
                  state.save();
                }
              });
              return new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Expanded(
                      child: new TextField(
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
                  )),
                  new Center(
                      child: new IconButton(
                          icon: new Icon(Icons.add_location),
                          onPressed: () {
                            LocationMap.create(mapView,
                                onSubmit: (latitude, longitude) {
                              state.didChange(new TrufiLocation(
                                  description: "Marker Position",
                                  latitude: latitude,
                                  longitude: longitude));
                              state.save();
                            }).showMap();
                          }))
                ],
              );
            });
}
