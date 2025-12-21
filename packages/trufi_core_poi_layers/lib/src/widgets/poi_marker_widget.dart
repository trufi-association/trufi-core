import 'package:flutter/material.dart';

import '../data/models/poi.dart';
import '../data/models/poi_category.dart';

/// Widget for displaying a POI marker on the map
class POIMarkerWidget extends StatelessWidget {
  final POI poi;
  final double size;

  const POIMarkerWidget({
    super.key,
    required this.poi,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: poi.category.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        poi.type.icon,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}

/// Small dot marker for when there are many POIs
class POIMarkerDot extends StatelessWidget {
  final POICategory category;
  final double size;

  const POIMarkerDot({
    super.key,
    required this.category,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
