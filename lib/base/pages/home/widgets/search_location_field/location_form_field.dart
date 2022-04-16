import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/location_search_delegate/location_search_delegate.dart';

class LocationFormField extends StatelessWidget {
  const LocationFormField({
    Key? key,
    required this.hintText,
    required this.textLeadingImage,
    required this.onSaved,
    required this.isOrigin,
    this.value,
    this.leading,
    this.trailing,
  }) : super(key: key);

  final bool isOrigin;
  final String hintText;
  final Widget textLeadingImage;
  final Function(TrufiLocation) onSaved;
  final TrufiLocation? value;
  final Widget? leading;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final localizationSP = SavedPlacesLocalization.of(context);
    return Row(
      children: [
        if (leading != null)
          SizedBox(
            width: 40.0,
            child: leading,
          ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              // Show search
              final TrufiLocation? location = await showSearch<TrufiLocation?>(
                context: context,
                delegate: LocationSearchDelegate(
                  isOrigin: isOrigin,
                  hint: isOrigin
                      ? localization.searchHintOrigin
                      : localization.searchHintDestination,
                ),
              );
              // Check result
              if (location != null) {
                onSaved(location);
              }
            },
            child: Container(
              height: 36,
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(height: 24.0, child: textLeadingImage),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: RichText(
                        maxLines: 1,
                        text: value != null
                            ? TextSpan(
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                                text:
                                    "${value?.displayName(localizationSP)}${value?.address != null ? ", ${value?.address}" : ""}",
                              )
                            : TextSpan(
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
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
        if (trailing != null)
          SizedBox(
            width: 40.0,
            child: trailing,
          )
      ],
    );
  }
}
