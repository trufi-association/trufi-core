import 'package:flutter/material.dart';
import 'package:trufi_core/location/location_search_delegate.dart';

import '../../../trufi_models.dart';

class LocationFormField extends StatelessWidget {
  const LocationFormField({
    Key key,
    @required this.hintText,
    @required this.textLeadingImage,
    @required this.onSaved,
    this.leading,
    this.trailing,
    @required this.value,
  }) : super(key: key);

  final String hintText;
  final Widget textLeadingImage;
  final Function(TrufiLocation) onSaved;
  final Widget leading;
  final Widget trailing;
  final TrufiLocation value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyText1;
    final hintStyle = theme.textTheme.bodyText2.copyWith(
      color: theme.textTheme.caption.color,
    );
    return Row(
      children: [
        if (leading != null)
          SizedBox(
            width: 40.0,
            child: leading,
          ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () async {
                // Show search
                final TrufiLocation location = await showSearch(
                  context: context,
                  delegate: LocationSearchDelegate(
                    currentLocation: value,
                  ),
                );
                // Check result
                if (location != null) {
                  onSaved(location);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: SizedBox(
                  height: 32.0,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.vertical,
                    children: <Widget>[
                      SizedBox(height: 16.0, child: textLeadingImage),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: RichText(
                            text: value != null
                                ? TextSpan(
                                    style: textStyle,
                                    text: value.displayName,
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
          ),
        ),
        if (trailing != null)
          SizedBox(
            width: 40.0,
            child: trailing,
          )
      ],
    );
  }
}
