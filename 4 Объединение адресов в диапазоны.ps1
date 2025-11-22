param ($addressFile, $addressList)

. '.\Тип IP-адреса.ps1'

$адреса = Get-Content -LiteralPath $addressFile | Select-String "`t" -NotMatch
$диапазоны = [IPАдрес]::ОбъединитьВъДиапазоны($адреса, 24)
Set-Content $диапазоны -LiteralPath $addressList

Write-Host "Создан файл со списком диапазонов, объединяющих полученные IP-адреса." -ForegroundColor Green

Invoke-Item -LiteralPath $addressList
