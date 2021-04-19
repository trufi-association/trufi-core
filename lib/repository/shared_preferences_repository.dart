import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  Future<SharedPreferences> _sharedPreferences;

  static const String correlationIdKey = "correlation_id";
  static const String propertyLanguageCodeKey = "property_language_code";
  static const String propertyOnlineKey = "property_online";
  static const String propertyMapTypeKey = "property_map_type";
  static const String stateHomePageKey = "state_home_page";
  static const String actionCountKey = "review_worthy_action_count";
  static const String lastReviewRequestAppVersionKey =
      "last_review_request_app_version";

  SharedPreferencesRepository() {
    _sharedPreferences = SharedPreferences.getInstance();
  }

  Future<void> saveLanguageCode(String languageCode) async {
    final preferences = await _sharedPreferences;
    await preferences.setString(propertyOnlineKey, languageCode);
  }

  Future<void> saveUseOnline({bool loadOnline}) async {
    final preferences = await _sharedPreferences;
    await preferences.setBool(propertyOnlineKey, loadOnline);
  }

  Future<void> saveCorrelationId(String correlationId) async {
    final preference = await _sharedPreferences;
    preference.setString(correlationIdKey, correlationId);
  }

  Future<String> getCorrelationId() async {
    final preference = await _sharedPreferences;
    return preference.getString(correlationIdKey);
  }

  Future<String> getLanguageCode() async {
    final preference = await _sharedPreferences;
    return preference.getString(propertyLanguageCodeKey);
  }

  Future<bool> getOnline() async {
    final preference = await _sharedPreferences;
    return preference.getBool(propertyOnlineKey);
  }

  Future<String> getMapType() async {
    final preference = await _sharedPreferences;
    return preference.getString(propertyMapTypeKey);
  }

  Future<String> getLastReviewRequestAppVersionKey() async {
    final preference = await _sharedPreferences;
    return preference.getString(lastReviewRequestAppVersionKey);
  }

  Future<void> saveStateHomePage(String stateHomePage) async {
    final preference = await _sharedPreferences;
    preference.setString(stateHomePageKey, stateHomePage);
  }

  Future<void> saveLastReviewRequestAppVersion(String currentVersion) async {
    final preference = await _sharedPreferences;
    preference.setString(lastReviewRequestAppVersionKey, currentVersion);
  }

  Future<void> saveReviewWorthyActionCount(int actionCount) async{
    final preference = await _sharedPreferences;
    preference.setInt(actionCountKey, actionCount);
  }
}
