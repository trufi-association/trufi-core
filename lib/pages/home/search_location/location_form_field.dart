import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/location/location_search_delegate.dart';

import '../../../models/trufi_place.dart';

class LocationFormField extends StatelessWidget {
  const LocationFormField({
    Key key,
    @required this.hintText,
    @required this.textLeadingImage,
    @required this.onSaved,
    @required this.isOrigin,
    this.leading,
    this.trailing,
    @required this.value,
  }) : super(key: key);

  final bool isOrigin;
  final String hintText;
  final Widget textLeadingImage;
  final Function(TrufiLocation) onSaved;
  final Widget leading;
  final Widget trailing;
  final TrufiLocation value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final textStyle = theme.textTheme.bodyText1;
    final hintStyle = theme.textTheme.bodyText2.copyWith(
      color: theme.textTheme.caption.color,
    );
    return Row(
      children: [
        if (leading != null) leading,
        Expanded(
          child: GestureDetector(
            onTap: () async {
              TypeLocationForm().isOrigin = isOrigin;
              // Show search
              final TrufiLocation location = await showSearch<TrufiLocation>(
                context: context,
                delegate: LocationSearchDelegate(),
              );
              // Check result
              if (location != null) {
                onSaved(location);
              }
            },
            child: Container(
              height: 36,
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(height: 16.0, child: textLeadingImage),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: RichText(
                        maxLines: 1,
                        text: value != null
                            ? TextSpan(
                                style: textStyle,
                                text:
                                    "${value.displayName(localization)}${value.address != null ? ", ${value.address}" : ""}",
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
        if (trailing != null) trailing,
      ],
    );
  }
}

class TypeLocationForm {
  static final TypeLocationForm _singleton = TypeLocationForm._internal();

  factory TypeLocationForm() => _singleton;

  TypeLocationForm._internal();

  bool isOrigin = false;
}
