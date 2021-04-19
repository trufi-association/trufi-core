import 'package:trufi_core/models/preferences.dart';

abstract class PreferencesEvent {
  const PreferencesEvent();
}

class LoadPreferences extends PreferencesEvent {}

class UpdatePreferences extends PreferencesEvent {
  final Preference preference;

  const UpdatePreferences(this.preference);

  @override
  String toString() => "PreferenceUpdated { updatedPreference: $preference }";
}

class UpdateOnline extends PreferencesEvent {
  final bool isOnline;

  const UpdateOnline({this.isOnline});

  @override
  String toString() => "PreferenceUpdated { isOnline: $isOnline }";
}
