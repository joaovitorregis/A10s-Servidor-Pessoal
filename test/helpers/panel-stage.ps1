param([string]$Repository,[string]$Stage)
$ErrorActionPreference='Stop'
# Intercept every external boundary before running the public entry point.
# No remote command, HTTP request, Node process or credential access is allowed.
$env:ROTA_SSH_KEY='fixture-key-not-read'
$env:ROTA_SSH_TARGET='fixture@invalid'
$env:ROTA_PANEL_URL='http://127.0.0.1:8787'
function node { $global:LASTEXITCODE=0 }
function ssh {
  # Reproduce only the preparation copies against local repository fixtures.
  # All service, installer, lock and remote test commands remain inert.
  $command=$args[$args.Count-1]
  foreach($copy in [regex]::Matches($command,"cp ([^&]+?) '([^']+)'")) {
    $destination=$copy.Groups[2].Value
    if($destination -notmatch '/.incoming/[^/]+/(.*)$'){throw 'Unexpected preparation copy'}
    $output=Join-Path $Stage $Matches[1]
    $sources=@($copy.Groups[1].Value.Split(' ',[StringSplitOptions]::RemoveEmptyEntries))
    if($destination.EndsWith('/')){New-Item -ItemType Directory -Force $output | Out-Null}
    else {New-Item -ItemType Directory -Force (Split-Path $output) | Out-Null}
    foreach($source in $sources){Copy-Item -LiteralPath (Join-Path $Repository $source) -Destination $output}
  }
  $global:LASTEXITCODE=0
}
function Invoke-WebRequest { }
function scp {
  $source=$args[$args.Count-2]
  $destination=$args[$args.Count-1]
  if($destination -notmatch '^fixture@invalid:.+?/.incoming/[^/]+/(.*)$'){throw 'Unexpected upload destination'}
  $relative=$Matches[1]
  if($relative){
    $output=Join-Path $Stage $relative
    New-Item -ItemType Directory -Force (Split-Path $output) | Out-Null
    Copy-Item -LiteralPath $source -Destination $output
  } else {
    Copy-Item -LiteralPath $source -Destination $Stage -Recurse
  }
  $global:LASTEXITCODE=0
}
& (Join-Path $Repository 'painel.ps1') -Action Install
