import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/bike_feature_model.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/images.dart';

class BikeMarkerModal extends StatelessWidget {
  final BikeParkFeature bikeParkFeature;
  const BikeMarkerModal({super.key, required this.bikeParkFeature});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: bikeParkMarkerIcons[bikeParkFeature.type],
              ),
              Expanded(
                child: Text(
                  "Bicycle Parking",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (bikeParkFeature.bicyclePlacesCapacity != null)
                Text(
                  "${bikeParkFeature.bicyclePlacesCapacity} ${languageCode == 'en' ? 'parking spaces' : 'Stellplätze'}",
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
