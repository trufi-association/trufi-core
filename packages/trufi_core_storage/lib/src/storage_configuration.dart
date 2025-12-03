enum StorageBackend {
  sharedPreferences,

  // More DB could be added in the future e.g.
  // hive,
  // secureStorage,
}

class StorageConfiguration {
  final StorageBackend backend;
  final String? encryptionKey;
  final bool enableLogging;
  final Duration? cacheDuration;

  const StorageConfiguration({
    this.backend = StorageBackend.sharedPreferences,
    this.encryptionKey,
    this.enableLogging = false,
    this.cacheDuration,
  });

  // factory StorageConfiguration.secure({
  //   required String encryptionKey,
  //   bool enableLogging = false,
  // }) {
  //   return StorageConfiguration(
  //     backend: StorageBackend.secureStorage,
  //     encryptionKey: encryptionKey,
  //     enableLogging: enableLogging,
  //   );
  // }
  //
  // factory StorageConfiguration.hive({
  //   String? encryptionKey,
  //   bool enableLogging = false,
  // }) {
  //   return StorageConfiguration(
  //     backend: StorageBackend.hive,
  //     encryptionKey: encryptionKey,
  //     enableLogging: enableLogging,
  //   );
  // }
}
