import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

const List<Locale> supportedLocales = <Locale>[
  Locale('en', 'US'), // English
  Locale('de', 'DE'), // German
  Locale('qu', 'BO'), // Quechua
  Locale('es', 'ES'), // Spanish
];

const Locale defaultLocale = Locale('es', 'ES');

class TrufiLocalizations {
  static TrufiLocalizations of(BuildContext context) {
    return Localizations.of<TrufiLocalizations>(context, TrufiLocalizations);
  }

  TrufiLocalizations(this.locale, this.translation);

  final Locale locale;
  final Map<String, String> translation;

  static Future<Map<String, String>> loadTranslation(Locale locale) async {
    final localeString = locale.languageCode + "_" + locale.countryCode;
    final assetPath = "assets/translations/$localeString.json";
    final translationString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> result = jsonDecode(translationString);
    final translation = result.cast<String, String>();

    return translation;
  }

  String translate(String translationKey) {
    return translation[translationKey] ?? translationKey;
  }

  String get title {
    return translate("title");
  }

  String get tagLine {
    return translate("tag_line");
  }

  String get description {
    return translate("description");
  }

  String get alertLocationServicesDeniedTitle {
    return translate("alert_location_services_denied_title");
  }

  String get alertLocationServicesDeniedMessage {
    return translate("alert_location_services_denied_message");
  }

  String get commonOK {
    return translate("common_ok");
  }

  String get commonCancel {
    return translate("common_cancel");
  }

  String get commonGoOffline {
    return translate("common_go_offline");
  }

  String get commonGoOnline {
    return translate("common_go_online");
  }

  String get commonDestination {
    return translate("common_destination");
  }

  String get commonOrigin {
    return translate("common_origin");
  }

  String get commonNoInternet {
    return translate("common_no_internet_connection");
  }

  String get commonFailLoading {
    return translate("common_fail_loading_data");
  }

  String get commonUnknownError {
    return translate("common_unknown_error");
  }

  String get commonError {
    return translate("common_error");
  }

  String get errorServerUnavailable {
    return translate("route_request_error_server_unavailable");
  }

  String get errorOutOfBoundary {
    return translate("route_request_error_out_of_boundary");
  }

  String get errorPathNotFound {
    return translate("route_request_error_path_not_found");
  }

  String get errorNoTransitTimes {
    return translate("route_request_error_no_transit_times");
  }

  String get errorServerTimeout {
    return translate("route_request_error_server_timeout");
  }

  String get errorTrivialDistance {
    return translate("route_request_error_trivial_distance");
  }

  String get errorServerCanNotHandleRequest {
    return translate("route_request_error_server_can_not_handle_request");
  }

  String get errorUnknownOrigin {
    return translate("route_request_error_unknown_origin");
  }

  String get errorUnknownDestination {
    return translate("route_request_error_unknown_destination");
  }

  String get errorUnknownOriginDestination {
    return translate("route_request_error_origin_destination_unknown");
  }

  String get errorNoBarrierFree {
    return translate("route_request_error_no_barrier_free");
  }

  String get errorAmbiguousOrigin {
    return translate("route_request_error_ambiguous_origin");
  }

  String get errorAmbiguousDestination {
    return translate("route_request_error_ambiguous_destination");
  }

  String get errorAmbiguousOriginDestination {
    return translate("route_request_error_origin_destination_ambiguous");
  }

  String get searchHintOrigin {
    return translate("search_hint_origin");
  }

  String get searchHintDestination {
    return translate("search_hint_destination");
  }

  String get searchItemChooseOnMap {
    return translate("search_item_choose_on_map");
  }

  String get searchItemYourLocation {
    return translate("search_item_your_location");
  }

  String get searchItemNoResults {
    return translate("search_item_no_results");
  }

  String get searchTitlePlaces {
    return translate("search_section_places");
  }

  String get searchTitleRecent {
    return translate("search_section_recent");
  }

  String get searchTitleFavorites {
    return translate("search_section_favorites");
  }

  String get searchTitleResults {
    return translate("search_section_results");
  }

  String get searchPleaseSelectOrigin {
    return translate("search_section_please_select_origin");
  }

  String get searchPleaseSelectDestination {
    return translate("search_section_please_select_destination");
  }

