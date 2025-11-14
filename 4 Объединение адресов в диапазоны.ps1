param ($addressFile, $addressList)

. '.\Функции для IP-адресов.ps1'

Get-Content -LiteralPath $addressFile
| Select-String "`t" -NotMatch
| АдресСъМаскойВъДиапазон 24
| ПривестиВъДополненнуюФорму
| Sort-Object -Unique
| Out-File -LiteralPath $addressList

Write-Host "Создан файл со списком диапазонов, объединяющих полученные IP-адреса." -ForegroundColor Green

Invoke-Item -LiteralPath $addressList
