param([string]$Action='a10s-control://open')
$ErrorActionPreference='Stop'
$controlLogFolderTask=Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'A10sControl'
$controlLogTask=Join-Path $controlLogFolderTask 'control.log'
try {
  New-Item -ItemType Directory -Path $controlLogFolderTask -Force | Out-Null
  Add-Content -LiteralPath $controlLogTask -Value ((Get-Date -Format o)+' handler_started')
  if($Action -notin @('a10s-control://open','a10s-control://open/')) { throw 'Acao de controle invalida.' }
  $controlSettingsTask=Get-ItemProperty -LiteralPath 'HKCU:\Software\Classes\a10s-control'
  $controlExpectedSerialTask=$controlSettingsTask.DeviceSerial
  $controlAddressTask=$controlSettingsTask.ServerAddress
  if($controlExpectedSerialTask -notmatch '^[A-Za-z0-9]+$' -or $controlAddressTask -notmatch '^\d+\.\d+\.\d+\.\d+$') { throw 'Configuracao do controle invalida.' }
  $controlDevicePatternTask='^('+[regex]::Escape($controlAddressTask)+':\d+|adb-'+[regex]::Escape($controlExpectedSerialTask)+'[^\s]*)\s+device$'
  $controlMdnsPatternTask='^adb-'+[regex]::Escape($controlExpectedSerialTask)+'[^\s]*\s+_adb-tls-connect\._tcp\s+(\d+\.\d+\.\d+\.\d+:\d+)$'
  $controlAdbTask=$controlSettingsTask.AdbPath
  $controlScrcpyTask=$controlSettingsTask.ScrcpyPath
  foreach($controlExecutableTask in @($controlAdbTask,$controlScrcpyTask)) {
    if(-not $controlExecutableTask -or -not (Test-Path -LiteralPath $controlExecutableTask -PathType Leaf)) { throw 'ADB ou scrcpy nao localizado. Execute novamente install-control.ps1.' }
  }
  $controlDeviceTask=$null
  & $controlAdbTask start-server | Out-Null
  $controlDevicesTask=& $controlAdbTask devices
  foreach($controlLineTask in $controlDevicesTask) {
    if($controlLineTask -match $controlDevicePatternTask) {
      $controlCandidateTask=$Matches[1]
      $controlSerialTask=(& $controlAdbTask -s $controlCandidateTask shell getprop ro.serialno | Out-String).Trim()
      if($controlSerialTask -eq $controlExpectedSerialTask) { $controlDeviceTask=$controlCandidateTask; break }
    }
  }
  if(-not $controlDeviceTask) {
    foreach($controlLineTask in (& $controlAdbTask mdns services)) {
      if($controlLineTask -match $controlMdnsPatternTask) {
        $controlCandidateTask=$Matches[1]
        & $controlAdbTask connect $controlCandidateTask | Out-Null
        $controlSerialTask=(& $controlAdbTask -s $controlCandidateTask shell getprop ro.serialno | Out-String).Trim()
        if($controlSerialTask -eq $controlExpectedSerialTask) { $controlDeviceTask=$controlCandidateTask; break }
      }
    }
  }
  if(-not $controlDeviceTask) { throw 'A10s não conectado. Ative Depuração sem fio e conecte o dispositivo pareado no ADB.' }
  Add-Content -LiteralPath $controlLogTask -Value ((Get-Date -Format o)+' device_verified; launching_scrcpy')
  & $controlScrcpyTask -s $controlDeviceTask --window-title 'A10s - Controle remoto'
  if($LASTEXITCODE -ne 0) { throw 'O scrcpy encerrou com erro.' }
  Add-Content -LiteralPath $controlLogTask -Value ((Get-Date -Format o)+' scrcpy_closed_successfully')
} catch {
  try { Add-Content -LiteralPath $controlLogTask -Value ((Get-Date -Format o)+' error: '+$_.Exception.Message) } catch {}
  Write-Host $_.Exception.Message -ForegroundColor Red
  Write-Host ('Registro: '+$controlLogTask)
  Read-Host 'Pressione Enter para fechar'
  exit 1
}
