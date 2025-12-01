import 'package:trufi_core/base/models/trufi_place.dart';

abstract class SearchLocationsLocalRepository {
  Future<void> loadRepository();

  Future<List<TrufiLocation>> getMyPlaces();
  Future<void> saveMyPlaces(List<TrufiLocation> data);

  Future<List<TrufiLocation>> getMyDefaultPlaces();
  Future<void> saveMyDefaultPlaces(List<TrufiLocation> data);

  Future<List<TrufiLocation>> getHistoryPlaces();
  Future<void> saveHistoryPlaces(List<TrufiLocation> data);

  Future<List<TrufiLocation>> getFavoritePlaces();
  Future<void> saveFavoritePlaces(List<TrufiLocation> data);
}