  String get searchFailLoadingPlan {
    return translate("search_fail_loading_plan");
  }

  String get searchMapMarker {
    return translate("search_section_map_marker");
  }

  String get searchNavigate {
    return translate("search_navigate_to_marker");
  }

  String get instructionWalkStart {
    return translate("instruction_walk_start");
  }

  String get instructionWalk {
    return translate("instruction_walk");
  }

  String get instructionRide {
    return translate("instruction_ride");
  }

  String get instructionRideBus {
    return translate("instruction_ride_bus");
  }

  String get instructionMinutes {
    return translate("instruction_minutes");
  }

  String get instructionRideMicro {
    return translate("instruction_ride_micro");
  }

  String get instructionRideMinibus {
    return translate("instruction_ride_minibus");
  }

  String get instructionRideTrufi {
    return translate("instruction_ride_trufi");
  }

  String get instructionTo {
    return translate("instruction_to");
  }

  String get instructionFor {
    return translate("instruction_for");
  }

  String get instructionUnitKm {
    return translate("instruction_unit_kilometer");
  }

  String get instructionUnitMeter {
    return translate("instruction_unit_meter");
  }

  String get chooseLocationPageTitle {
    return translate("choose_location_page_title");
  }

  String get chooseLocationPageSubtitle {
    return translate("choose_location_page_subtitle");
  }

  String get menuConnections {
    return translate("menu_connections");
  }

  String get menuAbout {
    return translate("menu_about");
  }

  String get menuTeam {
    return translate("menu_team");
  }

  String get menuFeedback {
    return translate("menu_feedback");
  }

  String get menuOnline {
    return translate("menu_online");
  }

  String get feedbackContent {
    return translate("feedback_content");
  }

  String get feedbackTitle {
    return translate("feedback_title");
  }

  String get aboutContent {
    return translate("about_content");
  }

  String get license {
    return translate("license_button");
  }

  String get teamContent {
    return translate("team_content");
  }

  String get english {
    return translate("english");
  }

  String get german {
    return translate("german");
  }

  String get spanish {
    return translate("spanish");
  }

  String get quechua {
    return translate("quechua");
  }
}

class TrufiMaterialLocalizations extends DefaultMaterialLocalizations {
  static TrufiMaterialLocalizations of(BuildContext context) {
    return MaterialLocalizations.of(context);
  }

  TrufiMaterialLocalizations(this.locale);

  final Locale locale;
  String _searchHinText;

  @override
  String get searchFieldLabel {
    return _searchHinText;
  }

  void setSearchHintText(String searchHintText) {
    _searchHinText = searchHintText;
  }
}

class TrufiLocalizationsDelegate
    extends TrufiLocalizationsDelegateBase<TrufiLocalizations> {
  TrufiLocalizationsDelegate(String languageCode) : super(languageCode);

  @override
  Future<TrufiLocalizations> load(Locale locale) async {
    if (languageCode != null) {
      locale = localeForLanguageCode(languageCode);
    }

    if (locale == null) {
      locale = defaultLocale;
    }

    var translation = await TrufiLocalizations.loadTranslation(locale);
    return TrufiLocalizations(locale, translation);
  }
}

class TrufiMaterialLocalizationsDelegate
    extends TrufiLocalizationsDelegateBase<MaterialLocalizations> {
  TrufiMaterialLocalizationsDelegate(String languageCode) : super(languageCode);

  @override
  Future<TrufiMaterialLocalizations> load(Locale locale) async {
    if (languageCode != null) {
      locale = localeForLanguageCode(languageCode);
    }

    if (locale == null) {
      locale = defaultLocale;
    }

    return SynchronousFuture<TrufiMaterialLocalizations>(
      TrufiMaterialLocalizations(locale),
    );
  }
}

abstract class TrufiLocalizationsDelegateBase<T>
    extends LocalizationsDelegate<T> {
  TrufiLocalizationsDelegateBase(this.languageCode);

  final String languageCode;

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  bool shouldReload(TrufiLocalizationsDelegateBase<T> old) {
    return old.languageCode != languageCode;
  }

  Locale localeForLanguageCode(String languageCode) {
    for (var locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }

    return null;
  }
}
