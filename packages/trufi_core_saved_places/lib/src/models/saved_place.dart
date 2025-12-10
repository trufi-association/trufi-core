import 'package:equatable/equatable.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Types of saved places
enum SavedPlaceType {
  home,
  work,
  other,
  history,
}

/// A saved place with additional metadata for display and storage.
class SavedPlace extends Equatable {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final SavedPlaceType type;
  final String? iconName;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const SavedPlace({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.iconName,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Creates a SavedPlace from a TrufiLocation
  factory SavedPlace.fromTrufiLocation(
    TrufiLocation location, {
    required SavedPlaceType type,
    String? iconName,
  }) {
    return SavedPlace(
      id: '${location.latitude}_${location.longitude}_${DateTime.now().millisecondsSinceEpoch}',
      name: location.description,
      address: location.address,
      latitude: location.latitude,
      longitude: location.longitude,
      type: type,
      iconName: iconName,
      createdAt: DateTime.now(),
    );
  }

  /// Converts this SavedPlace to a TrufiLocation
  TrufiLocation toTrufiLocation() {
    return TrufiLocation(
      description: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      type: _getLocationType(),
    );
  }

  String _getLocationType() {
    switch (type) {
      case SavedPlaceType.home:
        return 'saved_place:home';
      case SavedPlaceType.work:
        return 'saved_place:work';
      case SavedPlaceType.other:
        return 'saved_place:other';
      case SavedPlaceType.history:
        return 'saved_place:history';
    }
  }

  SavedPlace copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    SavedPlaceType? type,
    String? iconName,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return SavedPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      type: SavedPlaceType.values.firstWhere(
        (e) => e.name == json['type'] || (json['type'] == 'favorite' && e == SavedPlaceType.other) || (json['type'] == 'others' && e == SavedPlaceType.other),
        orElse: () => SavedPlaceType.other,
      ),
      iconName: json['iconName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.name,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        type,
        iconName,
        createdAt,
        lastUsedAt,
      ];
}
