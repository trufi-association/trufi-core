import 'package:flutter/material.dart';

import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class LegOverview extends StatelessWidget {
  static const _paddingHeight = 20.0;
  final PlanItinerary itinerary;
  final AdEntity ad;
  const LegOverview({
    Key key,
    @required this.itinerary,
    @required this.ad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: _paddingHeight / 2,
        bottom: _paddingHeight / 2,
        left: 10.0,
        right: 32.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (ad != null && index >= itinerary.legs.length) {
          return Row(
            children: <Widget>[
              Icon(Icons.sentiment_very_satisfied,
                  color: Theme.of(context).colorScheme.secondary),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      text: ad.text,
                      style: theme.primaryTextTheme.bodyText1,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final leg = itinerary.legs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: <Widget>[
              Icon(
                leg.iconData,
                color: leg.transportMode == TransportMode.walk
                    ? Colors.white
                    : leg.transportMode.color,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                        text: leg.toInstruction(localization),
                        style: theme.primaryTextTheme.bodyText1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: itinerary.legs.length + (ad != null ? 1 : 0),
    );
  }
}
