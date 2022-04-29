import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'enums/defaults_location.dart';

abstract class TrufiPlace {}

class TrufiLocation implements TrufiPlace {
  final String description;
  final double latitude;
  final double longitude;
  final List<String>? alternativeNames;
  final Map<String, String>? localizedNames;
  final String? address;
  final String? type;

  TrufiLocation({
    required this.description,
    required this.latitude,
    required this.longitude,
    this.alternativeNames,
    this.localizedNames,
    this.address,
    this.type,
  });

  TrufiLocation copyWith({
    String? description,
    double? latitude,
    double? longitude,
    List<String>? alternativeNames,
    Map<String, String>? localizedNames,
    String? address,
    String? type,
  }) {
    return TrufiLocation(
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      localizedNames: localizedNames ?? this.localizedNames,
      address: address ?? this.address,
      type: type ?? this.type,
    );
  }

  factory TrufiLocation.fromChooseLocationDetail(
    LocationDetail chooseLocationDetail,
  ) {
    return TrufiLocation(
      description: chooseLocationDetail.description,
      address: chooseLocationDetail.street,
      latitude: chooseLocationDetail.position.latitude,
      longitude: chooseLocationDetail.position.longitude,
    );
  }

  factory TrufiLocation.fromLocationsJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['name'] as String,
      latitude: json['coords']['lat'] as double,
      longitude: json['coords']['lng'] as double,
    );
  }

  factory TrufiLocation.fromSearchPlacesJson(List<dynamic> json) {
    return TrufiLocation(
      description: json[0].toString(),
      alternativeNames: json[1].cast<String>() as List<String>?,
      localizedNames: json[2].cast<String, String>() as Map<String, String>?,
      longitude: json[3][0].toDouble() as double,
      latitude: json[3][1].toDouble() as double,
      address: json[4] as String?,
      type: json[5] as String?,
    );
  }

  // factory TrufiLocation.fromPlanLocation(PlanLocation value) {
  //   return TrufiLocation(
  //     description: value.name,
  //     latitude: value.latitude,
  //     longitude: value.longitude,
  //   );
  // }

  factory TrufiLocation.fromSearch(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'] as String,
      latitude: json['lat'] as double,
      longitude: json['lng'] as double,
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json["description"] as String,
      latitude: json["latitude"] as double,
      longitude: json["longitude"] as double,
      type: json["type"] as String?,
      address: json["address"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "type": type,
      "address": address ?? ''
    };
  }

  @override
  bool operator ==(Object other) =>
      other is TrufiLocation &&
      other.description == description &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.type == type;

  @override
  int get hashCode =>
      description.hashCode ^ latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return '$latitude,$longitude';
  }

  String displayName(
    SavedPlacesLocalization localization,
  ) {
    String translate = description;
    if (translate == '') {
      translate = localization.selectedOnMap;
    } else if (type == DefaultLocation.defaultHome.initLocation.type &&
        description == DefaultLocation.defaultHome.initLocation.description) {
      translate = isLatLngDefined
          ? localization.defaultLocationHome
          : localization.defaultLocationAdd(
              localization.defaultLocationHome.toLowerCase());
    } else if (type == DefaultLocation.defaultWork.initLocation.type &&
        description == DefaultLocation.defaultWork.initLocation.description) {
      translate = isLatLngDefined
          ? localization.defaultLocationWork
          : localization.defaultLocationAdd(
              localization.defaultLocationWork.toLowerCase());
    }
    return translate;
  }

  static bool sameLocations(TrufiLatLng location1, TrufiLatLng location2) {
    return location1.latitude.toStringAsFixed(2) ==
            location2.latitude.toStringAsFixed(2) &&
        location1.longitude.toStringAsFixed(2) ==
            location2.longitude.toStringAsFixed(2);
  }

  static TrufiLatLng centerLocation(
      TrufiLatLng location1, TrufiLatLng location2) {
    return TrufiLatLng(
      (location1.latitude + location2.latitude) / 2,
      (location1.longitude + location2.longitude) / 2,
    );
  }

  bool get isLatLngDefined {
    return latitude != 0 && longitude != 0;
  }

  TrufiLatLng get latLng {
    return TrufiLatLng(latitude, longitude);
  }
}

class TrufiStreet implements TrufiPlace {
  TrufiStreet({required this.location});

  final TrufiLocation location;
  final List<TrufiStreetJunction> junctions = [];

  factory TrufiStreet.fromSearchJson(List<dynamic> json) {
    return TrufiStreet(
      location: TrufiLocation(
        description: json[0] as String,
        alternativeNames: json[1].cast<String>() as List<String>,
        longitude: json[2][0].toDouble() as double,
        latitude: json[2][1].toDouble() as double,
      ),
    );
  }

  String get description => location.description;

  String displayName(SavedPlacesLocalization localization) =>
      location.displayName(localization);
}

class TrufiStreetJunction {
  TrufiStreetJunction({
    required this.street1,
    required this.street2,
    required this.latitude,
    required this.longitude,
  });

  final TrufiStreet street1;
  final TrufiStreet street2;
  final double latitude;
  final double longitude;

  String get description {
    return '${street1.location.description} & ${street2.location.description}';
  }

  String displayName(SavedPlacesLocalization localization) =>
      localization.instructionJunction(
        street1.location.displayName(localization),
        street2.location.displayName(localization),
      );

  TrufiLocation location(SavedPlacesLocalization localization) {
    return TrufiLocation(
      description: displayName(localization),
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class LevenshteinObject<T> {
  LevenshteinObject(this.object, this.distance);

  final T object;
  final int distance;
}

class LocationDetail {
  final String description;
  final String street;
  final TrufiLatLng position;

  LocationDetail(this.description, this.street, this.position);
}
