. '.\Функции для IP-адресов.ps1'

Clear-Host

$folder = Read-Host "Введите путь к папке, содержащей списки адресов (файлы с расширением .iplist)"
Set-Location -LiteralPath $folder

$ILCsubfld = Join-Path $folder "IpListComposer"
New-Item $ILCsubfld -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

foreach ($iplist in Get-ChildItem *.iplist) {
	Get-Content -LiteralPath $iplist
	| ПривестиВъДополненнуюФорму
	| Sort-Object -Unique
	| Set-Content -LiteralPath (Join-Path $ILCsubfld (Split-Path $iplist -Leaf))
}

Write-Host "Адреса из файлов со списками были переведены в дополненную форму и сохранены в одноимённых файлах в подпапке 'IpListComposer'. Нажмите клавишу <Enter> для выхода."
Read-Host