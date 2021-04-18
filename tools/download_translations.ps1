lokalise2 file download --unzip-to ./translations --config ./tools/config.yml --format arb `
    --original-filenames=false --bundle-structure locale/trufiapp_%LANG_ISO%.%FORMAT% `
    --all-platforms --filter-langs='ee,es,fr,it,pt,qu,en,de' --replace-breaks=false

$source = "./translations/locale"
$dest = "./translations"
Get-ChildItem -Path $source -Recurse -File | Move-Item -Destination $dest -Force
Remove-Item $source