import 'package:hive/hive.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

enum CityInstance {
  zitacuaro,
  zamora,
  uruapan,
  salinaCruz,
  oaxaca,
  toluca,
  jilotepec,
  puertoEscondido,
}

extension CityInstanceExtension on CityInstance {
  static final Map<CityInstance, String> _toValueMap = {
    CityInstance.zitacuaro: 'zitacuaro',
    CityInstance.zamora: 'zamora',
    CityInstance.uruapan: 'uruapan',
    CityInstance.oaxaca: 'oaxaca',
    CityInstance.toluca: 'toluca',
    CityInstance.salinaCruz: 'salinaCruz',
    CityInstance.jilotepec: 'jilotepec',
    CityInstance.puertoEscondido: 'puertoEscondido',
  };
  static final Map<CityInstance, String> _oficialText = {
    CityInstance.zitacuaro: 'Zitácuaro',
    CityInstance.zamora: 'Zamora',
    CityInstance.uruapan: 'Uruapan',
    CityInstance.oaxaca: 'Oaxaca',
    CityInstance.toluca: 'Toluca',
    CityInstance.salinaCruz: 'Salina Cruz',
    CityInstance.jilotepec: 'Jilotepec',
    CityInstance.puertoEscondido: 'Puerto Escondido',
  };

  static final Map<String, CityInstance> _fromValueMap = _toValueMap.map(
    (key, value) => MapEntry(value, key),
  );

  static final otpEndpointValues = <CityInstance, String>{
    CityInstance.zitacuaro: "https://rutometro.trufi.dev/otp",
    CityInstance.zamora: "https://rutometro.trufi.dev/zamora/otp",
    CityInstance.uruapan: "https://rutometro.trufi.dev/uruapan/otp",
    CityInstance.oaxaca:
        "https://2-4-0.otp.oaxaca.trufi.dev/otp/routers/default",
    CityInstance.toluca: "https://otp.toluca.trufi.dev/otp/routers/default",
    CityInstance.salinaCruz:
        "https://otp.salinacruz.trufi.dev/otp/routers/default",
    CityInstance.jilotepec:
        "https://otp.jilotepec.trufi.dev/otp/routers/default",
    CityInstance.puertoEscondido:
        "https://otp.puertoescondido.trufi.dev/otp/routers/default",
  };

  static final otpGraphqlEndpointValues = <CityInstance, String>{
    CityInstance.zitacuaro: "https://rutometro.trufi.dev/otp/index/graphql",
    CityInstance.zamora: "https://rutometro.trufi.dev/zamora/otp/index/graphql",
    CityInstance.uruapan:
        "https://rutometro.trufi.dev/uruapan/otp/index/graphql",
    CityInstance.oaxaca:
        "https://2-4-0.otp.oaxaca.trufi.dev/otp/routers/default/index/graphql",
    CityInstance.toluca:
        "https://otp.toluca.trufi.dev/otp/routers/default/index/graphql",
    CityInstance.salinaCruz:
        "https://otp.salinacruz.trufi.dev/otp/routers/default/index/graphql",
    CityInstance.jilotepec:
        "https://otp.jilotepec.trufi.dev/otp/routers/default/index/graphql",
    CityInstance.puertoEscondido:
        "https://otp.puertoescondido.trufi.dev/otp/routers/default/index/graphql",
  };

  static final _bboxValues = <CityInstance, List<double>>{
    CityInstance.zitacuaro: [-100.477837, 19.201667, -100.211988, 19.545306],
    CityInstance.zamora: [-102.50253, 19.920427, -102.1755, 20.106905],
    CityInstance.uruapan: [-102.108526, 19.337806, -101.99688, 19.50949],
    CityInstance.oaxaca: [ -96.777, 17.022, -96.668, 17.113 ],
    CityInstance.toluca: [-99.900696, 18.712811, -99.210725, 19.648171],
    CityInstance.salinaCruz: [-95.229601, 16.157866, -95.156508, 16.246881],
    CityInstance.jilotepec: [-99.703615, 19.849161, -99.436664, 20.171306],
    CityInstance.puertoEscondido: [-97.119519, 15.830408, -97.034392, 15.937529],
  };

  static final centerValues = <CityInstance, TrufiLatLng>{
    CityInstance.zitacuaro: TrufiLatLng(19.4323039, -100.3554035),
    CityInstance.zamora: TrufiLatLng(19.9807, -102.2835),
    CityInstance.uruapan: TrufiLatLng(19.4136, -102.0565),
    CityInstance.oaxaca: TrufiLatLng(17.065, -96.721),
    CityInstance.toluca: TrufiLatLng(19.288, -99.666),
    CityInstance.salinaCruz: TrufiLatLng(16.184, -95.201),
    CityInstance.jilotepec: TrufiLatLng(19.95194, -99.53278),
    CityInstance.puertoEscondido: TrufiLatLng(15.8700, -97.0770),
  };

  static final splashScreenAssets = <CityInstance, String>{
    CityInstance.zitacuaro:
        "assets/images/splash-screens/splash-screen-zitacuaro.png",
    CityInstance.zamora:
        "assets/images/splash-screens/splash-screen-zamora.png",
    CityInstance.uruapan:
        "assets/images/splash-screens/splash-screen-uruapan.png",
    CityInstance.oaxaca:
        "assets/images/splash-screens/splash-screen-oaxaca.png",
    CityInstance.toluca:
        "assets/images/splash-screens/splash-screen-toluca.png",
    CityInstance.salinaCruz:
        "assets/images/splash-screens/splash-screen-salinaCruz.png",
    CityInstance.jilotepec:
        "assets/images/splash-screens/splash-screen-jilotepec.png",
    CityInstance.puertoEscondido:
        "assets/images/splash-screens/splash-screen-puertoEscondido.png",
  };

  String toValue() => _toValueMap[this]!;

  static CityInstance? fromValue(String? value) => _fromValueMap[value];

  String get otpEndpoint => otpEndpointValues[this]!;
  String get otpGraphqlEndpoint => otpGraphqlEndpointValues[this]!;
  List<double> get bbox => _bboxValues[this]!;
  String get bboxString => _bboxValues[this]!.join(',');
  TrufiLatLng get center => centerValues[this]!;
  String get getText => _oficialText[this]!;
  String get getSplashScreenAsset => splashScreenAssets[this]!;

  bool contains(TrufiLatLng point) {
    final corners = bbox;
    final sw = LatLng(corners[1], corners[0]);
    final ne = LatLng(corners[3], corners[2]);
    final bounds = LatLngBounds(sw, ne);
    return bounds.contains(point.toLatLng());
  }
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

    currentCity;
  }

  Future<CityInstance?> get getCityInstance async =>
      await _localRepository.getCityInstance();

  Future<bool> detectAndAssignCityByLocation(TrufiLatLng location) async {
    final city = detectCityByLocation(location);
    if (city != null) {
      await assignCity(city);
      return true;
    }
    return false;
  }

  CityInstance? detectCityByLocation(TrufiLatLng location) {
    for (final city in CityInstance.values) {
      if (city.contains(location)) {
        return city;
      }
    }
    return null;
  }

  Future<void> assignCity(CityInstance city) async {
    currentCity = city;
    await _localRepository.saveCityInstance(city);
  }
}

class CitySelectionManagerHiveLocalRepository {
  static const String path = "CitySelectionManagerHiveLocalRepository";
  static const String _cityInstanceKey = 'cityInstanceKey';

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
