import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/models/citybikes_icon.dart';

enum CityBikeLayerIds { carSharing, cargoBike, regiorad, taxi, scooter }

CityBikeLayerIds cityBikeLayerIdStringToEnum(String id) {
  return CityBikeLayerIdsExtension.names.keys.firstWhere(
    (keyE) => keyE.name == id,
    orElse: () {
      switch (id) {
        case "de.mfdz.flinkster.cab.regiorad_stuttgart":
          return CityBikeLayerIds.regiorad;
        case "de.openbikebox.stadt-herrenberg":
          return CityBikeLayerIds.cargoBike;
        default:
          return CityBikeLayerIds.carSharing;
      }
    },
  );
}

extension CityBikeLayerIdsExtension on CityBikeLayerIds {
  static const names = <CityBikeLayerIds, String>{
    CityBikeLayerIds.taxi: 'taxi',
    CityBikeLayerIds.cargoBike: 'cargo-bike',
    CityBikeLayerIds.carSharing: 'car-sharing',
    CityBikeLayerIds.regiorad: 'regiorad',
    CityBikeLayerIds.scooter: 'tier_ludwigsburg',
  };

  static final images = <CityBikeLayerIds, SvgPicture>{
    CityBikeLayerIds.taxi: SvgPicture.string(taxiSvg),
    CityBikeLayerIds.cargoBike: SvgPicture.string(cargoBikeSvg),
    CityBikeLayerIds.carSharing: SvgPicture.string(carSharingSvg),
    CityBikeLayerIds.regiorad: SvgPicture.string(regioradSvg),
    CityBikeLayerIds.scooter: SvgPicture.string(scooterSvg),
  };

  static final imagesStop = <CityBikeLayerIds, SvgPicture>{
    CityBikeLayerIds.taxi: SvgPicture.string(taxiStopSvg),
    CityBikeLayerIds.cargoBike: SvgPicture.string(cargoBikeStopSvg),
    CityBikeLayerIds.carSharing: SvgPicture.string(carSharingStopSvg),
    CityBikeLayerIds.regiorad: SvgPicture.string(regioradStopSvg),
    CityBikeLayerIds.scooter: SvgPicture.string(scooterStopSvg),
  };
  static final imagesStopColor = <CityBikeLayerIds, Color>{
    CityBikeLayerIds.taxi: const Color(0xfff1b736),
    CityBikeLayerIds.cargoBike: const Color(0xffff834a),
    CityBikeLayerIds.carSharing: const Color(0xffff834a),
    CityBikeLayerIds.regiorad: const Color(0xff009FE4),
    CityBikeLayerIds.scooter: const Color(0xffff834a),
  };

  static final translateEn = <CityBikeLayerIds, String>{
    CityBikeLayerIds.taxi: "Taxi rank",
    CityBikeLayerIds.cargoBike: "Cargo bike rental station",
    CityBikeLayerIds.carSharing: "Car sharing station",
    CityBikeLayerIds.regiorad: "Bike rental station",
    CityBikeLayerIds.scooter: "e-scooter",
  };

  static final translateDE = <CityBikeLayerIds, String>{
    CityBikeLayerIds.taxi: 'Taxistand',
    CityBikeLayerIds.cargoBike: 'Lastenrad-Station',
    CityBikeLayerIds.carSharing: 'Carsharing-Station',
    CityBikeLayerIds.regiorad: 'Leihrad-Station',
    CityBikeLayerIds.scooter: "E-Scooter",
  };

  static final capacityEn = <CityBikeLayerIds, String>{
    CityBikeLayerIds.taxi: "Taxis available at the station right now",
    CityBikeLayerIds.cargoBike:
        "Cargo bikes available at the station right now",
    CityBikeLayerIds.carSharing:
        "Cars sharing available at the station right now",
    CityBikeLayerIds.regiorad: "Bikes available at the station right now",
    CityBikeLayerIds.scooter:
        "Kick scooters available at the station right now",
  };

  static final capacityDE = <CityBikeLayerIds, String>{
    CityBikeLayerIds.taxi: 'Taxis verfügbar',
    CityBikeLayerIds.cargoBike: 'Lastenräder verfügbar',
    CityBikeLayerIds.carSharing: 'Carsharing verfügbar',
    CityBikeLayerIds.regiorad: 'Leihräder verfügbar',
    CityBikeLayerIds.scooter: 'E-Scooter ausleihbar',
  };

  static const networkBookDataEn = <CityBikeLayerIds, NetworkBookData?>{
    CityBikeLayerIds.taxi: null,
    CityBikeLayerIds.carSharing: NetworkBookData(
      'Book a shared car',
      'https://stuttgart.stadtmobil.de/privatkunden/',
      languageCode: "en",
    ),
    CityBikeLayerIds.cargoBike: NetworkBookData(
      'Book a cargo bike',
      'https://gueltsteinmobil.de/guelf-unser-lastenfahrrad',
      languageCode: "en",
    ),
    CityBikeLayerIds.regiorad: NetworkBookData(
      'Book a rental bike',
      'https://www.regioradstuttgart.de/',
      languageCode: "en",
    ),
    CityBikeLayerIds.scooter: NetworkBookData(
      'Book an e-scooter',
      'https://www.tier.app/',
      languageCode: "en",
    ),
  };

  static const networkBookDataDe = <CityBikeLayerIds, NetworkBookData?>{
    CityBikeLayerIds.taxi: null,
    CityBikeLayerIds.carSharing: NetworkBookData(
      'Buchen Sie ein Car-Sharing-Auto',
      'https://stuttgart.stadtmobil.de/privatkunden/',
      languageCode: "de",
    ),
    CityBikeLayerIds.cargoBike: NetworkBookData(
      'Buchen Sie ein Lastenrad',
      'https://gueltsteinmobil.de/guelf-unser-lastenfahrrad',
      languageCode: "de",
    ),
    CityBikeLayerIds.regiorad: NetworkBookData(
      'Buchen Sie ein Leihrad',
      'https://www.regioradstuttgart.de/de',
      languageCode: "de",
    ),
    CityBikeLayerIds.scooter: NetworkBookData(
      'Buchen Sie einen E-Scooter',
      'https://www.tier.app/de/',
      languageCode: "de",
    ),
  };

  String get name => names[this] ?? 'taxi';

  Widget get image =>
      images[this] ?? const Icon(Icons.error, color: Colors.red);

  Widget get imageStop =>
      imagesStop[this] ?? const Icon(Icons.error, color: Colors.red);
  Color get imageStopColor => imagesStopColor[this] ?? Colors.transparent;

  String getTranslate(String languageCode) =>
      languageCode == 'en' ? translateEn[this]! : translateDE[this]!;

  String getCapacity(String languageCode, int capacity) => languageCode == 'en'
      ? "${capacityEn[this]} ($capacity)"
      : "${capacityDE[this]} ($capacity)";

  NetworkBookData getNetworkBookData(String languageCode) =>
      languageCode == 'en'
      ? networkBookDataEn[this]!
      : networkBookDataDe[this]!;

  bool hasBook(String languageCode) => languageCode == 'en'
      ? networkBookDataEn[this] != null
      : networkBookDataDe[this] != null;
}

class NetworkBookData {
  final String title;
  final String url;
  final String? languageCode;
  final IconData icon;

  const NetworkBookData(
    this.title,
    this.url, {
    this.languageCode,
    this.icon = Icons.launch,
  });

  String get bookText => languageCode == 'en' ? 'Book' : 'Buchen';
}
