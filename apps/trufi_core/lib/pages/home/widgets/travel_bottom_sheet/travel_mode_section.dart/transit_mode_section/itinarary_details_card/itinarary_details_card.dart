import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:tr_translations/l10n/app_localizations.dart';
import 'package:tr_translations/trufi_localizations_provider.dart';
import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/travel_mode_section.dart/transit_mode_section/itinerary_card/itinerary_path.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/widgets/base_marker/from_marker.dart';
import 'package:trufi_core/widgets/base_marker/to_marker.dart';
import 'package:trufi_core/widgets/buttons/trufi_icon_button.dart';
import 'package:trufi_core/widgets/fare_ticket/ticket_selection_result.dart';
import 'package:trufi_core/widgets/utils.dart';
import 'package:trufi_core/widgets/utils/date_time_utils.dart';
import 'package:trufi_core/widgets/utils/leg_utils.dart';

class ItineraryDetailsCard extends StatelessWidget {
  const ItineraryDetailsCard({
    required this.onRouteDetailsViewChanged,
    required this.plan,
    required this.itinerary,
    required this.updateCamera,
    super.key,
  });
  final void Function(bool) onRouteDetailsViewChanged;
  final PlanEntity plan;
  final PlanItinerary itinerary;
  final bool Function({
    LatLng? target,
    double? zoom,
    double? bearing,
    LatLngBounds? visibleRegion,
  })
  updateCamera;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            BackButton(
              onPressed: () {
                onRouteDetailsViewChanged(false);
              },
              // icon: Icon(Icons.arrow_back_ios),
              // isCompact: true,
            ),
            Text(
              'Public transport',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 4),
            TrufiIconButton(
              onPressed: () {},
              icon: const Icon(Icons.ios_share),
              isCompact: true,
            ),
            const SizedBox(width: 16),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SizedBox(width: 4),
                  Expanded(child: ItineraryPath(itinerary: itinerary)),
                  const SizedBox(width: 4),
                  if (!itinerary.legs.every(
                    (l) => l.transportMode == TransportMode.walk,
                  ))
                    OutlinedButton(
                      onPressed: () async {
                        TicketSelector.show(context);
                      },
                      child: const Text('Buy Ticket'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ItineraryLocationTile(
                text: plan.from?.name ?? '',
                icon: const FromMarker(),
                moveTo: () {
                  updateCamera(
                    target: LatLng(plan.from!.latitude!, plan.from!.longitude!),
                    zoom: 18,
                  );
                },
              ),
              const SizedBox(height: 10),
              ...itinerary.legs.map((leg) {
                return leg.transitLeg
                    ? TransitDetailsIcon(
                        leg: leg,
                        moveTo: (p0) {
                          updateCamera(target: p0, zoom: 18);
                        },
                      )
                    : WalkDetailsIcon(
                        leg: leg,
                        moveTo: (p0) {
                          updateCamera(target: p0, zoom: 18);
                        },
                      );
              }),
              const SizedBox(height: 10),
              ItineraryLocationTile(
                text: plan.to?.name ?? '',
                icon: const SizedBox(
                  width: 24,
                  height: 30,
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: SizedBox(width: 30, height: 30, child: ToMarker()),
                  ),
                ),
                moveTo: () {
                  updateCamera(
                    target: LatLng(plan.to!.latitude!, plan.to!.longitude!),
                    zoom: 18,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ItineraryLocationTile extends StatelessWidget {
  const ItineraryLocationTile({
    required this.text,
    required this.moveTo,
    required this.icon,
    super.key,
  });
  final String text;
  final VoidCallback moveTo;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        icon,
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: moveTo,
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WalkDetailsIcon extends StatelessWidget {
  const WalkDetailsIcon({required this.leg, required this.moveTo, super.key});
  final PlanItineraryLeg leg;
  final Function(LatLng) moveTo;

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalizationsProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Column(
              children: [
                const DotWalkIcon(),
                const SizedBox(height: 10),
                const DotWalkIcon(),
                const SizedBox(height: 8),
                leg.transportMode.getImage(),
                const SizedBox(height: 8),
                const DotWalkIcon(),
                const SizedBox(height: 8),
                const DotWalkIcon(),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, thickness: 1),
                    InkWell(
                      onTap: () {
                        moveTo(LatLng(leg.fromPlace!.lat, leg.fromPlace!.lon));
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 3, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Walk ${DateTimeUtils.durationToStringTime(leg.duration)} (${ItineraryLegUtils.distanceWithTranslation(leg.distance, localization)})',
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DotWalkIcon extends StatelessWidget {
  const DotWalkIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withAlpha(110),
      ),
    );
  }
}

class TransitDetailsIcon extends StatelessWidget {
  const TransitDetailsIcon({
    required this.leg,
    required this.moveTo,
    super.key,
  });
  final PlanItineraryLeg leg;
  final Function(LatLng) moveTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalizationsProvider.of(context);
    final color = hexToColor(leg.route?.color);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TransitLineSpace(
        icon: leg.transportMode.getImage(color: Colors.black),
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                moveTo(LatLng(leg.fromPlace!.lat, leg.fromPlace!.lon));
              },
              child: Text(
                leg.fromPlace?.name ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                moveTo(LatLng(leg.fromPlace!.lat, leg.fromPlace!.lon));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: hexToColor(leg.route?.color),
                      ),
                      child: Text(
                        leg.route?.shortName ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hexToColor(leg.route?.textColor ?? 'ffffff'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateTimeUtils.durationToStringTime(leg.duration)} (${ItineraryLegUtils.distanceWithTranslation(leg.distance, localization)})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.dividerColor,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_right),
                  ],
                ),
              ),
            ),
            if (leg.intermediatePlaces != null &&
                leg.intermediatePlaces!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16, top: 4),
                child: IntermediatePlacesList(
                  intermediatePlaces: leg.intermediatePlaces!,
                  moveTo: moveTo,
                ),
              ),
            InkWell(
              onTap: () {
                moveTo(LatLng(leg.toPlace!.lat, leg.toPlace!.lon));
              },
              child: Text(
                leg.toPlace?.name ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IntermediatePlacesList extends StatelessWidget {
  const IntermediatePlacesList({
    required this.intermediatePlaces,
    required this.moveTo,
    super.key,
  });
  final List<PlaceEntity> intermediatePlaces;
  final Function(LatLng) moveTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Divider(height: 1, thickness: 1),
        ExpansionTile(
          visualDensity: VisualDensity.compact,
          title: Row(
            children: [
              Icon(Icons.keyboard_arrow_down, color: theme.iconTheme.color),
              const SizedBox(width: 8),
              Text('${intermediatePlaces.length} stops'),
            ],
          ),
          tilePadding: const EdgeInsets.only(right: 7),
          iconColor: Colors.transparent,
          collapsedIconColor: Colors.transparent,
          childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            ...intermediatePlaces.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 23),
                child: Material(
                  child: InkWell(
                    onTap: () {
                      moveTo(LatLng(e.stopEntity!.lat!, e.stopEntity!.lon!));
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: Text(e.stopEntity?.name ?? '')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.near_me,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}

class TransitLineSpace extends StatelessWidget {
  const TransitLineSpace({
    required this.icon,
    required this.child,
    required this.color,
    super.key,
  });
  final Widget icon;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              SizedBox(
                width: 26,
                height: 30,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(width: 18, height: 20, color: color),
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(120),
                            spreadRadius: 0.5,
                            blurRadius: 0.2,
                          ),
                        ],
                      ),
                      child: icon,
                    ),
                  ],
                ),
              ),
              Expanded(child: Container(width: 18, color: color)),
              Container(
                width: 18,
                padding: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                ),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
