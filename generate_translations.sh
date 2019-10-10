#!/bin/sh

flutter pub run intl_translation:generate_from_arb \
  --output-dir=lib/translations/ \
  --use-deferred-loading \
  lib/trufi_localizations.dart \
  translations/*.arb

# Produce hard errors instead of falling back to original text:
# --codegen_mode release