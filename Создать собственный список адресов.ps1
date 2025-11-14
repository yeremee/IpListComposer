Clear-Host

if ($false) { # РАБОЧИЙ РЕЖИМ
	$onlineRes = Read-Host "Введите название интернет-ресурса"
	$logFile = Read-Host "Введите путь к файлу журнала HTTP-соединений, записанного при работе с этим интернет-ресурсом"
	$folder = Read-Host "Введите путь к папке, где будут сохранены создаваемые файлы"
}
else { # ОТЛАДОЧНЫЙ РЕЖИМ
	$onlineRes = "test-copilot"
		Write-Host "Название интернет-ресурса: $onlineRes"
	$logFile = "$env:USERPROFILE\Yandex.Disk\Документы\OpenWRT\ProxyPin_2025-11-12_copilot"
		Write-Host "Путь к файлу журнала HTTP-соединений, записанного при работе с этим интернет-ресурсом: $logFile"
	$folder = "$env:USERPROFILE\Yandex.Disk\Документы\OpenWRT\"
		Write-Host "Путь к папке, где будут сохранены создаваемые файлы: $folder"
}

$logData = Get-Content -LiteralPath $logFile -Raw | ConvertFrom-Json
$subfolder = Join-Path $folder "IpListComposer" $onlineRes
New-Item $subfolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
$dateTime = Get-Date -Format "yyyyMMdd-HHmm"
$os = $logData.log.entries[0]._app.os

$appFileBASE    = Join-Path $subfolder "$onlineRes`_applist.txt"
$appFile        = Join-Path $subfolder "$onlineRes`_$os`_$dateTime`_applist.txt"
$domainFileBASE = Join-Path $subfolder "$onlineRes`_domainlist.txt"
$domainFile     = Join-Path $subfolder "$onlineRes`_$os`_$dateTime`_domainlist.txt"
$addressFile    = Join-Path $subfolder "$onlineRes`_$os`_$dateTime`_addresslist.txt"
$addressList    = Join-Path $subfolder "$onlineRes`_$os`_$dateTime.iplist"

. '.\1 Получение приложений из журнала.ps1' $logData $appFile $appFileBASE

. '.\2 Сбор доменов из запросов приложений.ps1' $logData $appFileBASE $domainFile $domainFileBASE

. '.\3 Перевод доменов в адреса.ps1' $domainFileBASE $addressFile

. '.\4 Объединение адресов в диапазоны.ps1' $addressFile $addressList

Write-Host "Работа завершена." -ForegroundColor Green -NoNewline
Write-Host " Нажмите клавишу <Enter> для выхода." -NoNewline
Read-Host