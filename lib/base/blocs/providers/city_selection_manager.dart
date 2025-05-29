import 'package:hive/hive.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

enum CityInstance {
  zitacuaro,
  zamora,
  uruapan,
  oaxaca,
}

extension CityInstanceExtension on CityInstance {
  static final Map<CityInstance, String> _toValueMap = {
    CityInstance.zitacuaro: 'zitacuaro',
    CityInstance.zamora: 'zamora',
    CityInstance.uruapan: 'uruapan',
    CityInstance.oaxaca: 'oaxaca',
  };

  static final Map<String, CityInstance> _fromValueMap = _toValueMap.map(
    (key, value) => MapEntry(value, key),
  );

  static final otpEndpointValues = <CityInstance, String>{
    CityInstance.zitacuaro: "https://rutometro.trufi.dev/otp",
    CityInstance.zamora: "https://rutometro.trufi.dev/zamora/otp",
    CityInstance.uruapan: "https://rutometro.trufi.dev/uruapan/otp",
    CityInstance.oaxaca: "https://2-4-0.otp.oaxaca.trufi.dev/otp/routers/default",
  };

  static final bboxValues = <CityInstance, String>{
    CityInstance.zitacuaro: "-100.477837,19.201667,-100.211988,19.545306",
    CityInstance.zamora: "-102.50253,19.920427,-102.1755,20.106905",
    CityInstance.uruapan: "-102.108526,19.337806,-101.99688,19.50949",
    CityInstance.oaxaca: "-98.552707,15.657169,-93.867427,18.669688",
  };

  static final centerValues = <CityInstance, TrufiLatLng>{
    CityInstance.zitacuaro: TrufiLatLng(19.4323039, -100.3554035),
    CityInstance.zamora: TrufiLatLng(19.9807, -102.2835),
    CityInstance.uruapan: TrufiLatLng(19.4136, -102.0565),
    CityInstance.oaxaca: TrufiLatLng(17.065, -96.721),
  };

  String toValue() => _toValueMap[this]!;

  static CityInstance? fromValue(String? value) => _fromValueMap[value];

  String get otpEndpoint => otpEndpointValues[this]!;
  String get bbox => bboxValues[this]!;
  TrufiLatLng get center => centerValues[this]!;
}

class CitySelectionManager {
  final _localRepository = CitySelectionManagerHiveLocalRepository();

  // Private constructor
  CitySelectionManager._privateConstructor();

  // The static instance of the class
  static final CitySelectionManager _instance =
      CitySelectionManager._privateConstructor();

  // Factory constructor to return the same instance
  factory CitySelectionManager() {
    return _instance;
  }

  CityInstance currentCity = CityInstance.zitacuaro;

  Future<void> loadData() async {
    currentCity =
        (await _localRepository.getCityInstance()) ?? CityInstance.zitacuaro;
  }

  void assignNextCity() {
    final cities = CityInstance.values;
    final currentIndex = cities.indexOf(currentCity);
    final nextIndex =
        (currentIndex + 1) % cities.length; // Loop back to the first city
    currentCity = cities[nextIndex];
    _localRepository.saveCityInstance(cities[nextIndex]);
  }
}

class CitySelectionManagerHiveLocalRepository {
  static const String path = "CitySelectionManagerHiveLocalRepository";
  static const String _cityInstanceKey = '_cityInstanceKey';

  late Box _box;
  CitySelectionManagerHiveLocalRepository() {
    _box = Hive.box(path);
  }

  Future<CityInstance?> getCityInstance() async {
    return CityInstanceExtension.fromValue(_box.get(_cityInstanceKey));
  }

  Future<void> saveCityInstance(CityInstance data) async {
    await _box.put(_cityInstanceKey, data.toValue());
  }
}
