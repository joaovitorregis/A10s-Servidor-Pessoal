param([Parameter(Mandatory=$true)][ValidatePattern('^[A-Za-z0-9]+$')][string]$DeviceSerial,[Parameter(Mandatory=$true)][ValidatePattern('^\d+\.\d+\.\d+\.\d+$')][string]$ServerAddress)
$ErrorActionPreference='Stop'
$controlAdbPathTask=(Get-Command adb -ErrorAction Stop).Source
$controlScrcpyPathTask=(Get-Command scrcpy -ErrorAction Stop).Source
$controlScriptTask=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'open-control.ps1')).Path
if($controlScriptTask.Contains('"')) { throw 'Caminho inválido.' }
$controlProtocolTask='HKCU:\Software\Classes\a10s-control'
New-Item -Path $controlProtocolTask -Force | Out-Null
Set-Item -LiteralPath $controlProtocolTask -Value 'URL:A10s remote control'
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'DeviceSerial' -Value $DeviceSerial -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'ServerAddress' -Value $ServerAddress -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'AdbPath' -Value $controlAdbPathTask -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'ScrcpyPath' -Value $controlScrcpyPathTask -PropertyType String -Force | Out-Null
New-Item -Path ($controlProtocolTask+'\shell\open\command') -Force | Out-Null
$controlPowerShellTask=Join-Path ([Environment]::GetFolderPath('System')) 'WindowsPowerShell\v1.0\powershell.exe'
if(-not (Test-Path -LiteralPath $controlPowerShellTask -PathType Leaf)) { throw 'Windows PowerShell nao localizado.' }
$controlCommandTask='"'+$controlPowerShellTask+'" -NoProfile -ExecutionPolicy Bypass -File "'+$controlScriptTask+'" -Action "%1"'
Set-Item -LiteralPath ($controlProtocolTask+'\shell\open\command') -Value $controlCommandTask
$controlProgIdTask='HKCU:\Software\Classes\A10sControl.Url'
New-Item -Path ($controlProgIdTask+'\shell\open\command') -Force | Out-Null
Set-Item -LiteralPath $controlProgIdTask -Value 'A10s - Controle remoto'
New-ItemProperty -LiteralPath $controlProgIdTask -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null
Set-Item -LiteralPath ($controlProgIdTask+'\shell\open\command') -Value $controlCommandTask
$controlCapabilitiesTask='HKCU:\Software\A10sControl\Capabilities'
New-Item -Path ($controlCapabilitiesTask+'\URLAssociations') -Force | Out-Null
New-ItemProperty -LiteralPath $controlCapabilitiesTask -Name 'ApplicationName' -Value 'A10s - Controle remoto' -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath $controlCapabilitiesTask -Name 'ApplicationDescription' -Value 'Abre somente o A10s pareado no scrcpy deste notebook.' -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath ($controlCapabilitiesTask+'\URLAssociations') -Name 'a10s-control' -Value 'A10sControl.Url' -PropertyType String -Force | Out-Null
New-Item -Path 'HKCU:\Software\RegisteredApplications' -Force | Out-Null
New-ItemProperty -LiteralPath 'HKCU:\Software\RegisteredApplications' -Name 'A10s - Controle remoto' -Value 'Software\A10sControl\Capabilities' -PropertyType String -Force | Out-Null
# Do not write UserChoice or its protected hash. The user chooses the default in Windows Settings.
if(-not ('A10sAssociationNotification' -as [type])) {
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class A10sAssociationNotification {
  [DllImport("shell32.dll")]
  public static extern void SHChangeNotify(uint eventId, uint flags, IntPtr item1, IntPtr item2);
}
'@
}
# Refresh the Shell's association cache, without launching any application.
[A10sAssociationNotification]::SHChangeNotify(0x08000000,0x1003,[IntPtr]::Zero,[IntPtr]::Zero)
Write-Host 'Controle A10s registrado para este usuário. O navegador pedirá para abrir o aplicativo.'
