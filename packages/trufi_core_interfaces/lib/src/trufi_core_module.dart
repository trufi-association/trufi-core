import 'package:trufi_core_interfaces/src/service_locator.dart';

abstract class TrufiModule {
  String get name;
  Future<void> configure(ServiceLocator locator);
  Future<void> initialize(ServiceLocator locator);
  List<TrufiModule> get dependencies => [];
}
