// Basic smoke test for trufi_core_poi_layers example
//
// Note: Full widget tests for the example app are not practical because
// it requires network access for map tiles and asset loading for GeoJSON.
// This test only verifies that the basic widgets can be instantiated.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

/// Test category configuration for tests
final testFoodCategory = POICategoryConfig(
  name: 'food',
  displayName: 'Food & Drink',
  count: 100,
  color: const Color(0xFFE65100),
  weight: 2,
  subcategories: [
    const POISubcategoryConfig(
      name: 'restaurant',
      displayName: 'Restaurants',
      count: 50,
      color: Color(0xFFFF5722),
    ),
    const POISubcategoryConfig(
      name: 'cafe',
      displayName: 'Cafes',
      count: 30,
      color: Color(0xFF795548),
    ),
  ],
);

void main() {
  testWidgets('POIDetailPanel renders correctly', (WidgetTester tester) async {
    final testPOI = POI(
      id: 'test-1',
      name: 'Test POI',
      position: const LatLng(-17.3895, -66.1568),
      category: testFoodCategory,
      subcategory: 'restaurant',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: POILayersLocalizations.localizationsDelegates,
        supportedLocales: POILayersLocalizations.supportedLocales,
        home: Scaffold(
          body: POIDetailPanel(
            poi: testPOI,
            onClose: () {},
          ),
        ),
      ),
    );

    // Verify the POI name is displayed
    expect(find.text('Test POI'), findsOneWidget);
    // Verify close button exists
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('POISelectionSheet renders correctly',
      (WidgetTester tester) async {
    final testPOIs = [
      POI(
        id: 'test-1',
        name: 'Restaurant A',
        position: const LatLng(-17.3895, -66.1568),
        category: testFoodCategory,
        subcategory: 'restaurant',
      ),
      POI(
        id: 'test-2',
        name: 'Cafe B',
        position: const LatLng(-17.3896, -66.1569),
        category: testFoodCategory,
        subcategory: 'cafe',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: POILayersLocalizations.localizationsDelegates,
        supportedLocales: POILayersLocalizations.supportedLocales,
        home: Scaffold(
          body: POISelectionSheet(
            pois: testPOIs,
            onPOISelected: (_) {},
          ),
        ),
      ),
    );

    // Verify both POIs are displayed
    expect(find.text('Restaurant A'), findsOneWidget);
    expect(find.text('Cafe B'), findsOneWidget);
  });
}
