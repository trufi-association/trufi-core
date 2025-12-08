import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_card.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/itinerary_details_card.dart';
import 'package:trufi_core/base/widgets/bottom_sheet/widgets/header_bottom_sheet.dart';

/// Bottom sheet widget for displaying transit route information.
///
/// Shows a list of itineraries initially, and switches to detailed view
/// when an itinerary is tapped. Use the back button to return to the list.
class TransitBottomSheet extends StatefulWidget {
  final Plan plan;
  final Itinerary? selectedItinerary;
  final void Function(Itinerary) onSelectItinerary;
  final void Function() onClose;
  final bool Function(TrufiLatLng) moveTo;

  const TransitBottomSheet({
    super.key,
    required this.plan,
    required this.selectedItinerary,
    required this.onSelectItinerary,
    required this.onClose,
    required this.moveTo,
  });

  @override
  State<TransitBottomSheet> createState() => _TransitBottomSheetState();
}

class _TransitBottomSheetState extends State<TransitBottomSheet> {
  /// Whether we're showing the details view (true) or list view (false)
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (!_showDetails)
          Column(
            children: [
              HeaderBottomSheet(onClose: widget.onClose),
              _ItineraryList(
                plan: widget.plan,
                selectedItinerary: widget.selectedItinerary,
                onSelectItinerary: (itinerary) {
                  widget.onSelectItinerary(itinerary);
                },
                onShowDetails: (itinerary) {
                  widget.onSelectItinerary(itinerary);
                  setState(() {
                    _showDetails = true;
                  });
                },
              ),
            ],
          ),
        if (_showDetails && widget.selectedItinerary != null)
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surface,
            elevation: 0,
            child: ItineraryDetailsCard(
              itinerary: widget.selectedItinerary!,
              onBackPressed: () {
                setState(() {
                  _showDetails = false;
                });
              },
              moveTo: widget.moveTo,
            ),
          ),
      ],
    );
  }
}

class _ItineraryList extends StatelessWidget {
  final Plan plan;
  final Itinerary? selectedItinerary;
  final void Function(Itinerary) onSelectItinerary;
  final void Function(Itinerary) onShowDetails;

  const _ItineraryList({
    required this.plan,
    required this.selectedItinerary,
    required this.onSelectItinerary,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final itineraries = plan.itineraries ?? [];
    return Column(
      children: [
        ...itineraries.map((itinerary) {
          return Column(
            children: [
              ItineraryCard(
                itinerary: itinerary,
                onTap: () => onShowDetails(itinerary),
              ),
            ],
          );
        }),
      ],
    );
  }
}
