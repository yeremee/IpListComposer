class IPАдрес {
	[byte[]] $байты
	[byte] $маска

	IPАдрес([string] $адрес) {
		Write-Debug "Создание объекта для адреса/диапазона '$адрес'"

		# Адрес в десятичном виде
		if ($адрес -match '^(?<part1>\d{1,3})\.(?<part2>\d{1,3})\.(?<part3>\d{1,3})\.(?<part4>\d{1,3})(?:/(?<mask>\d{1,2}))?$') {
			try {
				$частиАдреса = 	[byte]$Matches.part1,
								[byte]$Matches.part2,
								[byte]$Matches.part3,
								[byte]$Matches.part4,
								($null -ne $Matches.mask ? [byte]$Matches.mask : 32)
				$this.байты = $частиАдреса[0..3]
			}
			catch {
				throw "Строка '$адрес' содержит значение, превышающее 255, и не является действительным IP-адресом (диапазоном адресов)!"
			}

			$this.маска = $частиАдреса[4]
			if ($this.маска -notin 1..32) {
				throw "Строка '$адрес' содержит маску за пределами интервала от 1 до 32, и не является действительным IP-адресом (диапазоном адресов)!"
			}

			if ($this.адресДвоич() -ne $this.завершённыйАдресДвоич($this.маска, "0")) {
				throw "Строка '$адрес' содержит несогласующуюся с адресом маску, и не является действительным IP-адресом (диапазоном адресов)!"
			}
		# Адрес в двоичном виде
		} elseif ($адрес -match '^(?<part1>[01]{8})(?<part2>[01]{8})(?<part3>[01]{8})(?<part4>[01]{8})$') {
			$this.байты = $this.адресДесят($адрес)[0..3]
			$this.маска = 32
		# Неверный формат адреса
		} else {
			throw "Строка '$адрес' имеет формат, не являющийся действительным IP-адресом (диапазоном адресов)!"
		}
	}

	IPАдрес([string] $адрес, [byte] $маска) {
		Write-Debug "Создание объекта для адреса '$адрес' и маски '$маска'"

		if ($адрес -match '^(?<part1>\d{1,3})\.(?<part2>\d{1,3})\.(?<part3>\d{1,3})\.(?<part4>\d{1,3})$') {
			try {
				$частиАдреса = 	[byte]$Matches.part1,
								[byte]$Matches.part2,
								[byte]$Matches.part3,
								[byte]$Matches.part4
			}
			catch {
				throw "Строка '$адрес' содержит значение, превышающее 255, и не является действительным IP-адресом!"
			}
		}
		else {
			throw "Строка '$адрес' имеет формат, не являющийся действительным IP-адресом!"
		}

		$this.байты = $частиАдреса[0..3]

		if ($маска -notin 1..32) {
			throw "Маска '$маска' лежит за пределами интервала от 1 до 32!"
		}
		$this.маска = $маска

		$адресДвоич = $this.завершённыйАдресДвоич($this.маска, "0")
		$this.байты = $this.адресДесят($адресДвоич)[0..3]
	}

	static [hashtable[]] $вычислимыеСвойства = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'СтандартнаяФорма'
            Value      = { ("{0:D}.{1:D}.{2:D}.{3:D}" + ($this.маска -ne 32 ? "/{4:D}" : "")) -f ($this.байты[0..3] + $this.маска) }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'ДополненнаяФорма'
            Value      = { "{0:D3}.{1:D3}.{2:D3}.{3:D3}/{4:D2}" -f ($this.байты[0..3] + $this.маска) }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'ДвоичнаяФорма'
            Value      = { 
				$адресДвоич = "{0:B8}.{1:B8}.{2:B8}.{3:B8}" -f $this.байты[0..3]
				$счётчик = $this.маска
				for ($позиция = 0; $позиция -lt $адресДвоич.Length; $позиция++) {
					if ($адресДвоич[$позиция] -ne ".") {
						$счётчик--
					}
					if ($счётчик -eq -1) {
						return $адресДвоич.Insert($позиция, "'")
					}
				}
				return $адресДвоич + "'"
			}
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'МаскаДиапазона'
            Value      = { $this.маска }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'НачалоДиапазона'
            Value      = { [IPАдрес]::new($this.завершённыйАдресДвоич($this.маска, "0")) }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'КонецДиапазона'
            Value      = { [IPАдрес]::new($this.завершённыйАдресДвоич($this.маска, "1")) }
        }
    )

    static IPАдрес() {
        $имяТипа = [IPАдрес].Name
        foreach ($свойство in [IPАдрес]::вычислимыеСвойства) {
            Update-TypeData -TypeName $имяТипа -Force @свойство
        }
    }

	[string] ToString() {
		return "[$([IPАдрес].Name)] $($this.СтандартнаяФорма)"
	}

	hidden [string] адресДвоич() {
		return "{0:B8}{1:B8}{2:B8}{3:B8}" -f $this.байты[0..3]
	}

	hidden [string] завершённыйАдресДвоич([byte] $маска, [string] $бит) {
		return $this.адресДвоич().Substring(0, $маска) + $бит * (32 - $маска)
	}

	hidden [byte[]] адресДесят([string] $адресДвоич) {
		$адресДвоич -match '^(?<part1>[01]{8})(?<part2>[01]{8})(?<part3>[01]{8})(?<part4>[01]{8})$'
		return 	[Convert]::ToByte($Matches.part1, 2), 
				[Convert]::ToByte($Matches.part2, 2), 
				[Convert]::ToByte($Matches.part3, 2), 
				[Convert]::ToByte($Matches.part4, 2)
	}
}