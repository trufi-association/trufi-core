## Generates all files for the given translation
list='trufiapp_de.arb trufiapp_en.arb trufiapp_es.arb trufiapp_fr.arb trufiapp_it.arb trufiapp_pt.arb'

#base command translations
# for i in $list; do
# flutter gen-l10n --arb-dir=translations/trufi_base_localizations --template-arb-file=$i --output-localization-file=trufi_base_localizations.dart --output-class=TrufiBaseLocalization --output-dir=lib/base/translations --no-synthetic-package
# done


#SavedPlaces command translations
# for i in $list; do
#     flutter gen-l10n --arb-dir=translations/saved_places_localizations --template-arb-file=$i --output-localization-file=saved_places_localizations.dart --output-class=SavedPlacesLocalization --output-dir=lib/base/pages/saved_places/translations --no-synthetic-package
# done


#Feedback command translations
# for i in $list; do
#     flutter gen-l10n --arb-dir=translations/feedback_localizations --template-arb-file=$i --output-localization-file=feedback_localizations.dart --output-class=FeedbackLocalization --output-dir=lib/base/pages/feedback/translations --no-synthetic-package
# done

#Aboud command translations
for i in $list; do
    flutter gen-l10n --arb-dir=translations/about_localizations --template-arb-file=$i --output-localization-file=about_localizations.dart --output-class=AboutLocalization --output-dir=lib/base/pages/about/translations --no-synthetic-package
done
