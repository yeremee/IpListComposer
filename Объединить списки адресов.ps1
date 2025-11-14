Clear-Host

$folder = Read-Host "Введите путь к папке, содержащей списки адресов (файлы с расширением .iplist)"
Set-Location -LiteralPath $folder

$iplist = "IPLIST_" + (Get-Date -Format "yyyyMMdd-HHmm")

Get-Content *.iplist
| Select-String "^$" -NotMatch
| Sort-Object -Unique
| Set-Content $iplist

Invoke-Item -LiteralPath $iplist

Write-Host "Списки адресов были объединены в файле '$iplist', сохранённом в той же папке. Нажмите клавишу <Enter> для выхода."
Read-Host