import 'package:get_it/get_it.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

class GetItServiceLocator implements ServiceLocator {
  final GetIt _getIt;

  GetItServiceLocator(this._getIt);

  @override
  T get<T extends Object>({String? instanceName}) {
    return _getIt.get<T>(instanceName: instanceName);
  }

  @override
  void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
  }) {
    _getIt.registerSingleton<T>(instance, instanceName: instanceName);
  }

  @override
  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerLazySingleton<T>(factoryFunc, instanceName: instanceName);
  }

  @override
  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(factoryFunc, instanceName: instanceName);
  }

  @override
  Future<void> allReady() => _getIt.allReady();

  @override
  Future<void> reset() => _getIt.reset();
}
