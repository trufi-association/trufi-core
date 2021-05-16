import '../../trufi_models.dart';

abstract class PlacesStorage {
  final String id;

  PlacesStorage(this.id);

  Future<void> insert(TrufiLocation location);
  Future<void> delete(TrufiLocation location);
  Future<void> replace(TrufiLocation location);
  Future<void> update(TrufiLocation old, TrufiLocation location);
  Future<List<TrufiLocation>> all();
}
