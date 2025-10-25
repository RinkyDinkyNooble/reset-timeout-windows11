$GUIDs = @{
	"hibernate" = "9d7815a6-7ee4-497e-8888-515a05f02364"
	"monitor" = "3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
	"standby" = "29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
}
$Pattern = "Current (\w+) Power Setting Index: (\S+)"
$MadeChanges = $false
$FinalMessage = ""

function Get-Number-From-Hexadecimal {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Hexadecimal
    )
    $Number = [UInt32]$Hexadecimal
    return $Number
}

function Get-Hexadecimals-From-GUID {
    param(
        [Parameter(Mandatory=$true)]
        [string]$GUID
    )
    $String = powercfg /Q | Select-String $GUID -Context 0, 7
    $HexadecimalHashTable = @{}
    foreach ($Match in $String) {
        $Line = $Match.Context.PostContext[5..6]
        $LineMatches = $Line | Select-String -Pattern $Pattern
        foreach ($Value in $LineMatches) {
            $PowerType = $Value.Matches.Groups[1].Value 
            $Hexadecimal = $Value.Matches.Groups[2].Value
            $HexadecimalHashTable[$PowerType] = $Hexadecimal
        }
    }
    return $HexadecimalHashTable
}

function Update-MadeChanges {
	param(
		[Parameter(Mandatory=$true)]
		[string]$String
	)
	$script:FinalMessage += "$String`n"
	if ($script:MadeChanges -ne $true) {
		$script:MadeChanges = $true
	}
}

function Set-Timeout-Reset {
	param(
		[Parameter(Mandatory=$true)]
		[string]$Name,
		[string]$GUID
	)
	$HashTable = Get-Hexadecimals-From-GUID $GUID
	$ACNumber = Get-Number-From-Hexadecimal $HashTable["AC"]
	$DCNumber = Get-Number-From-Hexadecimal $HashTable["DC"]
	if ($ACNumber -ne 0) {
		Invoke-Expression "powercfg -change -${Name}-timeout-ac 0"
		Update-MadeChanges "GUID: $GUID`nName: $Name`nType: AC"
	}
	if ($DCNumber -ne 0) {
		Invoke-Expression "powercfg -change -${Name}-timeout-dc 0"
		Update-MadeChanges "GUID: $GUID`nName: $Name`nType: DC"
	}
}

foreach ($Name in $GUIDs.Keys) {
	Set-Timeout-Reset $Name $GUIDs[$Name]
}

if ($MadeChanges) {
	Write-Host $FinalMessage
	$Toast = New-Object -ComObject WScript.Shell
	$Toast.Popup($FinalMessage, 0, "Successfully Reset Timeouts", 0x0)
}
