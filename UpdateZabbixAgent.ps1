<# 
.SYNOPSIS 
    Checks and update/install the Zabbix agent files on Windows servers.
.DESCRIPTION 
    The script verifies if the Zabbix service exists on the server, if so,
	it compares the verions of the local agent file with the network updated
	files. If the network files version are greater than the local files, the
	local files are updated and the service restarted. Also, if there is no
	Zabbix service installed, it will install the updated agent. It is meant
	to be run as a scheduled task on servers.
.NOTES  
    File Name  : UpdateZabbixAgent.ps1 
    Author     : Rafael Alexandre Feustel Gustmann - esserafael@gmail.com 
    Requires   : PowerShell V3
	Version: 0.01	
#>

# Updates Zabbix files.
function UpdateZabbixAgent($UpdatedSource, $LocalDest){
	$TimeOut = 30
	$SecondsToWait = 5
	Stop-Service $ServiceName -Force
	While((Get-Service $ServiceName).Status -ne "Stopped" -or $TimePast -ge $TimeOut){		
		Start-Sleep -Seconds $SecondsToWait
		$TimePast += $SecondsToWait
	}
	Copy-Item $UpdatedSource $LocalDest -Force
	if((Get-Service $ServiceName).Status -eq "Stopped"){
		Start-Service $ServiceName
	}
}

# Installs Zabbix.
function InstallZabbixAgent{
	New-Item $LocalFiles -Type Directory	
	$TargetInstall = $env:SystemDrive + $LocalFiles
	Copy-Item ($UpdatedFiles + "\*") $LocalFiles -Recurse -Force
	$AgentConfFile = $LocalFiles + "\" + $ZabbixConf
	$FQDN = (Get-WmiObject Win32_ComputerSystem).DNSHostName + "." + (Get-WmiObject Win32_ComputerSystem).Domain
	
	$ConfigContent = Get-Content $AgentConfFile
	$ConfigContent | % {
		if($_ -like "Hostname*"){
			$ConfigContent[$ConfigContent.IndexOf($_)] += $FQDN
		}
	}
	Set-Content $AgentConfFile -Value $ConfigContent
		
	$InstallStr = $LocalFiles + "\" + $Agent + " -c " + $AgentConfFile + " --install"
	$StartStr = $LocalFiles + "\" + $Agent + " -c " + $AgentConfFile + " --start"
	
	Invoke-Expression -Command $InstallStr 2>($LocalFiles + "\zabbix_install.log")
	Invoke-Expression -Command $StartStr 2>($LocalFiles + "\zabbix_start.log")
}

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

# Check O.S. architecture.
if((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -like "64*"){
	$UpdatedFiles = $UpdatedFiles64
}
else{
	$UpdatedFiles = $UpdatedFiles32
}

# Check if service exists.
if(Get-Service -Name $ServiceName -ErrorAction SilentlyContinue){

	# Check 'agentd' version.
	if((Get-Item ($UpdatedFiles + "\" + $Agent)).VersionInfo.FileVersion -gt (Get-Item ($LocalFiles + "\" + $Agent)).VersionInfo.FileVersion){
		UpdateZabbixAgent ($UpdatedFiles + "\" + $Agent) ($LocalFiles + "\" + $Agent)
	}

	# Check 'sender' version.
	if((Get-Item ($UpdatedFiles + "\" + $Sender)).VersionInfo.FileVersion -gt (Get-Item ($LocalFiles + "\" + $Sender)).VersionInfo.FileVersion){
		UpdateZabbixAgent ($UpdatedFiles + "\" + $Sender) ($LocalFiles + "\" + $Sender)
	}

	# Check 'get' version.
	if((Get-Item ($UpdatedFiles + "\" + $Get)).VersionInfo.FileVersion -gt (Get-Item ($LocalFiles + "\" + $Get)).VersionInfo.FileVersion){
		UpdateZabbixAgent ($UpdatedFiles + "\" + $Get) ($LocalFiles + "\" + $Get)
	}
}
else{	
	InstallZabbixAgent	
}