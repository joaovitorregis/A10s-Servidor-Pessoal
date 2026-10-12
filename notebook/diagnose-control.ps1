$ErrorActionPreference='Stop'
# Read-only diagnostics. Does not launch scrcpy or activate remote debugging.
$controlDiagnosticsTask=@()
foreach($controlFileTask in @('open-control.ps1','install-control.ps1')) {
  $controlErrorsTask=$null; $controlTokensTask=$null
  [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot $controlFileTask),[ref]$controlTokensTask,[ref]$controlErrorsTask) | Out-Null
  $controlDiagnosticsTask += [pscustomobject]@{check=$controlFileTask;ok=($controlErrorsTask.Count -eq 0)}
}
$controlSettingsTask=Get-ItemProperty -LiteralPath 'HKCU:\Software\Classes\a10s-control'
foreach($controlPropertyTask in @('AdbPath','ScrcpyPath')) {
  $controlPathTask=$controlSettingsTask.$controlPropertyTask
  $controlDiagnosticsTask += [pscustomobject]@{check=$controlPropertyTask;ok=($controlPathTask -and (Test-Path -LiteralPath $controlPathTask -PathType Leaf))}
}
$controlRegisteredTask=(Get-Item -LiteralPath 'HKCU:\Software\Classes\a10s-control\shell\open\command').GetValue('')
$controlDiagnosticsTask += [pscustomobject]@{check='ProtocolHandler';ok=($controlRegisteredTask.Contains((Join-Path $PSScriptRoot 'open-control.ps1')))}
$controlLogTask=Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'A10sControl\control.log'
$controlDiagnosticsTask | Format-Table -AutoSize
if(Test-Path -LiteralPath $controlLogTask) {Get-Content -LiteralPath $controlLogTask -Tail 8} else {Write-Host 'Nenhuma execucao registrada pelo lancador atualizado.'}
if($controlDiagnosticsTask | Where-Object {-not $_.ok}) {exit 1}
