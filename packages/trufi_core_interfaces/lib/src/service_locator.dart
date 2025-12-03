abstract class ServiceLocator {
  T get<T extends Object>({String? instanceName});

  void registerSingleton<T extends Object>(T instance, {String? instanceName});

  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  });

  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  });

  Future<void> allReady();
  Future<void> reset();
}
