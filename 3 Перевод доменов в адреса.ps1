param ($domainFileBASE, $addressFile)

Get-Content -LiteralPath $domainFileBASE
| Select-String "^\d+\.\d+\.\d+\.\d+$"
| Out-File -LiteralPath $addressFile -Append

$addressGroups = Get-Content -LiteralPath $domainFileBASE
| Select-String "^\d+\.\d+\.\d+\.\d+$" -NotMatch
| Resolve-DnsName -ErrorAction SilentlyContinue
| Where-Object IP4Address -NE $null
| Group-Object IP4Address

foreach ($group in $addressGroups) {
	$group.Name | Out-File -LiteralPath $addressFile -Append
	$group.Group | ForEach-Object {"`t" + $_.Name} | Sort-Object -Unique | Out-File -LiteralPath $addressFile -Append
}

(Get-Content -LiteralPath $addressFile)
| Select-String "^\s*$" -NotMatch
| Set-Content -LiteralPath $addressFile

Write-Host "Создан файл со списком IP-адресов для полученных доменов." -ForegroundColor Green
