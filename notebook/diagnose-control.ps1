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
if(-not ('A10sAssociationQuery' -as [type])) {
  Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class A10sAssociationQuery {
  [DllImport("shlwapi.dll", CharSet=CharSet.Unicode, ExactSpelling=true)]
  public static extern int AssocQueryStringW(uint flags, uint kind, string association, string verb, StringBuilder output, ref uint length);
  public static int QueryDefault(uint kind, StringBuilder output, ref uint length) {
    return AssocQueryStringW(0x1000, kind, "a10s-control", null, output, ref length);
  }
}
'@
}
foreach($controlQueryKindTask in @(1,2,4)) {
  $controlQueryBufferTask=New-Object System.Text.StringBuilder 1024
  [uint32]$controlQueryLengthTask=1024
  $controlQueryResultTask=[A10sAssociationQuery]::QueryDefault($controlQueryKindTask,$controlQueryBufferTask,[ref]$controlQueryLengthTask)
  $controlDiagnosticsTask += [pscustomobject]@{check=('WindowsAssociation_'+$controlQueryKindTask);ok=($controlQueryResultTask -eq 0)}
  Write-Host ('Association '+$controlQueryKindTask+': HRESULT='+$controlQueryResultTask+' value='+$controlQueryBufferTask.ToString())
}
$controlLogTask=Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'A10sControl\control.log'
$controlDiagnosticsTask | Format-Table -AutoSize
if(Test-Path -LiteralPath $controlLogTask) {Get-Content -LiteralPath $controlLogTask -Tail 8} else {Write-Host 'Nenhuma execucao registrada pelo lancador atualizado.'}
if($controlDiagnosticsTask | Where-Object {-not $_.ok}) {exit 1}
