import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/widgets/map/buttons/map_type_button.dart';
import 'package:trufi_core/widgets/map/buttons/your_location_button.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';
import 'package:trufi_core/widgets/map/trufi_map.dart';

import '../../../trufi_app.dart';

const double customOverlayWidgetMargin = 80;

class PlanEmptyPage extends StatefulWidget {
  const PlanEmptyPage(
      {this.initialPosition,
      this.onLongPress,
      this.customOverlayWidget,
      this.customBetweenFabWidget,
      Key key})
      : super(key: key);

  final LatLng initialPosition;
  final LongPressCallback onLongPress;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;

  @override
  PlanEmptyPageState createState() => PlanEmptyPageState();
}

class PlanEmptyPageState extends State<PlanEmptyPage>
    with TickerProviderStateMixin {
  final _trufiMapController = TrufiMapController();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final trufiConfiguration = TrufiConfiguration();
    return Stack(
      children: <Widget>[
        TrufiMap(
          key: const ValueKey("PlanEmptyMap"),
          controller: _trufiMapController,
          layerOptionsBuilder: (context) => [],
        ),
        const Positioned(
          top: 16.0,
          right: 16.0,
          child: MapTypeButton(),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: YourLocationButton(
            trufiMapController: _trufiMapController,
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(
              right: customOverlayWidgetMargin,
              bottom: 60,
            ),
            child: widget.customOverlayWidget != null
                ? widget.customOverlayWidget(context, locale)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 10,
          child: SafeArea(
            child: trufiConfiguration.map.buildMapAttribution(context),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.only(
              left:
                  MediaQuery.of(context).size.width - customOverlayWidgetMargin,
              bottom: 80,
              top: 65,
            ),
            child: widget.customBetweenFabWidget != null
                ? widget.customBetweenFabWidget(context)
                : null,
          ),
        )
      ],
    );
  }
}
