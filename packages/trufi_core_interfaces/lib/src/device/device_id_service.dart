/// Abstract interface for obtaining a stable per-install device identifier.
///
/// Implementations typically generate a UUID on first access, persist it, and
/// return the same value for the lifetime of the install. The value is sent as
/// the `X-Device-Id` HTTP header on every outgoing request to correlate
/// backend analytics.
abstract class DeviceIdService {
  /// Returns the stable device id, generating and persisting one on first call.
  Future<String> getDeviceId();
}
