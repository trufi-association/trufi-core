import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/custom_buttons.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/default_location_form_field.dart';

class BAFormFieldsPortrait extends StatelessWidget {
  const BAFormFieldsPortrait({
    Key key,
    @required this.onSaveFrom,
    @required this.onSaveTo,
    @required this.onSwap,
    this.padding = EdgeInsets.zero,
    this.spaceBetween = 0,
    this.showTitle = true,
  }) : super(key: key);

  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final void Function() onSwap;
  final EdgeInsetsGeometry padding;
  final double spaceBetween;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final homePageState = context.read<HomePageCubit>().state;
    return Column(
      children: [
        Container(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DefaultLocationFormField(
                isOrigin: true,
                onSaved: onSaveFrom,
                // TODO translate
                hintText: "Ihr Start",
                textLeadingImage: null,
                value: homePageState.fromPlace,
                showTitle: showTitle,
              ),
              SizedBox(
                height: spaceBetween,
              ),
              DefaultLocationFormField(
                  isOrigin: false,
                  onSaved: onSaveTo,
                  // TODO translate
                  hintText: "Ihr Zielort",
                  textLeadingImage: null,
                  trailing: homePageState.toPlace != null &&
                          homePageState.fromPlace != null
                      ? SwapButton(
                          orientation: Orientation.portrait,
                          onSwap: onSwap,
                        )
                      : null,
                  value: homePageState.toPlace,
                  showTitle: showTitle),
            ],
          ),
        ),
      ],
    );
  }
}
