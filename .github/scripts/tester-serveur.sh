#!/usr/bin/env bash
# Teste le serveur auto-hébergé (dossier serveur) de bout en bout, comme sur un NAS :
#   1. préparation (.env) et démarrage, migrations appliquées ;
#   2. comptes : inscriptions fermées, compte créé par l'administration, connexion ;
#   3. données : chacun ses courses, fichiers rangés par compte, tableau de bord protégé ;
#   4. (étape « app » lancée par le workflow : le vrai code de synchro de l'app) ;
#   5. sauvegarde, perte totale de la base, restauration.
# Utilisation : tester-serveur.sh demarrer | verifier | restaurer
set -euo pipefail
cd "$(dirname "$0")/../../serveur"

URL=http://localhost:8000
EMAIL=coureuse@exemple.fr
MDP=mot-de-passe-de-test-ci

etape() { echo; echo "=== $*"; }
echec() { echo "ÉCHEC : $*" >&2; docker compose ps -a; docker compose logs --tail=60; exit 1; }
cle() { grep "^$1=" .env | cut -d= -f2-; }

# Attend la fin des migrations (succès exigé) et une porte d'entrée qui répond.
attendre() {
  for _ in $(seq 1 120); do
    etat=$(docker compose ps -a --format '{{.Service}} {{.State}} {{.ExitCode}}' | awk '$1=="migrations"{print $2, $3}')
    case "$etat" in
      "exited 0")
        if curl -fsS -o /dev/null -H "apikey: $(cle ANON_KEY)" "$URL/auth/v1/health"; then return 0; fi ;;
      exited*) echec "migrations : $etat" ;;
    esac
    sleep 5
  done
  echec "serveur pas prêt après 10 minutes"
}

connexion() {
  curl -fsS -X POST "$URL/auth/v1/token?grant_type=password" -H "apikey: $(cle ANON_KEY)" \
    -H 'Content-Type: application/json' -d "{\"email\":\"$EMAIL\",\"password\":\"$MDP\"}" | jq -r .access_token
}

code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }

demarrer() {
  etape "Préparation : secrets générés par l'outil fourni"
  sh systeme/preparer.sh "$URL"
  test -f connexion-app.txt

  etape "Démarrage"
  docker compose up -d
  attendre
  docker compose logs migrations | grep -q "2 fichier(s) appliqué(s)" || echec "les 2 migrations auraient dû passer"

  etape "Redémarrage : aucune migration rejouée"
  docker compose up -d --force-recreate migrations
  attendre
  docker compose logs migrations | grep -q "rien à appliquer" || echec "migrations rejouées"
}

