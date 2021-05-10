lokalise2 file download --unzip-to ./translations/ --config ./tools/config.yml --format arb \
    --original-filenames=false --bundle-structure locale/trufiapp_%LANG_ISO%.%FORMAT% --all-platforms \
    --filter-langs='ee,es,fr,it,pt,qu,en,de' --replace-breaks=false \
    --export-empty-as=base

mv ./translations/locale/* ./translations
rm -r ./translations/locale