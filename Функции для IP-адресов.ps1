function ПривестиВъДополненнуюФорму {
	param (
		[Parameter(ValueFromPipeline)]
		[string]$АдресИлиДиапазон
	)
	process {
		$АдресИлиДиапазон -match '(?<part1>\d{1,3})\.(?<part2>\d{1,3})\.(?<part3>\d{1,3})\.(?<part4>\d{1,3})(?:/(?<mask>\d{1,2}))?' | Out-Null
		$части = 	[byte]$Matches.part1,
					[byte]$Matches.part2,
					[byte]$Matches.part3,
					[byte]$Matches.part4,
					($null -ne $Matches.mask ? [byte]$Matches.mask : 32)
		"$АдресИлиДиапазон >>" | Write-Debug
		return "{0:D3}.{1:D3}.{2:D3}.{3:D3}/{4:D2}" -f $части
	}
}

function ПривестиВъСтандартнуюФорму {
	param (
		[Parameter(ValueFromPipeline)]
		[string]$АдресИлиДиапазон
	)
	process {
		$АдресИлиДиапазон -match '(?<part1>\d{1,3})\.(?<part2>\d{1,3})\.(?<part3>\d{1,3})\.(?<part4>\d{1,3})(?:/(?<mask>\d{1,2}))?' | Out-Null
		$части = 	[byte]$Matches.part1,
					[byte]$Matches.part2,
					[byte]$Matches.part3,
					[byte]$Matches.part4,
					($null -eq $Matches.mask -or 32 -eq $Matches.mask ? $null : [byte]$Matches.mask)
		"$АдресИлиДиапазон >>" | Write-Debug
		return ("{0:D}.{1:D}.{2:D}.{3:D}" + ($null -ne $части[-1] ? "/{4:D}" : "")) -f $части
	}
}

function АдресДесятичныйВъДвоичный($АдресДЕСЯТ) {
	$АдресДЕСЯТ -match '(?<part1>\d{1,3})\.(?<part2>\d{1,3})\.(?<part3>\d{1,3})\.(?<part4>\d{1,3})' | Out-Null
	$частиАдреса = 	[byte]$Matches.part1,
	 				[byte]$Matches.part2,
	  				[byte]$Matches.part3,
	   				[byte]$Matches.part4
	"$("{0:D}.{1:D}.{2:D}.{3:D}" -f $частиАдреса) > $("{0:B8}.{1:B8}.{2:B8}.{3:B8}" -f $частиАдреса)" | Write-Debug
	return "{0:B8}{1:B8}{2:B8}{3:B8}" -f $частиАдреса
}

function АдресДвоичныйВъДесятичный($АдресДВОИЧ) {
	$АдресДВОИЧ -match '(?<part1>[01]{8})(?<part2>[01]{8})(?<part3>[01]{8})(?<part4>[01]{8})' | Out-Null
	$частиАдреса = 	[Convert]::ToByte($Matches.part1, 2), 
					[Convert]::ToByte($Matches.part2, 2), 
					[Convert]::ToByte($Matches.part3, 2), 
					[Convert]::ToByte($Matches.part4, 2)
	"$("{0:B8}.{1:B8}.{2:B8}.{3:B8}" -f $частиАдреса) > $("{0:D}.{1:D}.{2:D}.{3:D}" -f $частиАдреса)" | Write-Debug
	return "{0:D}.{1:D}.{2:D}.{3:D}" -f $частиАдреса
}

function МаскуВъАдресДвоичный($Маска) {
	$АдресДВОИЧ = "1" * $Маска + "0" * (32 - $Маска)
	$АдресДВОИЧ -match '(?<part1>[01]{8})(?<part2>[01]{8})(?<part3>[01]{8})(?<part4>[01]{8})' | Out-Null
	$частиАдреса = 	$Matches.part1,
	 				$Matches.part2,
	  				$Matches.part3,
	   				$Matches.part4
	"/$Маска > $("{0}.{1}.{2}.{3}" -f $частиАдреса)" | Write-Debug
	return $АдресДВОИЧ
}

