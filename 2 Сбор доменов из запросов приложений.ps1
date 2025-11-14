param ($logData, $appFileBASE, $domainFile, $domainFileBASE)

$fileExists = Test-Path -LiteralPath $domainFileBASE

if (-not $fileExists) {
	Write-Host "Сейчас откроется файл со списком доменов, к которым обращаются выбранные программы/пакеты. Его нужно отредактировать, удалив те, что не имеют отношения к выбранному интернет-ресурсу. Нажмите клавишу <Enter> для продолжения." -NoNewline
	Read-Host | Out-Null
}
else {
	Write-Host "Файл со списком доменов для выбранных программ/пакетов уже существует." -ForegroundColor Green -NoNewline
	Write-Host " Сейчас откроется новый файл со списком, полученным из выбранного журнала. Его нужно отредактировать, удалив домены, не имеющие отношения к выбранному интернет-ресурсу. После этого оба списка будут объединены. Нажмите клавишу <Enter> для продолжения." -NoNewline
	Read-Host | Out-Null
}


$logData.log.entries
| Where-Object {$_._app.id -in (Get-Content -LiteralPath $appFileBASE)}
| Sort-Object {$_.request.url} -Unique
| ForEach-Object {$_.request.url -replace "^.+?//", ""}
| ForEach-Object {$_ -replace ":\d+", ""}
| ForEach-Object {$_ -replace "/.*$", ""}
| Sort-Object -Unique
| Out-File -LiteralPath ($fileExists ? $domainFile : $domainFileBASE)

Invoke-Item -LiteralPath ($fileExists ? $domainFile : $domainFileBASE)


if (-not $fileExists) {
	Write-Host "Если редактирование файла завершено, сохраните его и нажмите клавишу <Enter>." -NoNewline
	Read-Host | Out-Null
	Write-Host "Создан файл со списком доменов для выбранных программ/пакетов." -ForegroundColor Green
}
else {
	Write-Host "Если редактирование файла завершено, сохраните его и нажмите клавишу <Enter>. Выбранные домены буду добавлены в существующий список без повторов." -NoNewline
	Read-Host | Out-Null

	Get-Content -LiteralPath $domainFileBASE, $domainFile
	| Sort-Object -Unique
	| Set-Content -LiteralPath $domainFileBASE
}
