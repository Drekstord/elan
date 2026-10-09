<#
  ÉLAN : construction de l'application Android (APK), avec config/supabase.json intégrée.

  Utilisation : double-cliquer sur « Construire APK Android.cmd » à la racine du projet.
  Résultat : dist\ELAN.apk, à installer sur le téléphone (voir docs\INSTALLATION.md).

  Prérequis : Android Studio installé (SDK Android), cf. docs\INSTALLATION.md.
#>
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')

if (-not (Test-Path (Join-Path $root 'config\supabase.json'))) {
  throw "config\supabase.json est introuvable (voir docs\CLOUD.md)."
}

# Java (Gradle) ouvre une connexion locale via un fichier du dossier temporaire ; avec certains
# chemins (nom abrégé « MATMAT~1 », dossier synchronisé…) elle échoue : « Unable to establish
# loopback connection ». Un dossier temporaire court et simple évite le problème.
$javaTmp = Join-Path $env:SystemDrive 'Temp\elan-java'
New-Item -ItemType Directory -Force -Path $javaTmp | Out-Null
$env:JAVA_TOOL_OPTIONS = "-Djdk.net.unixdomain.tmpdir=$javaTmp"
$env:TEMP = $javaTmp
$env:TMP = $javaTmp

Push-Location $root
try {
  Write-Host "Construction de l'APK (la première fois peut prendre 5 à 10 minutes)..." -ForegroundColor Cyan

  # Modules natifs Windows reliés par des jonctions : pas besoin du « Mode développeur »
  # (Flutter les vérifie à chaque commande, même pour Android).
  flutter pub get 2>&1 | Out-Null
  # Cache de compilation vidé : sinon Flutter peut réutiliser une police d'icônes réduite
  # périmée (icônes récentes invisibles dans l'app).
  Remove-Item -Recurse -Force (Join-Path $root '.dart_tool\flutter_build') -ErrorAction SilentlyContinue
  & (Join-Path $PSScriptRoot '..\windows\plugin_links.ps1')

  flutter build apk --release --dart-define-from-file=config/supabase.json
  if ($LASTEXITCODE -ne 0) { throw 'La construction a échoué (voir les messages ci-dessus).' }

  $apk = Join-Path $root 'build\app\outputs\flutter-apk\app-release.apk'
  $dist = Join-Path $root 'dist'
  New-Item -ItemType Directory -Force -Path $dist | Out-Null
  Copy-Item $apk (Join-Path $dist 'ELAN.apk') -Force

  Write-Host ''
  Write-Host "APK prêt : $dist\ELAN.apk" -ForegroundColor Green
  Write-Host 'Copie-le sur ton téléphone puis ouvre-le pour installer ÉLAN (voir docs\INSTALLATION.md).'
} finally { Pop-Location }
