<#
  Prépare les liens vers les modules natifs Windows sans « Mode développeur ».

  Flutter relie chaque module natif dans windows\flutter\ephemeral\.plugin_symlinks par un
  lien symbolique, ce qui exige le Mode développeur de Windows. Une « jonction » de dossier
  fait le même travail sans aucun droit particulier, et Flutter conserve un lien déjà présent.
  Ce script crée ces jonctions d'après .flutter-plugins-dependencies.
#>
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$deps = Join-Path $root '.flutter-plugins-dependencies'
if (-not (Test-Path $deps)) { throw '.flutter-plugins-dependencies introuvable : lance « flutter pub get ».' }

$plugins = (Get-Content $deps -Raw -Encoding UTF8 | ConvertFrom-Json).plugins.windows
$linkDir = Join-Path $root 'windows\flutter\ephemeral\.plugin_symlinks'
New-Item -ItemType Directory -Force -Path $linkDir | Out-Null

foreach ($plugin in $plugins) {
  $link = Join-Path $linkDir $plugin.name
  $target = $plugin.path.TrimEnd('\', '/')
  if (Test-Path $link) {
    $item = Get-Item $link -Force
    if ($item.Target -and ($item.Target -replace '[\\/]+$', '') -eq $target) { continue }
    $item.Delete()
  }
  New-Item -ItemType Junction -Path $link -Target $target | Out-Null
  Write-Host "  module $($plugin.name) relié"
}
