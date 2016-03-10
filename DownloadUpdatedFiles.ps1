<# 
.SYNOPSIS 
    Download the latest Zabbix agent binaries from a URL to a central repository.
.DESCRIPTION 
    Download both 64 and 32 bits binaries from a web server
	to a shared location, where server have read permissions,
	to update/install the agents later.
.NOTES  
    File Name  : DownloadUpdatedFiles.ps1 
    Author     : Rafael Alexandre Feustel Gustmann - esserafael@gmail.com 
    Requires   : PowerShell V3
	Version: 0.01	
#>

function RemSpaces($Str){
	while($Str[0] -eq [Char]32){
		$Str = $Str.Substring(1,$Str.Length-1)
	}
	while($Str[-1] -eq [Char]32){
		$Str = $Str.Substring(0,$Str.Length-1)
	}
	Return $Str
}

# Get configs in config file.
$Dir = Split-Path ($MyInvocation.MyCommand.Path)
$ScriptName = ((($MyInvocation.MyCommand.Name).Split("."))[0]) + ".conf"
$ConfigFile = "$Dir\$ScriptName"
Get-Content -Path $Configfile | % {
	if(($_[0] -ne "#") -and ($_[0] -ne $Null)){
		$Var = $_.Split("=")
		$Var[0] = RemSpaces $Var[0]
		if($Var[1] -match ","){	
			New-Variable -Name $Var[0] -Value $Var[1].Split(",")
		}
		else{			
			$Var[1] = RemSpaces $Var[1]
			New-Variable -Name $Var[0] -Value $Var[1]
		}
	}
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$WebClient = New-Object System.Net.WebClient

#64-bit files
$WebClient.DownloadFile(($URL64+$Agent),($Path64+$Agent))
$WebClient.DownloadFile(($URL64+$Sender),($Path64+$Sender))
$WebClient.DownloadFile(($URL64+$Get),($Path64+$Get))

#32-bit files
$WebClient.DownloadFile(($URL32+$Agent),($Path32+$Agent))
$WebClient.DownloadFile(($URL32+$Sender),($Path32+$Sender))
$WebClient.DownloadFile(($URL32+$Get),($Path32+$Get))