import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/widgets/map/buttons/map_type_button.dart';
import 'package:trufi_core/widgets/map/buttons/your_location_button.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';
import 'package:trufi_core/widgets/map/trufi_map.dart';
import 'package:trufi_core/widgets/map/utils/trufi_map_utils.dart';

import '../../../trufi_app.dart';

const double customOverlayWidgetMargin = 80;

class PlanEmptyPage extends StatefulWidget {
  const PlanEmptyPage({
    Key key,
    @required this.onFetchPlan,
    this.initialPosition,
    this.customOverlayWidget,
    this.customBetweenFabWidget,
  }) : super(key: key);

  final LatLng initialPosition;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;
  final void Function() onFetchPlan;

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
    final homePageCubit = context.read<HomePageCubit>();
    return Stack(
      children: <Widget>[
        TrufiMap(
          key: const ValueKey("PlanEmptyMap"),
          controller: _trufiMapController,
          layerOptionsBuilder: (context) => [
            MarkerLayerOptions(markers: [
              if (homePageCubit.state.fromPlace != null)
                buildFromMarker(homePageCubit.state.fromPlace.latLng),
              if (homePageCubit.state.toPlace != null)
                buildToMarker(homePageCubit.state.toPlace.latLng),
            ]),
          ],
          onLongPress: (location) async {
            await homePageCubit.setTappingPlace(location);
            widget.onFetchPlan();
          },
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
