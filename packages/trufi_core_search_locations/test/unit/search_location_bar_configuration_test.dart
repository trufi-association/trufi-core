import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/src/models/search_location_bar_configuration.dart';

/// Unit tests for SearchLocationBarConfiguration model.
void main() {
  group('SearchLocationBarConfiguration', () {
    test('creates instance with default values', () {
      const config = SearchLocationBarConfiguration();

      expect(config.originHintText, 'Select origin');
      expect(config.destinationHintText, 'Select destination');
      expect(config.originLeadingWidget, isNull);
      expect(config.destinationLeadingWidget, isNull);
      expect(
        config.fieldBorderRadius,
        const BorderRadius.all(Radius.circular(8.0)),
      );
      expect(config.fieldHeight, 36.0);
      expect(config.padding, const EdgeInsets.all(5.0));
    });

    test('creates instance with custom values', () {
      const customBorderRadius = BorderRadius.all(Radius.circular(16.0));
      const customPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
      const originWidget = Icon(Icons.location_on);
      const destWidget = Icon(Icons.flag);

      const config = SearchLocationBarConfiguration(
        originHintText: 'From',
        destinationHintText: 'To',
        originLeadingWidget: originWidget,
        destinationLeadingWidget: destWidget,
        fieldBorderRadius: customBorderRadius,
        fieldHeight: 48.0,
        padding: customPadding,
      );

      expect(config.originHintText, 'From');
      expect(config.destinationHintText, 'To');
      expect(config.originLeadingWidget, originWidget);
      expect(config.destinationLeadingWidget, destWidget);
      expect(config.fieldBorderRadius, customBorderRadius);
      expect(config.fieldHeight, 48.0);
      expect(config.padding, customPadding);
    });

    test('can create with partial custom values', () {
      const config = SearchLocationBarConfiguration(
        originHintText: 'Custom Origin',
        fieldHeight: 50.0,
      );

      expect(config.originHintText, 'Custom Origin');
      expect(config.destinationHintText, 'Select destination');
      expect(config.fieldHeight, 50.0);
      expect(config.padding, const EdgeInsets.all(5.0));
    });
  });
}
