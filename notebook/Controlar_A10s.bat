@echo off
setlocal
title A10s - Controle remoto
set "A10S_CONTROL_BAT=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$lines=Get-Content -LiteralPath $env:A10S_CONTROL_BAT; $start=[Array]::IndexOf($lines,'# A10S_POWERSHELL'); if($start -lt 0){exit 1}; & ([scriptblock]::Create(($lines[($start+1)..($lines.Length-1)] -join [Environment]::NewLine)))"
exit /b %errorlevel%
# A10S_POWERSHELL
$ErrorActionPreference='Stop'
try {
  $settings=Get-ItemProperty -LiteralPath 'HKCU:\Software\Classes\a10s-control'
  $serial=$settings.DeviceSerial; $address=$settings.ServerAddress
  if($serial -notmatch '^[A-Za-z0-9]+$' -or $address -notmatch '^\d+\.\d+\.\d+\.\d+$') {throw 'Configuracao do A10s nao encontrada neste notebook.'}
  $adb=$settings.AdbPath; $scrcpy=$settings.ScrcpyPath
  foreach($exe in @($adb,$scrcpy)) {if(-not $exe -or -not (Test-Path -LiteralPath $exe -PathType Leaf)){throw 'ADB ou scrcpy nao encontrado neste notebook.'}}
  & $adb start-server | Out-Null
  $device=$null
  $pattern='^('+[regex]::Escape($address)+':\d+|adb-'+[regex]::Escape($serial)+'[^\s]*)\s+device$'
  foreach($line in (& $adb devices)) {
    if($line -match $pattern) {
      $candidate=$Matches[1]
      if(((& $adb -s $candidate shell getprop ro.serialno | Out-String).Trim()) -eq $serial){$device=$candidate;break}
    }
  }
  if(-not $device) {
    $pattern='^adb-'+[regex]::Escape($serial)+'[^\s]*\s+_adb-tls-connect\._tcp\s+(\d+\.\d+\.\d+\.\d+:\d+)$'
    foreach($line in (& $adb mdns services)) {
      if($line -match $pattern) {
        $candidate=$Matches[1]; & $adb connect $candidate | Out-Null
        if(((& $adb -s $candidate shell getprop ro.serialno | Out-String).Trim()) -eq $serial){$device=$candidate;break}
      }
    }
  }
  if(-not $device){throw 'A10s desconectado. Ative Depuracao sem fio e conecte o dispositivo pareado ao ADB.'}
  & $scrcpy -s $device --window-title 'A10s - Controle remoto'
  if($LASTEXITCODE -ne 0){throw 'O scrcpy encerrou com erro.'}
} catch {
  Write-Host $_.Exception.Message -ForegroundColor Red
  Read-Host 'Pressione Enter para fechar'
  exit 1
}
