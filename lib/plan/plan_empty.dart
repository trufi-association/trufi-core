import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/location_provider_cubit.dart';
import 'package:trufi_core/widgets/alerts.dart';

import '../trufi_app.dart';
import '../trufi_configuration.dart';
import '../widgets/map_type_button.dart';
import '../widgets/trufi_map.dart';
import '../widgets/trufi_online_map.dart';
import '../widgets/your_location_button.dart';

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
    final cfg = TrufiConfiguration();
    final Locale locale = Localizations.localeOf(context);
    return Stack(children: <Widget>[
      TrufiOnlineMap(
        key: const ValueKey("PlanEmptyMap"),
        controller: _trufiMapController,
        onLongPress: widget.onLongPress,
        layerOptionsBuilder: (context) {
          return <LayerOptions>[
            _trufiMapController.yourLocationLayer,
          ];
        },
      ),
      if (cfg.map.satelliteMapTypeEnabled || cfg.map.terrainMapTypeEnabled)
        Positioned(
          top: 16.0,
          right: 16.0,
          child: _buildUpperActionButtons(context),
        ),
      Positioned(
        bottom: 16.0,
        right: 16.0,
        child: _buildLowerActionButtons(context),
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
      Positioned.fill(
        child: Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width - customOverlayWidgetMargin,
            bottom: 80,
            top: 65,
          ),
          child: widget.customBetweenFabWidget != null
              ? widget.customBetweenFabWidget(context)
              : null,
        ),
      )
    ]);
  }

  Widget _buildUpperActionButtons(BuildContext context) {
    return const SafeArea(
      child: MapTypeButton(),
    );
  }

  Widget _buildLowerActionButtons(BuildContext context) {
    return SafeArea(
      child: YourLocationButton(onPressed: _handleOnYourLocationPressed),
    );
  }

  Future<void> _handleOnYourLocationPressed() async {
    try {
      final location =
          await context.read<LocationProviderCubit>().getCurrentLocation();
      _trufiMapController.moveToYourLocation(
        location: location,
        context: context,
        tickerProvider: this,
      );
    } on PermissionDeniedException catch (_) {
      showDialog(
        context: context,
        builder: (context) => buildAlertLocationServicesDenied(context),
      );
    }
  }
}
