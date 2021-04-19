import 'package:trufi_core/models/preferences.dart';

abstract class PreferencesState {
  const PreferencesState();
}

class PreferencesLoading extends PreferencesState {}

class PreferencesLoadSuccess extends PreferencesState {
  final Preference preference;

  PreferencesLoadSuccess(this.preference);

  @override
  String toString() => "PreferencesLoadSuccess { preference: $preference }";
}

class PreferencesLoadFailure extends PreferencesState {}
