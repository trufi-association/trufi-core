import 'package:flutter/material.dart';

typedef LocalizedStringBuilder = String Function(BuildContext context);

/// A single price entry within a fare group (e.g., "Adulto: 3.00 Bs").
///
/// Apps provide already-localized labels. The package intentionally avoids
/// hardcoding category names like "student" or "senior" so each deployment
/// can model its own tariff structure (general, primary student, secondary
/// student, disability, senior, employee, etc.).
class FareCategory {
  /// Display label, already localized by the consumer.
  final String label;

  /// Optional localized label builder used when a [BuildContext] exists.
  final LocalizedStringBuilder? labelBuilder;

  /// Formatted price string without currency (e.g., `"3.00"`).
  final String price;

  /// Optional category icon. Renders a generic person icon when null.
  final IconData? icon;

  /// Optional accent color for the category chip.
  final Color? color;

  /// Optional sub-note shown under the price (e.g., promotional period).
  final String? note;

  const FareCategory({
    required this.label,
    required this.price,
    this.icon,
    this.color,
    this.note,
    this.labelBuilder,
  });

  /// Localized label when a [BuildContext] exists; mirrors the
  /// `localized*` convention of `ITrufiMapEngine`/`IRoutingProvider`.
  String localizedLabel(BuildContext context) =>
      labelBuilder?.call(context) ?? label;
}

/// A fare grouping rendered as a single card on the fares screen.
///
/// Models a transport mode (e.g., "Trufi"), a tariff regime (e.g., "Pasaje
/// urbano (Cercado)"), or any other grouping. The [primary] category is
/// rendered as a headline price badge in the card header; [additional]
/// categories render as chips below.
class FareInfo {
  /// Group title shown in the card header.
  final String title;

  /// Optional localized title builder used when a [BuildContext] exists.
  final LocalizedStringBuilder? titleBuilder;

  /// Icon shown next to [title].
  final IconData icon;

  /// Optional accent color; defaults to the theme's primary color.
  final Color? color;

  /// Headline category — its price appears as a badge in the header.
  final FareCategory primary;

  /// Additional categories rendered as chips below the header.
  final List<FareCategory> additional;

  /// Long-form notes shown at the bottom of the card.
  final String? notes;

  const FareInfo({
    required this.title,
    required this.icon,
    required this.primary,
    this.color,
    this.additional = const [],
    this.notes,
    this.titleBuilder,
  });

  /// Localized title when a [BuildContext] exists; mirrors the
  /// `localized*` convention of `ITrufiMapEngine`/`IRoutingProvider`.
  String localizedTitle(BuildContext context) =>
      titleBuilder?.call(context) ?? title;
}

/// Top-level configuration for the fares screen.
class FaresConfig {
  /// Currency symbol prepended to every price (e.g., `"Bs."`, `"$"`).
  final String currency;

  /// Fare groups to render, in display order.
  final List<FareInfo> fares;

  /// URL launched when the "More info" button is tapped.
  final String? externalFareUrl;

  /// When the fare data was last verified.
  final DateTime? lastUpdated;

  /// Free-form notes shown at the bottom of the screen.
  final String? additionalNotes;

  const FaresConfig({
    required this.currency,
    required this.fares,
    this.externalFareUrl,
    this.lastUpdated,
    this.additionalNotes,
  });
}
