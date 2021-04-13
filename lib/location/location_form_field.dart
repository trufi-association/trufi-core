import 'package:flutter/material.dart';

import '../location/location_search_delegate.dart';
import '../trufi_models.dart';

class LocationFormField extends FormField<TrufiLocation> {
  LocationFormField({
    Key key,
    FormFieldSetter<TrufiLocation> onSaved,
    String hintText,
    Widget leadingImage,
  }) : super(
          key: key,
          onSaved: onSaved,
          builder: (FormFieldState<TrufiLocation> state) {
            final theme = Theme.of(state.context);
            final textStyle = theme.textTheme.body2;
            final hintStyle = theme.textTheme.body1.copyWith(
              color: theme.textTheme.caption.color,
            );
            return Container(
              padding: EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () async {
                  // Show search
                  TrufiLocation location = await showSearch(
                    context: state.context,
                    delegate: LocationSearchDelegate(
                      currentLocation: state.value,
                    ),
                  );
                  // Check result
                  if (location != null) {
                    state.didChange(location);
                    state.save();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    border: new Border.all(color: Colors.white, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: SizedBox(
                    height: 32.0,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      direction: Axis.vertical,
                      children: <Widget>[
                        Container(height: 16.0, child: leadingImage),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: RichText(
                              text: state.value != null
                                  ? TextSpan(
                                      style: textStyle,
                                      text: state.value.displayName,
                                    )
                                  : TextSpan(
                                      style: hintStyle,
                                      text: hintText,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
}
