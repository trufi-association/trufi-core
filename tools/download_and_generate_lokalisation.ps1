Write-Host "Download Lokalisations" -ForegroundColor Green
.\tools\download_translations.ps1
Write-Host "Finished: Download Lokalisations" -ForegroundColor Green

Write-Host "Start: Generate Translations" -ForegroundColor Green
.\tools\generate_translations.ps1
Write-Host "Finished: Generate Translations" -ForegroundColor Green