import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/widgets/base_marker/from_marker.dart';
import 'package:trufi_core/widgets/base_marker/to_marker.dart';

class LocationSelectorBottomSheet extends StatelessWidget {
  final LatLng selectedLocation;
  final VoidCallback onSetAsOrigin;
  final VoidCallback onSetAsDestination;

  const LocationSelectorBottomSheet({
    super.key,
    required this.selectedLocation,
    required this.onSetAsOrigin,
    required this.onSetAsDestination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title with coordinates
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Select Location',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedLocation.latitude.toStringAsFixed(5)}, ${selectedLocation.longitude.toStringAsFixed(5)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                child: const FromMarker(height: 32),
              ),
              title: const Text('Set as Origin'),
              subtitle: const Text('Start your journey from here'),
              onTap: () {
                Navigator.pop(context);
                onSetAsOrigin();
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                child: const ToMarker(height: 32),
              ),
              title: const Text('Set as Destination'),
              subtitle: const Text('End your journey here'),
              onTap: () {
                Navigator.pop(context);
                onSetAsDestination();
              },
            ),
            
            const SizedBox(height: 8),
            
            // Cancel button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the bottom sheet and returns true if an option was selected
  static Future<void> show(
    BuildContext context, {
    required LatLng selectedLocation,
    required VoidCallback onSetAsOrigin,
    required VoidCallback onSetAsDestination,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LocationSelectorBottomSheet(
        selectedLocation: selectedLocation,
        onSetAsOrigin: onSetAsOrigin,
        onSetAsDestination: onSetAsDestination,
      ),
    );
  }
}
