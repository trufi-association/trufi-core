import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations_de.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations_en.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations_es.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations_fr.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations_it.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations_pt.dart';

void main() {
  // trufi-arequipa#29: the results list shows how many vehicle changes an
  // itinerary has; 0 reads as "direct" rather than "0 transfers".
  final cases = <TrufiBaseLocalization, List<String>>{
    TrufiBaseLocalizationEn(): ['Direct', '1 transfer', '2 transfers'],
    TrufiBaseLocalizationEs(): ['Directo', '1 transbordo', '2 transbordos'],
    TrufiBaseLocalizationDe(): ['Direkt', '1 Umstieg', '2 Umstiege'],
    TrufiBaseLocalizationFr(): ['Direct', '1 correspondance', '2 correspondances'],
    TrufiBaseLocalizationIt(): ['Diretto', '1 cambio', '2 cambi'],
    TrufiBaseLocalizationPt(): ['Direto', '1 transferência', '2 transferências'],
  };

  cases.forEach((l10n, expected) {
    test('itineraryTransfers in ${l10n.localeName}', () {
      expect(
        [0, 1, 2].map(l10n.itineraryTransfers).toList(),
        expected,
      );
    });
  });
}
