import 'package:latlong2/latlong.dart';
import 'package:tr_translations/trufi_localizations.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

enum DefaultLocationEnum { home, work }

extension DefaultLocationExt on DefaultLocationEnum {
  static final Map<DefaultLocationEnum, String> _keys = {
    DefaultLocationEnum.home: 'Key-Default-Home',
    DefaultLocationEnum.work: 'Key-Default-Work',
  };

  static final Map<DefaultLocationEnum, String> _types = {
    DefaultLocationEnum.home: 'saved_place:home',
    DefaultLocationEnum.work: 'saved_place:work',
  };

  static final Map<DefaultLocationEnum, TrufiLocation> _init = {
    for (final e in DefaultLocationEnum.values)
      e: TrufiLocation(
        description: _keys[e]!,
        position: const LatLng(0, 0),
        type: TrufiLocationType.fromString(_types[e]),
      ),
  };

  String get key => _keys[this]!;
  String get type => _types[this]!;
  TrufiLocation get initLocation => _init[this]!;

  String getLocalizedName(TrufiLocalizations localization) {
    switch (this) {
      case DefaultLocationEnum.home:
        return localization.defaultLocationHome;
      case DefaultLocationEnum.work:
        return localization.defaultLocationWork;
    }
  }

  static DefaultLocationEnum? detect(TrufiLocation loc) {
    for (final e in DefaultLocationEnum.values) {
      if (loc.type.value == e.type &&
          loc.description == e.initLocation.description) {
        return e;
      }
    }
    return null;
  }
}
