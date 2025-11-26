import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

abstract class ILocationService {
  static const String path = "HiveLocationService";
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
