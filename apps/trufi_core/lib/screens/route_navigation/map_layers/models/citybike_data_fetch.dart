

import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/models/bike_rental_station_uris.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/models/citybikes_enum.dart';

class CityBikeDataFetch {
  final String? id;
  final String? stationId;
  final String? name;
  final int? bikesAvailable;
  final int? spacesAvailable;
  final String? state;
  final List<CityBikeLayerIds>? networks;
  final BikeRentalStationUris? rentalUris;
  final double? lon;
  final double? lat;
  final int? capacity;

  const CityBikeDataFetch({
    this.id,
    this.stationId,
    this.name,
    this.bikesAvailable,
    this.spacesAvailable,
    this.state,
    this.networks,
    this.rentalUris,
    this.lon,
    this.lat,
    this.capacity,
  });

  factory CityBikeDataFetch.fromBikeRentalStation(
    BikeRentalStationEntity? bikeRentalStation,
  ) {
    return CityBikeDataFetch(
      id: bikeRentalStation?.id,
      stationId: bikeRentalStation?.stationId,
      name: bikeRentalStation?.name,
      bikesAvailable: bikeRentalStation?.bikesAvailable,
      spacesAvailable: bikeRentalStation?.spacesAvailable,
      state: bikeRentalStation?.state,
      networks: bikeRentalStation?.networks
          ?.map((e) => cityBikeLayerIdStringToEnum(e))
          .toList(),
      // rentalUris: bikeRentalStation?.rentalUris, //TODO GT review data
      lon: bikeRentalStation?.lon,
      lat: bikeRentalStation?.lat,
      capacity: bikeRentalStation?.capacity,
    );
  }

  CityBikeLayerIds? get firstNetwork =>
      (networks?.isNotEmpty ?? false) ? networks![0] : null;

  String? getUrl(String languageCode) {
    return rentalUris?.web ??
        firstNetwork?.getNetworkBookData(languageCode).url;
  }
}
