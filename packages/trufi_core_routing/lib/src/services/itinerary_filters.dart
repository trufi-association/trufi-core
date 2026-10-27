import '../models/itinerary.dart';

/// Drops itineraries that ride more than [maxTransitLegs] vehicles.
///
/// Product rule (Sam, 2026-08-12, #737): a trip should take at most two
/// buses — chains like `18 → 120 → 50` are not something a rider will
/// actually do, and providers without server-side filtering (OTP 1.5/2.4)
/// return plenty of them. Walk/bike legs don't count.
///
/// Fail-open on transit: when the cap would leave no transit option at all
/// (nothing survives, or only walk/bike rows do), the original list is
/// returned unchanged — in a city where two vehicles genuinely can't cover
/// the trip, showing long chains beats a lone "walk 4 km" row or "no
/// routes found".
List<Itinerary> filterMaxTransitLegs(
  List<Itinerary> itineraries, {
  int maxTransitLegs = 2,
}) {
  bool ridesTransit(Itinerary it) => it.legs.any((l) => l.transitLeg);

  final kept = itineraries
      .where((it) => it.legs.where((l) => l.transitLeg).length <= maxTransitLegs)
      .toList(growable: false);

  final droppedAllTransit =
      itineraries.any(ridesTransit) && !kept.any(ridesTransit);
  return kept.isEmpty || droppedAllTransit ? itineraries : kept;
}
