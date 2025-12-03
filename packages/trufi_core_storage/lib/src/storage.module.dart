import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_storage/src/shared_preferences.service.dart';
import 'package:trufi_core_storage/src/storage_configuration.dart';
import 'package:trufi_core_storage/src/storage_service.dart';

class StorageModule implements TrufiModule {
  final StorageConfiguration configuration;

  StorageModule({StorageConfiguration? configuration})
    : configuration = configuration ?? const StorageConfiguration();

  @override
  String get name => 'storage';

  @override
  List<TrufiModule> get dependencies => [];

  @override
  Future<void> configure(ServiceLocator locator) async {
    locator.registerSingleton<StorageConfiguration>(configuration);

    locator.registerLazySingleton<StorageService>(
      () => SharedPreferencesStorage(locator.get<StorageConfiguration>()),
    );
  }

  @override
  Future<void> initialize(ServiceLocator locator) async {
    await locator.get<StorageService>().initialize();
  }
}
