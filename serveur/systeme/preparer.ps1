<#
  ÉLAN : crée le fichier .env du serveur avec des secrets neufs (Windows).
  Le plus simple : double-cliquer sur « Préparer le serveur.cmd ».

    powershell -ExecutionPolicy Bypass -File systeme\preparer.ps1 [-Adresse http://ADRESSE-DU-NAS:8000]

  Refuse d'écraser un .env existant : changer les secrets d'un serveur déjà lancé
  couperait l'accès aux données.
#>
param([string]$Adresse)

$ErrorActionPreference = 'Stop'
$dossier = Resolve-Path (Join-Path $PSScriptRoot '..')
$env_ = Join-Path $dossier '.env'

if (Test-Path $env_) {
  Write-Host 'Un fichier .env existe déjà : rien n''est modifié.' -ForegroundColor Yellow
  exit 1
}

while ($Adresse -notmatch '^https?://[^/\s]+') {
  Write-Host 'Adresse du serveur vue depuis le téléphone (VPN ou réseau local).'
  $Adresse = Read-Host 'Par exemple http://192.168.1.20:8000'
}
$Adresse = $Adresse.Trim().TrimEnd('/')
# Port ouvert sur le NAS : celui de l'adresse en http, sinon 8000 (https passe par un proxy).
$port = if ($Adresse -match '^http://[^/:]+:(\d+)') { $Matches[1] } else { '8000' }

$rng = [Security.Cryptography.RandomNumberGenerator]::Create()
function Hasard([int]$octets) {
  $b = New-Object byte[] $octets
  $rng.GetBytes($b)
  -join ($b | ForEach-Object { $_.ToString('x2') })
}
function B64Url([byte[]]$b) { [Convert]::ToBase64String($b).TrimEnd('=').Replace('+', '-').Replace('/', '_') }
$utf8 = New-Object Text.UTF8Encoding($false)

$jwtSecret = Hasard 32
function Jeton([string]$role) {
  $maintenant = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $entete = B64Url $utf8.GetBytes('{"alg":"HS256","typ":"JWT"}')
  $contenu = B64Url $utf8.GetBytes("{`"role`":`"$role`",`"iss`":`"supabase`",`"iat`":$maintenant,`"exp`":$($maintenant + 10 * 365 * 24 * 3600)}")
  $hmac = New-Object Security.Cryptography.HMACSHA256 (, $utf8.GetBytes($jwtSecret))
  $signature = B64Url $hmac.ComputeHash($utf8.GetBytes("$entete.$contenu"))
  "$entete.$contenu.$signature"
}
$anon = Jeton 'anon'
$service = Jeton 'service_role'
$tableau = Hasard 12

$valeurs = @{
  ADRESSE_SERVEUR    = $Adresse
  PORT               = $port
  DASHBOARD_PASSWORD = $tableau
  POSTGRES_PASSWORD  = Hasard 24
  JWT_SECRET         = $jwtSecret
  ANON_KEY           = $anon
  SERVICE_ROLE_KEY   = $service
  PG_META_CRYPTO_KEY = Hasard 24
}
$lignes = [IO.File]::ReadAllLines((Join-Path $dossier 'systeme\modele.env'), $utf8) | ForEach-Object {
  if ($_ -match '^([A-Z_]+)=' -and $valeurs.ContainsKey($Matches[1])) { "$($Matches[1])=$($valeurs[$Matches[1]])" } else { $_ }
}
# Fins de ligne Unix et pas de BOM : le fichier est lu par Docker sur le NAS.
[IO.File]::WriteAllText($env_, (($lignes -join "`n") + "`n"), $utf8)
[IO.File]::WriteAllText((Join-Path $dossier 'connexion-app.txt'), "Adresse du serveur : $Adresse`r`nClé publique : $anon`r`n", $utf8)

Write-Host ''
Write-Host 'Fichier .env créé.' -ForegroundColor Green
Write-Host ''
Write-Host "Tableau de bord : $Adresse"
Write-Host '  identifiant : elan'
Write-Host "  mot de passe : $tableau"
Write-Host ''
Write-Host 'Dans l''app ÉLAN (aussi dans connexion-app.txt) :'
Write-Host "  Adresse du serveur : $Adresse"
Write-Host "  Clé publique : $anon"
