param ($logData, $appFile, $appFileBASE)

$fileExists = Test-Path -LiteralPath $appFileBASE

if (-not $fileExists) {
	Write-Host "Сейчас откроется файл со списком всех присутствующих в журнале программ/пакетов. Его нужно отредактировать, удалив те, что не имеют отношения к выбранному интернет-ресурсу. Нажмите клавишу <Enter> для продолжения." -NoNewline
	Read-Host | Out-Null
}
else {
	Write-Host "Файл со списком программ/пакетов для этого интернет-ресурса уже существует." -ForegroundColor Green -NoNewline
	Write-Host " Сейчас откроется новый файл со списком, полученным из выбранного журнала. Его нужно отредактировать, удалив программы/пакеты, не имеющие отношения к работе с выбранным интернет-ресурсом. После этого оба списка будут объединены. Нажмите клавишу <Enter> для продолжения." -NoNewline
	Read-Host | Out-Null
}


$logData.log.entries
| Sort-Object {$_._app.id} -Unique
| ForEach-Object {$_._app.id}
| Out-File -LiteralPath ($fileExists ? $appFile : $appFileBASE)

Invoke-Item -LiteralPath ($fileExists ? $appFile : $appFileBASE)


if (-not $fileExists) {
	Write-Host "Если редактирование файла завершено, сохраните его и нажмите клавишу <Enter>." -NoNewline
	Read-Host | Out-Null
	Write-Host "Создан файл со списком программ/пакетов для выбранного интернет-ресурса." -ForegroundColor Green
}
else {
	Write-Host "Если редактирование файла завершено, сохраните его и нажмите клавишу <Enter>. Выбранные программы/пакеты буду добавлены в существующий список без повторов." -NoNewline
	Read-Host | Out-Null

	Get-Content -LiteralPath $appFileBASE, $appFile
	| Sort-Object -Unique
	| Set-Content -LiteralPath $appFileBASE
}
