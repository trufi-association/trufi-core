abstract class LocalRepository {
  Future<void> saveLanguageCode(String languageCode);

  Future<void> saveUseOnline({bool loadOnline});

  Future<void> saveCorrelationId(String correlationId);

  Future<void> saveStateHomePage(String stateHomePage);

  Future<void> saveLastReviewRequestAppVersion(String currentVersion);

  Future<void> saveReviewWorthyActionCount(int actionCount);

  Future<String> getCorrelationId();

  Future<String> getLanguageCode();

  Future<bool> getOnline();

  Future<String> getMapType();

  Future<String> getLastReviewRequestAppVersionKey();

  Future<void> deleteStateHomePage();

  Future<String> getStateHomePage();
}
