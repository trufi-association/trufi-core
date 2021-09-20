import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/location/location_search_delegate.dart';
import 'package:trufi_core/models/trufi_place.dart';

class DefaultLocationFormField extends StatelessWidget {
  const DefaultLocationFormField({
    Key key,
    @required this.hintText,
    @required this.textLeadingImage,
    @required this.onSaved,
    @required this.isOrigin,
    @required this.value,
    this.showTitle = true,
    this.leading,
    this.trailing,
  }) : super(key: key);

  final bool isOrigin;
  final String hintText;
  final bool showTitle;
  final Widget textLeadingImage;
  final Function(TrufiLocation) onSaved;
  final Widget leading;
  final Widget trailing;
  final TrufiLocation value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final textStyle = theme.textTheme.subtitle1.copyWith(fontSize: 18);
    final hintStyle = theme.textTheme.subtitle1.copyWith(fontSize: 18);
    return GestureDetector(
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.only(
              left: 10.0,
              top: 14.0,
            ),
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: <Widget>[
                SizedBox(height: 16.0, child: textLeadingImage),
                Expanded(
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
                if (trailing != null)
                  SizedBox(
                    width: 22,
                    child: trailing,
                  )
              ],
            ),
          ),
          Positioned(
            bottom: 3,
            left: 0,
            right: 0,
            child: Container(
              color: theme.dividerColor,
              height: 0.65,
            ),
          ),
          if (value != null && showTitle)
            Positioned(
              top: 0,
              left: 10,
              child: Text(
                hintText,
                style: theme.textTheme.bodyText1.copyWith(
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}