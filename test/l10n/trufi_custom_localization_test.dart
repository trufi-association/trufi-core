import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/blocs/configuration/configuration.dart';

void main() {
  TrufiCustomLocalizations subject;

  group("TrufiCustomLocalizations", () {
    setUp(() {
      subject = TrufiCustomLocalizations();
      subject.title = {
        const Locale("en"): "Trufi App Test en",
        const Locale("de"): "Trufi App Test de",
        const Locale("de", "DE"): "Trufi App Test de_DE",
        const Locale("it"): "Trufi App Test it",
        const Locale("it", "IT"): "Trufi App Test it_IT"
      };
    });

    test("should return text for language and countryKey", () {
      expect(subject.get(subject.title, const Locale("de"), ""),
          "Trufi App Test de");
      expect(subject.get(subject.title, const Locale("en"), ""),
          "Trufi App Test en");
      expect(subject.get(subject.title, const Locale("it"), ""),
          "Trufi App Test it");
    });

    test("should return text for languageKey and countryKey", () {
      expect(subject.get(subject.title, const Locale("de", "DE"), ""),
          "Trufi App Test de_DE");
      expect(subject.get(subject.title, const Locale("it", "IT"), ""),
          "Trufi App Test it_IT");
    });

    test("should fallback to languageKey if countryKey does not exist", () {
      expect(
          subject.get(subject.title, const Locale("en", "EN"), "Default Test"),
          "Trufi App Test en");
    });

    test("should return default if Locale is not known", () {
      expect(
        subject.get(subject.title, const Locale("qu", "QU"), "Default"),
        "Default",
      );
    });

    test("should return default if element is not set", () {
      expect(
          subject.get(subject.description, const Locale("qu", "QU"), "Default"),
          "Default");
    });
  });
}
