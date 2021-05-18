import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/location/location_search_delegate.dart';

import '../../../trufi_models.dart';

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
    final config = context.read<ConfigurationCubit>().state;
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
                                    text: value.translateValue(
                                      config.abbreviations,
                                      localization,
                                    ),
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

class TypeLocationForm {
  static final TypeLocationForm _singleton = TypeLocationForm._internal();

  factory TypeLocationForm() => _singleton;

  TypeLocationForm._internal();

  bool isOrigin = false;
}
