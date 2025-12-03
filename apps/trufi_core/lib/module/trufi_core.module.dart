import 'package:get_it/get_it.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import './get_it_service_locator.dart';

class TrufiCoreModule {
  static final _getIt = GetIt.asNewInstance();
  static late final ServiceLocator _locator;

  static ServiceLocator get locator => _locator;

  final List<TrufiModule> _modules = [];
  final Set<String> _registeredModules = {};

  TrufiCoreModule() {
    _locator = GetItServiceLocator(_getIt);
  }

  void addModule(TrufiModule module) {
    if (_registeredModules.contains(module.name)) {
      throw StateError('Module ${module.name} already registered');
    }

    for (final dependency in module.dependencies) {
      if (!_registeredModules.contains(dependency.name)) {
        addModule(dependency);
      }
    }

    _modules.add(module);
    _registeredModules.add(module.name);
  }

  Future<void> initialize() async {
    for (final module in _modules) {
      await module.configure(_locator);
    }

    for (final module in _modules) {
      await module.initialize(_locator);
    }

    await _locator.allReady();
  }

  T get<T extends Object>() => _locator.get<T>();

  Future<void> reset() async {
    await _locator.reset();
    _modules.clear();
    _registeredModules.clear();
  }
}
