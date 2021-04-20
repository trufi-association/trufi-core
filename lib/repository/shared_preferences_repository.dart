import 'package:shared_preferences/shared_preferences.dart';

const String _correlationIdKey = "correlation_id";
const String _propertyLanguageCodeKey = "property_language_code";
const String _propertyOnlineKey = "property_online";
const String _propertyMapTypeKey = "property_map_type";
const String _stateHomePageKey = "state_home_page";
const String _actionCountKey = "review_worthy_action_count";
const String _lastReviewRequestAppVersionKey =
    "last_review_request_app_version";

class SharedPreferencesRepository {
  Future<SharedPreferences> _sharedPreferences;

  SharedPreferencesRepository() {
    _sharedPreferences = SharedPreferences.getInstance();
  }

  Future<void> saveLanguageCode(String languageCode) async {
    final preferences = await _sharedPreferences;
    await preferences.setString(_propertyLanguageCodeKey, languageCode);
  }

  Future<void> saveUseOnline({bool loadOnline}) async {
    final preferences = await _sharedPreferences;
    await preferences.setBool(_propertyOnlineKey, loadOnline);
  }

  Future<void> saveCorrelationId(String correlationId) async {
    final preference = await _sharedPreferences;
    preference.setString(_correlationIdKey, correlationId);
  }

  Future<void> saveStateHomePage(String stateHomePage) async {
    final preference = await _sharedPreferences;
    preference.setString(_stateHomePageKey, stateHomePage);
  }

  Future<void> saveLastReviewRequestAppVersion(String currentVersion) async {
    final preference = await _sharedPreferences;
    preference.setString(_lastReviewRequestAppVersionKey, currentVersion);
  }

  Future<void> saveReviewWorthyActionCount(int actionCount) async {
    final preference = await _sharedPreferences;
    preference.setInt(_actionCountKey, actionCount);
  }

  Future<String> getCorrelationId() async {
    final preference = await _sharedPreferences;
    return preference.getString(_correlationIdKey);
  }

  Future<String> getLanguageCode() async {
    final preference = await _sharedPreferences;
    return preference.getString(_propertyLanguageCodeKey);
  }

  Future<bool> getOnline() async {
    final preference = await _sharedPreferences;
    return preference.getBool(_propertyOnlineKey);
  }

  Future<String> getMapType() async {
    final preference = await _sharedPreferences;
    return preference.getString(_propertyMapTypeKey);
  }

  Future<String> getLastReviewRequestAppVersionKey() async {
    final preference = await _sharedPreferences;
    return preference.getString(_lastReviewRequestAppVersionKey);
  }

  Future<void> deleteStateHomePage() async {
    final preference = await _sharedPreferences;
    preference.remove(_stateHomePageKey);
  }
}
