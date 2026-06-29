param(
  [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

$RokuRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $RokuRoot "dist\streamvault-roku.zip"
}

$dist = Split-Path -Parent $OutputPath
if (!(Test-Path $dist)) {
  New-Item -ItemType Directory -Path $dist | Out-Null
}

if (Test-Path $OutputPath) {
  Remove-Item -LiteralPath $OutputPath
}

$items = @("manifest", "source", "components", "images") | ForEach-Object {
  Join-Path $RokuRoot $_
}

$missing = $items | Where-Object { !(Test-Path $_) }
if ($missing.Count -gt 0) {
  throw "Missing Roku package paths: $($missing -join ', ')"
}

Push-Location $RokuRoot
try {
  Compress-Archive -Path "manifest", "source", "components", "images" -DestinationPath $OutputPath -Force
}
finally {
  Pop-Location
}

Write-Host "Created $OutputPath"