verifier() {
  local anon service jeton uid
  anon=$(cle ANON_KEY)
  service=$(cle SERVICE_ROLE_KEY)

  etape "Inscriptions fermées"
  [ "$(code -X POST "$URL/auth/v1/signup" -H "apikey: $anon" -H 'Content-Type: application/json' \
       -d '{"email":"intrus@exemple.fr","password":"azerty12345"}')" -ge 400 ] || echec "inscription acceptée"

  etape "Compte créé par l'administration (comme dans le tableau de bord), puis connexion"
  curl -fsS -X POST "$URL/auth/v1/admin/users" -H "apikey: $service" -H "Authorization: Bearer $service" \
    -H 'Content-Type: application/json' -d "{\"email\":\"$EMAIL\",\"password\":\"$MDP\",\"email_confirm\":true}" >/dev/null
  jeton=$(connexion)
  [ -n "$jeton" ] && [ "$jeton" != null ] || echec "connexion refusée"
  uid=$(curl -fsS "$URL/auth/v1/user" -H "apikey: $anon" -H "Authorization: Bearer $jeton" | jq -r .id)

  etape "Mauvaise clé refusée"
  [ "$(code "$URL/rest/v1/courses" -H "apikey: x$anon")" = 401 ] || echec "mauvaise clé acceptée"

  etape "Une course enregistrée, visible par son auteur seulement"
  curl -fsS -X POST "$URL/rest/v1/courses" -H "apikey: $anon" -H "Authorization: Bearer $jeton" \
    -H 'Content-Type: application/json' \
    -d '{"id":"ci-semi","title":"Semi de test","race_date":"2026-03-08","distance_m":21100,"duration_s":6100}' >/dev/null
  [ "$(curl -fsS "$URL/rest/v1/courses?select=id" -H "apikey: $anon" -H "Authorization: Bearer $jeton" | jq length)" = 1 ] \
    || echec "course non relue"
  [ "$(curl -fsS "$URL/rest/v1/courses?select=id" -H "apikey: $anon" | jq length)" = 0 ] \
    || echec "courses visibles sans connexion"

  etape "Photo : dans son dossier oui, dans celui d'un autre non"
  printf 'image' > /tmp/photo.jpg
  [ "$(code -X POST "$URL/storage/v1/object/course-media/$uid/photo.jpg" -H "apikey: $anon" \
       -H "Authorization: Bearer $jeton" -H 'Content-Type: image/jpeg' --data-binary @/tmp/photo.jpg)" = 200 ] \
    || echec "envoi de photo refusé"
  [ "$(code -X POST "$URL/storage/v1/object/course-media/autre/photo.jpg" -H "apikey: $anon" \
       -H "Authorization: Bearer $jeton" -H 'Content-Type: image/jpeg' --data-binary @/tmp/photo.jpg)" -ge 400 ] \
    || echec "photo acceptée dans le dossier d'un autre"

  etape "Tableau de bord protégé par mot de passe"
  [ "$(code "$URL/")" = 401 ] || echec "tableau de bord ouvert sans mot de passe"
  for _ in $(seq 1 24); do
    c=$(code -u "elan:$(cle DASHBOARD_PASSWORD)" "$URL/project/default")
    [ "$c" = 200 ] && break
    sleep 5
  done
  [ "$c" = 200 ] || echec "tableau de bord inaccessible avec le mot de passe ($c)"

  # Pour l'étape suivante (code de l'app).
  {
    echo "ELAN_SERVEUR_URL=$URL"
    echo "ELAN_SERVEUR_CLE=$anon"
    echo "ELAN_EMAIL=$EMAIL"
    echo "ELAN_MOT_DE_PASSE=$MDP"
  } >> "${GITHUB_ENV:-/dev/null}"
}

restaurer() {
  local anon jeton
  anon=$(cle ANON_KEY)

  etape "Service de sauvegarde en marche (programmé, sans redémarrages)"
  sleep 10
  [ "$(docker inspect -f '{{.State.Status}} {{.RestartCount}}' "$(docker compose ps -q sauvegarde)")" = "running 0" ]     || echec "le service de sauvegarde redémarre en boucle"
  docker compose logs sauvegarde | grep -q "Sauvegarde chaque jour à 03:00" || echec "sauvegarde non programmée"

  etape "Sauvegarde immédiate"
  docker compose exec -T sauvegarde sh /sauvegarder.sh maintenant
  sauvegarde=$(ls -1t donnees/sauvegardes/elan-*.sql.gz | head -1)
  [ -n "$sauvegarde" ] || echec "aucune sauvegarde"

  etape "Perte totale de la base"
  docker compose down
  sudo rm -rf donnees/base
  docker compose up -d
  attendre
  [ "$(code -X POST "$URL/auth/v1/token?grant_type=password" -H "apikey: $anon" -H 'Content-Type: application/json' \
       -d "{\"email\":\"$EMAIL\",\"password\":\"$MDP\"}")" = 400 ] || echec "le compte aurait dû disparaître"

  etape "Restauration"
  sh systeme/restaurer.sh "$sauvegarde" --oui
  jeton=$(connexion)
  [ -n "$jeton" ] && [ "$jeton" != null ] || echec "connexion impossible après restauration"
  ids=$(curl -fsS "$URL/rest/v1/courses?select=id&order=id" -H "apikey: $anon" -H "Authorization: Bearer $jeton" | jq -c 'map(.id)')
  [ "$ids" = '["ci-restos","ci-semi"]' ] || echec "courses après restauration : $ids"
  uid=$(curl -fsS "$URL/auth/v1/user" -H "apikey: $anon" -H "Authorization: Bearer $jeton" | jq -r .id)
  [ "$(curl -fsS "$URL/storage/v1/object/course-media/$uid/docs/facture-ci.pdf" -H "apikey: $anon" \
       -H "Authorization: Bearer $jeton" | head -c 8)" = '%PDF-1.4' ] || echec "justificatif perdu"

  etape "Tout est bon"
}

"$@"
