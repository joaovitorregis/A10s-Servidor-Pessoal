param([Parameter(Mandatory=$true)][ValidatePattern('^[A-Za-z0-9]+$')][string]$DeviceSerial,[Parameter(Mandatory=$true)][ValidatePattern('^\d+\.\d+\.\d+\.\d+$')][string]$ServerAddress)
$ErrorActionPreference='Stop'
$controlScriptTask=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'open-control.ps1')).Path
if($controlScriptTask.Contains('"')) { throw 'Caminho inválido.' }
$controlProtocolTask='HKCU:\Software\Classes\a10s-control'
New-Item -Path $controlProtocolTask -Force | Out-Null
Set-Item -LiteralPath $controlProtocolTask -Value 'URL:A10s remote control'
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'DeviceSerial' -Value $DeviceSerial -PropertyType String -Force | Out-Null
New-ItemProperty -LiteralPath $controlProtocolTask -Name 'ServerAddress' -Value $ServerAddress -PropertyType String -Force | Out-Null
New-Item -Path ($controlProtocolTask+'\shell\open\command') -Force | Out-Null
$controlCommandTask='powershell.exe -NoProfile -ExecutionPolicy Bypass -File "'+$controlScriptTask+'" -Action "%1"'
Set-Item -LiteralPath ($controlProtocolTask+'\shell\open\command') -Value $controlCommandTask
Write-Host 'Controle A10s registrado para este usuário. O navegador pedirá para abrir o aplicativo.'
