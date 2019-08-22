#!/bin/sh

flutter pub run intl_translation:generate_from_arb \
  --output-dir=lib/translations/ \
  --codegen_mode release \
  --use-deferred-loading \
  lib/trufi_localizations.dart \
  translations/*.arb