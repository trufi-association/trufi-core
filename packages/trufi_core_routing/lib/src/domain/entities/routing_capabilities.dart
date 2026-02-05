import 'package:equatable/equatable.dart';

/// Defines what routing preferences/options a provider supports.
///
/// Each routing provider has different capabilities based on its backend:
/// - OTP 2.x (GraphQL): Full feature set including wheelchair, bike options
/// - OTP 1.5 (REST): Most features but with different API
/// - GTFS Offline: Limited to maxWalkDistance only
///
/// UI should adapt based on these capabilities to show only relevant options.
class RoutingCapabilities extends Equatable {
  /// Whether the provider supports wheelchair accessibility filtering.
  final bool supportsWheelchair;

  /// Whether the provider supports walk speed configuration.
  final bool supportsWalkSpeed;

  /// Whether the provider supports max walking distance.
  final bool supportsMaxWalkDistance;

  /// Whether the provider supports walk reluctance (preference to avoid walking).
  final bool supportsWalkReluctance;

  /// Whether the provider supports bicycle routing.
  final bool supportsBicycle;

  /// Whether the provider supports bike speed configuration.
  final bool supportsBikeSpeed;

  /// Whether the provider supports bike triangle optimization
  /// (safety vs speed vs flat).
  final bool supportsBikeTriangle;

  /// Whether the provider supports car routing.
  final bool supportsCar;

  /// Whether the provider supports departure/arrival time selection.
  final bool supportsTimeSelection;

  /// Whether the provider supports multiple transport mode selection.
  final bool supportsTransportModes;

  /// Whether the provider supports maximum transfers setting.
  final bool supportsMaxTransfers;

  /// Whether the provider supports minimum transfer time.
  final bool supportsMinTransferTime;

  /// Whether the provider supports search window/range configuration.
  final bool supportsSearchWindow;

  const RoutingCapabilities({
    this.supportsWheelchair = false,
    this.supportsWalkSpeed = false,
    this.supportsMaxWalkDistance = false,
    this.supportsWalkReluctance = false,
    this.supportsBicycle = false,
    this.supportsBikeSpeed = false,
    this.supportsBikeTriangle = false,
    this.supportsCar = false,
    this.supportsTimeSelection = false,
    this.supportsTransportModes = false,
    this.supportsMaxTransfers = false,
    this.supportsMinTransferTime = false,
    this.supportsSearchWindow = false,
  });

  /// Full capabilities - all features supported (typical for OTP 2.x).
  static const full = RoutingCapabilities(
    supportsWheelchair: true,
    supportsWalkSpeed: true,
    supportsMaxWalkDistance: true,
    supportsWalkReluctance: true,
    supportsBicycle: true,
    supportsBikeSpeed: true,
    supportsBikeTriangle: true,
    supportsCar: true,
    supportsTimeSelection: true,
    supportsTransportModes: true,
    supportsMaxTransfers: true,
    supportsMinTransferTime: true,
    supportsSearchWindow: true,
  );

  /// OTP 2.8 capabilities (GraphQL API).
  static const otp28 = RoutingCapabilities(
    supportsWheelchair: true,
    supportsWalkSpeed: true,
    supportsMaxWalkDistance: true,
    supportsWalkReluctance: true,
    supportsBicycle: true,
    supportsBikeSpeed: true,
    supportsBikeTriangle: true,
    supportsCar: true,
    supportsTimeSelection: true,
    supportsTransportModes: true,
    supportsMaxTransfers: true,
    supportsMinTransferTime: true,
    supportsSearchWindow: true,
  );

  /// OTP 2.4 capabilities (GraphQL API).
  static const otp24 = RoutingCapabilities(
    supportsWheelchair: true,
    supportsWalkSpeed: true,
    supportsMaxWalkDistance: true,
    supportsWalkReluctance: true,
    supportsBicycle: true,
    supportsBikeSpeed: true,
    supportsBikeTriangle: true,
    supportsCar: true,
    supportsTimeSelection: true,
    supportsTransportModes: true,
    supportsMaxTransfers: true,
    supportsMinTransferTime: true,
    supportsSearchWindow: false, // Not available in 2.4
  );

  /// OTP 1.5 capabilities (REST API).
  static const otp15 = RoutingCapabilities(
    supportsWheelchair: true,
    supportsWalkSpeed: true,
    supportsMaxWalkDistance: true,
    supportsWalkReluctance: true,
    supportsBicycle: true,
    supportsBikeSpeed: true,
    supportsBikeTriangle: true,
    supportsCar: true,
    supportsTimeSelection: true,
    supportsTransportModes: true,
    supportsMaxTransfers: true,
    supportsMinTransferTime: false,
    supportsSearchWindow: false,
  );

  /// GTFS offline capabilities - very limited.
  static const gtfsOffline = RoutingCapabilities(
    supportsWheelchair: false,
    supportsWalkSpeed: false,
    supportsMaxWalkDistance: true,
    supportsWalkReluctance: false,
    supportsBicycle: false,
    supportsBikeSpeed: false,
    supportsBikeTriangle: false,
    supportsCar: false,
    supportsTimeSelection: false, // GTFS schedules are static
    supportsTransportModes: false, // Transit + walk only
    supportsMaxTransfers: false,
    supportsMinTransferTime: false,
    supportsSearchWindow: false,
  );

  /// No capabilities - provider doesn't support any preferences.
  static const none = RoutingCapabilities();

  /// Returns true if any walking-related preference is supported.
  bool get hasWalkingOptions =>
      supportsWalkSpeed || supportsMaxWalkDistance || supportsWalkReluctance;

  /// Returns true if any bicycle-related preference is supported.
  bool get hasBicycleOptions =>
      supportsBicycle || supportsBikeSpeed || supportsBikeTriangle;

  /// Returns true if any time-related preference is supported.
  bool get hasTimeOptions => supportsTimeSelection;

  /// Returns true if any accessibility option is supported.
  bool get hasAccessibilityOptions => supportsWheelchair;

  /// Returns true if the provider has any configurable options.
  bool get hasAnyOptions =>
      supportsWheelchair ||
      supportsWalkSpeed ||
      supportsMaxWalkDistance ||
      supportsWalkReluctance ||
      supportsBicycle ||
      supportsBikeSpeed ||
      supportsBikeTriangle ||
      supportsCar ||
      supportsTimeSelection ||
      supportsTransportModes ||
      supportsMaxTransfers ||
      supportsMinTransferTime ||
      supportsSearchWindow;

  @override
  List<Object?> get props => [
        supportsWheelchair,
        supportsWalkSpeed,
        supportsMaxWalkDistance,
        supportsWalkReluctance,
        supportsBicycle,
        supportsBikeSpeed,
        supportsBikeTriangle,
        supportsCar,
        supportsTimeSelection,
        supportsTransportModes,
        supportsMaxTransfers,
        supportsMinTransferTime,
        supportsSearchWindow,
      ];
}
