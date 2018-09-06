import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_search_delegate.dart';

class LocationFormField extends FormField<TrufiLocation> {
  LocationFormField({
    Key key,
    FormFieldSetter<TrufiLocation> onSaved,
    TrufiLocation initialValue,
    String hintText,
  }) : super(
            key: key,
            onSaved: onSaved,
            initialValue: initialValue,
            builder: (FormFieldState<TrufiLocation> state) {
              ThemeData theme = Theme.of(state.context);
              TextStyle textStyle = theme.textTheme.body1;
              TextStyle hintStyle = theme.textTheme.caption;
              return Container(
                padding: EdgeInsets.all(4.0),
                child: GestureDetector(
                  onTap: () async {
                    TrufiLocation location = await showSearch(
                      context: state.context,
                      delegate: LocationSearchDelegate(),
                    );
                    if (location != null) {
                      state.didChange(location);
                      state.save();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.0),
                    decoration: new BoxDecoration(
                      color: theme.highlightColor,
                      border: new Border(
                        bottom: new BorderSide(color: Colors.black, width: 1.0),
                      ),
                    ),
                    child: SizedBox(
                      height: 32.0,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: state.value != null ? textStyle : hintStyle,
                            text: state.value?.description ?? hintText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
}
