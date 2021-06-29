import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/widget/icon_transport.dart';

class ModeLeg extends StatelessWidget {
  final double maxWidth;
  final PlanItineraryLeg leg;
  final String mode;
  final double legLength;
  final int duration;
  final bool isTransitLeg;
  final bool renderModeIcons;

  const ModeLeg({
    Key key,
    this.leg,
    this.mode,
    this.legLength,
    this.duration,
    this.isTransitLeg,
    this.renderModeIcons,
    @required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final perc = legLength.abs() / 10;
    return SizedBox(
      width: (maxWidth * perc) >= 24 ? (maxWidth * perc) : 24,
      height: 30,
      child: IconTransport(
        bacgroundColor: leg.transportMode == TransportMode.bicycle &&
                leg.fromPlace.bikeRentalStation != null
            ? getBikeRentalNetwork(leg.fromPlace.bikeRentalStation.networks[0])
                .color
            : mode == 'WAIT'
                ? TransportMode.walk.backgroundColor
                : leg.transportMode.backgroundColor,
        color: Colors.black,
        text: (maxWidth * perc - 24) >= (duration.toString().length * 8.5)
            ? duration?.toString() ??
                leg.durationLeg(localization).split(' ')[0]
            : '',
        icon: leg.transportMode == TransportMode.bicycle &&
                leg.fromPlace.bikeRentalStation != null
            ? getBikeRentalNetwork(leg.fromPlace.bikeRentalStation.networks[0])
                .image
            : mode == 'WAIT'
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    width: 20,
                    height: 20,
                    child: waitSvg,
                  )
                : mode == 'WALK'
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        width: 20,
                        height: 20,
                        child: TransportMode.walk.getImage())
                    : mode == 'BICYCLE'
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            width: 20,
                            height: 20,
                            child: TransportMode.bicycle.getImage(),
                          )
                        : leg.transportMode.getImage(
                            color: Colors.white,
                          ),
      ),
    );
  }
}

class RouteLeg extends StatelessWidget {
  final double maxWidth;
  final PlanItineraryLeg leg;
  final PlanItineraryLeg beforeLeg;
  final String mode;
  final double legLength;
  final int duration;
  final bool isTransitLeg;
  final bool renderModeIcons;
  final bool fitRouteNumber;

  const RouteLeg({
    Key key,
    this.leg,
    this.beforeLeg,
    this.mode,
    this.legLength,
    this.duration,
    this.isTransitLeg,
    this.renderModeIcons,
    this.fitRouteNumber,
    @required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final perc = legLength.abs() / 10;
    final isRedenderBike = beforeLeg?.transportMode == TransportMode.bicycle &&
        beforeLeg?.toPlace?.bikeParkEntity == null;
    return SizedBox(
      width: (maxWidth * perc) >= 24 ? (maxWidth * perc) : 24,
      height: 30,
      child: ClipRRect(
        child: IconTransport(
          bacgroundColor: leg?.route?.color != null
              ? Color(int.tryParse("0xFF${leg.route.color}"))
              : leg.transportMode.backgroundColor,
          color: Colors.white,
          icon: (leg?.route?.type ?? 0) == 715
              ? onDemandTaxiSvg(color: 'FFFFFF')
              : leg.transportMode.getImage(color: Colors.white),
          secondaryIcon: (maxWidth * perc) >= 46 && isRedenderBike
              ? bikeSvg(color: 'FFFFFF')
              : null,
          text: (maxWidth * perc - 24) >=
                  ((leg?.route?.shortName?.length ?? 100) * 8.5)
              ? leg?.route?.shortName != null
                  ? leg.route.shortName
                  : leg.transportMode.getTranslate(localization)
              : '',
        ),
      ),
    );
  }
}
