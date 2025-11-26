import 'package:latlong2/latlong.dart';
import 'package:trufi_core/localization/app_localization.dart';
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

  static final Map<DefaultLocationEnum, LocalizationKey> _l10n = {
    DefaultLocationEnum.home: LocalizationKey.defaultLocationHome,
    DefaultLocationEnum.work: LocalizationKey.defaultLocationWork,
  };

  static final Map<DefaultLocationEnum, TrufiLocation> _init = {
    for (final e in DefaultLocationEnum.values)
      e: TrufiLocation(
        description: _keys[e]!,
        position: const LatLng(0, 0),
        type: TrufiLocationType.fromString(_types[e]!),
      ),
  };

  String get key => _keys[this]!;
  String get type => _types[this]!;
  LocalizationKey get l10nKey => _l10n[this]!;
  TrufiLocation get initLocation => _init[this]!;

  static DefaultLocationEnum? detect(TrufiLocation loc) {
    for (final e in DefaultLocationEnum.values) {
      if (loc.type.value == e.type && loc.description == e.initLocation.description) {
        return e;
      }
    }
    return null;
  }
}
