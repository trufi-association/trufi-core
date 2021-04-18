import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/trufi_configuration.dart';

void main() {
  TrufiCustomLocalizations subject;

  group("TrufiCustomLocalizations", () {
    setUp(() {
      subject = TrufiConfiguration().customTranslations;
      subject.title = {
        Locale("en"): "Trufi App Test en",
        Locale("de"): "Trufi App Test de",
        Locale("de", "DE"): "Trufi App Test de_DE",
        Locale("it"): "Trufi App Test it",
        Locale("it", "IT"): "Trufi App Test it_IT"
      };
    });

    test("should return text for language and countryKey", () {
      expect(subject.get(subject.title, Locale("de"), ""), "Trufi App Test de");
      expect(subject.get(subject.title, Locale("en"), ""), "Trufi App Test en");
      expect(subject.get(subject.title, Locale("it"), ""), "Trufi App Test it");
    });

    test("should return text for languageKey and countryKey", () {
      expect(subject.get(subject.title, Locale("de", "DE"), ""),
          "Trufi App Test de_DE");
      expect(subject.get(subject.title, Locale("it", "IT"), ""),
          "Trufi App Test it_IT");
    });

    test("should fallback to languageKey if countryKey does not exist", () {
      expect(subject.get(subject.title, Locale("en", "EN"), "Default Test"),
          "Trufi App Test en");
    });

    test("should return default if Locale is not known", () {
      expect(
        subject.get(subject.title, Locale("qu", "QU"), "Default"),
        "Default",
      );
    });

    test("should return default if element is not set", () {
      expect(subject.get(subject.description, Locale("qu", "QU"), "Default"),
          "Default");
    });
  });
}
