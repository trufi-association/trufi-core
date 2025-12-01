import '../trufi_place.dart';

enum DefaultLocation {
  defaultHome,
  defaultWork,
}

extension DefaultLocationExtension on DefaultLocation {
  static final initLocations = <DefaultLocation, TrufiLocation>{
    DefaultLocation.defaultHome: TrufiLocation(
      description: keys[DefaultLocation.defaultHome] ?? 'ErrorDefaultLocation',
      latitude: 0,
      longitude: 0,
      type: 'saved_place:home',
    ),
    DefaultLocation.defaultWork: TrufiLocation(
      description: keys[DefaultLocation.defaultWork] ?? 'ErrorDefaultLocation',
      latitude: 0,
      longitude: 0,
      type: 'saved_place:work',
    ),
  };

  static final keys = <DefaultLocation, String>{
    DefaultLocation.defaultHome: 'Key-Default-Home',
    DefaultLocation.defaultWork: 'Key-Default-Work'
  };

  TrufiLocation get initLocation =>
      initLocations[this] ??
      TrufiLocation(
        description: keyLocation,
        latitude: 0,
        longitude: 0,
        type: 'saved_place:work',
      );

  String get keyLocation => keys[this] ?? 'Key-Default-Home';
}
