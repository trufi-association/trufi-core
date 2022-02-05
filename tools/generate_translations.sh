## Generates all files for the given translation
list='trufiapp_de.arb trufiapp_ee.arb trufiapp_en.arb trufiapp_es.arb trufiapp_fr.arb trufiapp_it.arb trufiapp_pt.arb'
# for i in $list; do
#     flutter gen-l10n --arb-dir=translations/saved_places_localizations --template-arb-file=$i --output-localization-file=saved_places_localizations.dart --output-class=SavedPlacesLocalization --output-dir=lib/base/pages/saved_places/translations --no-synthetic-package
# done
# flutter gen-l10n --arb-dir=translations/saved_places_localizations --template-arb-file=trufiapp_en.arb --output-localization-file=saved_places_localizations.dart --output-class=SavedPlacesLocalization --output-dir=lib/base/translations/saved_places_localizations --no-synthetic-package


for i in $list; do
flutter gen-l10n --arb-dir=translations/trufi_base_localizations --template-arb-file=$i --output-localization-file=trufi_base_localizations.dart --output-class=TrufiBaseLocalization --output-dir=lib/base/translations --no-synthetic-package
done

## Generates all files for the given translation with an additional file that shows all missing translations from the main language.
# flutter gen-l10n --arb-dir=translations --template-arb-file=trufiapp_en_US.arb --output-localization-file=trufi_localization.dart --output-class=TrufiLocalization --output-dir=lib\l10n --no-synthetic-package --untranslated-messages-file=desiredFileName.txt
#