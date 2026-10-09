<#
  ÉLAN : installation sous Windows (sans droits administrateur).

  - Compile la version optimisée (« release ») avec config/supabase.json intégrée.
  - Copie l'application dans %LOCALAPPDATA%\Programs\ELAN.
  - Crée les raccourcis « ÉLAN » dans le menu Démarrer et sur le Bureau.

  Utilisation : double-cliquer sur « Installer ELAN.cmd » à la racine du projet, ou
    powershell -ExecutionPolicy Bypass -File scripts\windows\installer.ps1 [-SkipBuild] [-NoDesktop] [-Uninstall]

  Les données (session, courses, photos) sont dans %APPDATA%\com.example\app_course :
  ni la réinstallation ni la désinstallation n'y touchent.
#>
param(
  [switch]$SkipBuild,
  [switch]$NoDesktop,
  [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$installDir = Join-Path $env:LOCALAPPDATA 'Programs\ELAN'
$startMenu = Join-Path ([Environment]::GetFolderPath('Programs')) 'ÉLAN.lnk'
$desktop = Join-Path ([Environment]::GetFolderPath('Desktop')) 'ÉLAN.lnk'

function Stop-Elan {
  Get-Process -Name 'elan' -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$installDir*" } | ForEach-Object {
    Write-Host "Fermeture d'ÉLAN en cours d'exécution..."
    $_.CloseMainWindow() | Out-Null
    if (-not $_.WaitForExit(5000)) { $_ | Stop-Process -Force }
  }
}

if ($Uninstall) {
  Stop-Elan
  foreach ($path in @($startMenu, $desktop)) { if (Test-Path $path) { Remove-Item $path -Force } }
  if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
  Write-Host 'ÉLAN a été désinstallé. Tes données restent dans %APPDATA%\com.example\app_course.' -ForegroundColor Green
  exit 0
}

$config = Join-Path $root 'config\supabase.json'
if (-not (Test-Path $config)) {
  throw "config\supabase.json est introuvable : copie config\supabase.example.json et remplis-le (voir docs\CLOUD.md)."
}

$release = Join-Path $root 'build\windows\x64\runner\Release'
if (-not $SkipBuild) {
  Write-Host 'Compilation de la version optimisée (1 à 3 minutes)...' -ForegroundColor Cyan
  Push-Location $root
  try {
    # Modules natifs reliés par des jonctions : pas besoin du « Mode développeur » de Windows.
    # (pub get peut échouer en tentant des liens symboliques : les jonctions prennent le relais.)
    flutter pub get 2>&1 | Out-Null
    # Cache de compilation vidé : sinon Flutter peut réutiliser une police d'icônes réduite
    # périmée (icônes récentes invisibles dans l'app).
    Remove-Item -Recurse -Force (Join-Path $root '.dart_tool\flutter_build') -ErrorAction SilentlyContinue
    & (Join-Path $PSScriptRoot 'plugin_links.ps1')
    flutter build windows --release --dart-define-from-file=config/supabase.json
    if ($LASTEXITCODE -ne 0) { throw 'La compilation a échoué (voir les messages ci-dessus).' }
  } finally { Pop-Location }
}
if (-not (Test-Path (Join-Path $release 'elan.exe'))) { throw "elan.exe introuvable dans $release" }

Stop-Elan
Write-Host "Installation dans $installDir..." -ForegroundColor Cyan
if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item -Path (Join-Path $release '*') -Destination $installDir -Recurse -Force

$exe = Join-Path $installDir 'elan.exe'
$shell = New-Object -ComObject WScript.Shell
$targets = @($startMenu)
if (-not $NoDesktop) { $targets += $desktop }
foreach ($path in $targets) {
  $link = $shell.CreateShortcut($path)
  $link.TargetPath = $exe
  $link.WorkingDirectory = $installDir
  $link.IconLocation = "$exe,0"
  $link.WindowStyle = 3  # fenêtre agrandie
  $link.Description = 'ÉLAN · Sport & Impact'
  $link.Save()
}

Write-Host ''
Write-Host 'ÉLAN est installé.' -ForegroundColor Green
Write-Host 'Lance-le depuis le menu Démarrer ou le raccourci du Bureau.'
