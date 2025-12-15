import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Abstract interface for storing saved places locally.
abstract class SearchLocationsLocalRepository {
  /// Initialize the repository and open storage.
  Future<void> loadRepository();

  /// Close the repository and release resources.
  Future<void> dispose();

  Future<List<TrufiLocation>> getMyPlaces();
  Future<void> saveMyPlaces(List<TrufiLocation> data);

  Future<List<TrufiLocation>> getMyDefaultPlaces();
  Future<void> saveMyDefaultPlaces(List<TrufiLocation> data);

  Future<List<TrufiLocation>> getHistoryPlaces();
  Future<void> saveHistoryPlaces(List<TrufiLocation> data);

  Future<List<TrufiLocation>> getFavoritePlaces();
  Future<void> saveFavoritePlaces(List<TrufiLocation> data);
}
