import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/header_bottom_sheet.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/travel_mode_section.dart/transit_mode_section/itinarary_details_card/itinarary_details_card.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/travel_mode_section.dart/transit_mode_section/transit_mode_section.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class TransitBottomSheet extends StatelessWidget {
  final void Function(PlanItinerary?) onSelectItinerary;
  final void Function() onClose;
  final bool Function({
    latlng.LatLng? target,
    double? zoom,
    double? bearing,
    LatLngBounds? visibleRegion,
  })
  updateCamera;

  final PlanEntity plan;
  final PlanItinerary? selectedItinerary;
  const TransitBottomSheet({
    super.key,
    required this.onSelectItinerary,
    required this.plan,
    required this.selectedItinerary,
    required this.updateCamera,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        if (selectedItinerary == null)
          Column(
            children: [
              HeaderBottomSheet(onClose: onClose),
              TransitModeSection(
                plan: plan,
                onSelectItinerary: onSelectItinerary,
              ),
            ],
          ),
        if (selectedItinerary != null)
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surface,
            elevation: 0,
            child: ItineraryDetailsCard(
              plan: plan,
              itinerary: selectedItinerary!,
              updateCamera: updateCamera,
              onRouteDetailsViewChanged: (value) {
                onSelectItinerary.call(null);
              },
            ),
          ),
      ],
    );
  }
}
