## Generates all files for the given translation
flutter gen-l10n --arb-dir=translations --template-arb-file=trufiapp_en.arb --output-localization-file=trufi_localization.dart --output-class=TrufiLocalization --output-dir=lib/l10n --no-synthetic-package

## Generates all files for the given translation with an additional file that shows all missing translations from the main language.
# flutter gen-l10n --arb-dir=translations --template-arb-file=trufiapp_en_US.arb --output-localization-file=trufi_localization.dart --output-class=TrufiLocalization --output-dir=lib\l10n --no-synthetic-package --untranslated-messages-file=desiredFileName.txt
#