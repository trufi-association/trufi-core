import 'package:trufi_core/base/pages/transport_list/services/models.dart';

abstract class RouteTransportsLocalRepository {
  Future<void> loadRepository();
  Future<void> saveTransports(List<PatternOtp> data);
  Future<List<PatternOtp>> getTransports();
}
