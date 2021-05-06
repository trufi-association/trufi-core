import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core/repository/local_repository.dart';

const String _correlationIdKey = "correlation_id";
const String _propertyLanguageCodeKey = "property_language_code";
const String _propertyOnlineKey = "property_online";
const String _propertyMapTypeKey = "property_map_type";
const String _stateHomePageKey = "state_home_page";
const String _stateSettingPanelKey = "state_setting_panel";
const String _actionCountKey = "review_worthy_action_count";
const String _lastReviewRequestAppVersionKey =
    "last_review_request_app_version";

class SharedPreferencesRepository implements LocalRepository {
  Future<SharedPreferences> _sharedPreferences;

  SharedPreferencesRepository() {
    _sharedPreferences = SharedPreferences.getInstance();
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final preferences = await _sharedPreferences;
    await preferences.setString(_propertyLanguageCodeKey, languageCode);
  }

  @override
  Future<void> saveUseOnline({bool loadOnline}) async {
    final preferences = await _sharedPreferences;
    await preferences.setBool(_propertyOnlineKey, loadOnline);
  }

  @override
  Future<void> saveCorrelationId(String correlationId) async {
    final preference = await _sharedPreferences;
    preference.setString(_correlationIdKey, correlationId);
  }

  @override
  Future<void> saveStateHomePage(String stateHomePage) async {
    final preference = await _sharedPreferences;
    preference.setString(_stateHomePageKey, stateHomePage);
  }

  @override
  Future<void> saveLastReviewRequestAppVersion(String currentVersion) async {
    final preference = await _sharedPreferences;
    preference.setString(_lastReviewRequestAppVersionKey, currentVersion);
  }

  @override
  Future<void> saveReviewWorthyActionCount(int actionCount) async {
    final preference = await _sharedPreferences;
    preference.setInt(_actionCountKey, actionCount);
  }

  @override
  Future<String> getCorrelationId() async {
    final preference = await _sharedPreferences;
    return preference.getString(_correlationIdKey);
  }

  @override
  Future<String> getLanguageCode() async {
    final preference = await _sharedPreferences;
    return preference.getString(_propertyLanguageCodeKey);
  }

  @override
  Future<bool> getOnline() async {
    final preference = await _sharedPreferences;
    return preference.getBool(_propertyOnlineKey);
  }

  @override
  Future<String> getMapType() async {
    final preference = await _sharedPreferences;
    return preference.getString(_propertyMapTypeKey);
  }

  @override
  Future<String> getLastReviewRequestAppVersionKey() async {
    final preference = await _sharedPreferences;
    return preference.getString(_lastReviewRequestAppVersionKey);
  }

  @override
  Future<void> deleteStateHomePage() async {
    final preference = await _sharedPreferences;
    preference.remove(_stateHomePageKey);
  }

  @override
  Future<String> getStateHomePage() async {
    final preference = await _sharedPreferences;
    return preference.getString(_stateHomePageKey);
  }

  @override
  Future<String> getStateSettingPanel() async {
    final preference = await _sharedPreferences;
    return preference.getString(_stateSettingPanelKey);
  }

  @override
  Future<void> saveStateSettingPanel(String stateSettingPanel) async {
    final preference = await _sharedPreferences;
    preference.setString(_stateSettingPanelKey, stateSettingPanel);
  }
}
