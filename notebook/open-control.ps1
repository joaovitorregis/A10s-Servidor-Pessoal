param([string]$Action='a10s-control://open')
$ErrorActionPreference='Stop'
if($Action -notin @('a10s-control://open','a10s-control://open/')) { throw 'Ação de controle inválida.' }
$controlSettingsTask=Get-ItemProperty -LiteralPath 'HKCU:\Software\Classes\a10s-control'
$controlExpectedSerialTask=$controlSettingsTask.DeviceSerial
$controlAddressTask=$controlSettingsTask.ServerAddress
if($controlExpectedSerialTask -notmatch '^[A-Za-z0-9]+$' -or $controlAddressTask -notmatch '^\d+\.\d+\.\d+\.\d+$') { throw 'Configuração do controle inválida.' }
$controlDevicePatternTask='^('+[regex]::Escape($controlAddressTask)+':\d+|adb-'+[regex]::Escape($controlExpectedSerialTask)+'[^\s]*)\s+device$'
$controlMdnsPatternTask='^adb-'+[regex]::Escape($controlExpectedSerialTask)+'[^\s]*\s+_adb-tls-connect\._tcp\s+(\d+\.\d+\.\d+\.\d+:\d+)$'
$controlAdbTask=(Get-Command adb -ErrorAction Stop).Source
$controlScrcpyTask=(Get-Command scrcpy -ErrorAction Stop).Source
$controlDeviceTask=$null
try {
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
  & $controlScrcpyTask -s $controlDeviceTask --window-title 'A10s - Controle remoto'
  if($LASTEXITCODE -ne 0) { throw 'O scrcpy encerrou com erro.' }
} catch {
  Write-Host $_.Exception.Message -ForegroundColor Red
  Read-Host 'Pressione Enter para fechar'
  exit 1
}