function АдресСъМаскойВъГраницы([string]$АдресДЕСЯТ, [byte]$Маска) {
	$АдресДВОИЧ = АдресДесятичныйВъДвоичный $АдресДЕСЯТ
	$НачалоДиапазонаДВОИЧ = $АдресДВОИЧ.Substring(0, $Маска) + "0" * (32 - $Маска)
	$КонецДиапазонаДВОИЧ = $АдресДВОИЧ.Substring(0, $Маска) + "1" * (32 - $Маска)
	"$АдресДЕСЯТ/$Маска >>" | Write-Debug
	return (АдресДвоичныйВъДесятичный $НачалоДиапазонаДВОИЧ), (АдресДвоичныйВъДесятичный $КонецДиапазонаДВОИЧ)
}

function АдресСъМаскойВъДиапазон {
	# [CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline, Position=1)]
		[string]$АдресДЕСЯТ,

		[Parameter(Position=0)]
		[byte]$Маска
	)
	process {
		return (АдресСъМаскойВъГраницы $АдресДЕСЯТ $Маска)[0] + "/" + $Маска
	}
}

<# function АдресСъМаскойВъДиапазон2 {
	param (
		[Parameter(ValueFromPipeline)]
		[string]$АдресДЕСЯТ
	)
	process {
		return (АдресСъМаскойВъГраницы $АдресДЕСЯТ 24)[0] + "/" + 24
	}
}
 #>

<# function ПреобразоватьВъДиапазон([string]$Адрес, [byte]$Маска) {
	$Адрес -match '(?<part1>\d{1,3})\.(?<part2>\d{1,3})\.(?<part3>\d{1,3})\.(?<part4>\d{1,3})' | Out-Null
	Write-Debug "$Адрес >>"
	$АдресДВОИЧ = "{0:B8} {1:B8} {2:B8} {3:B8}" -f [byte]$Matches.part1, [byte]$Matches.part2, [byte]$Matches.part3, [byte]$Matches.part4
	Write-Host $АдресДВОИЧ
	
	Write-Debug "$Маска >>"
	$МаскаДВОИЧ = "." * $Маска
	Write-Host $МаскаДВОИЧ

	# $ДиапазонДВОИЧ = ""
	# for ($i = 0; $i -le 31; $i++) {
	# 	if ($АдресДВОИЧ[$i] -eq "0" -or $МаскаДВОИЧ[$i] -eq "0") {
	# 		$ДиапазонДВОИЧ += "0"
	# 	}
	# 	else {
	# 		$ДиапазонДВОИЧ += "1"
	# 	}
	# }
	# Write-Debug "ДиапазонДВОИЧ >>"
	# Write-Host $ДиапазонДВОИЧ


	$НачалоДиапазонаДВОИЧ -match '(?<part1>[01]{8})(?<part2>[01]{8})(?<part3>[01]{8})(?<part4>[01]{8})' | Out-Null
	Write-Debug "Диапазон >>"
	"{0:D}.{1:D}.{2:D}.{3:D}/$Маска" -f [Convert]::ToByte($Matches.part1, 2), [Convert]::ToByte($Matches.part2, 2), [Convert]::ToByte($Matches.part3, 2), [Convert]::ToByte($Matches.part4, 2)
	
	Write-Debug "Адреса >>"
	"   {0:D}.{1:D}.{2:D}.{3:D}..." -f [Convert]::ToByte($Matches.part1, 2), [Convert]::ToByte($Matches.part2, 2), [Convert]::ToByte($Matches.part3, 2), [Convert]::ToByte($Matches.part4, 2)
	$КонецДиапазонаДВОИЧ -match '(?<part1>[01]{8})(?<part2>[01]{8})(?<part3>[01]{8})(?<part4>[01]{8})' | Out-Null
	"...{0:D}.{1:D}.{2:D}.{3:D}" -f [Convert]::ToByte($Matches.part1, 2), [Convert]::ToByte($Matches.part2, 2), [Convert]::ToByte($Matches.part3, 2), [Convert]::ToByte($Matches.part4, 2)
}
 #>