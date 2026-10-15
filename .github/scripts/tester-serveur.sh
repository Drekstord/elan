#!/usr/bin/env bash
# Teste le serveur ÉLAN (dossier serveur) de bout en bout, comme sur un NAS :
#   demarrer   construit l'image, lance « docker compose up », attend la page d'accueil
#   verifier   premier compte, comptes du propriétaire, cloisonnement, synchro, fichiers
#   durer      redémarrage sans perte, sauvegarde, suppression d'un compte
# Entre « verifier » et « durer », le workflow lance le vrai code de l'app contre ce serveur.
set -euo pipefail
cd "$(dirname "$0")/../../serveur"

URL=http://localhost:8000
PROPRIO=proprietaire@exemple.fr
PROCHE=proche@exemple.fr
MDP=mot-de-passe-ci-1
MDP2=mot-de-passe-ci-2

etape() { echo; echo "=== $*"; }
echec() { echo "ÉCHEC : $*" >&2; docker compose ps -a; docker compose logs --tail=80; exit 1; }
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
json() { curl -fsS -H 'Content-Type: application/json' "$@"; }
attendre() {
  for _ in $(seq 1 60); do
    curl -fsS -o /dev/null "$URL/api/health" 2>/dev/null && return 0
    sleep 2
  done
  echec "le serveur ne répond pas"
}
# connexion <email> <mot de passe> : affiche « jeton identifiant »
connexion() {
  json -X POST "$URL/api/collections/users/auth-with-password" -d "{\"identity\":\"$1\",\"password\":\"$2\"}" \
    | jq -r '"\(.token) \(.record.id)"'
}
attendu() { [ "$2" = "$3" ] || echec "$1 : attendu $3, obtenu $2"; }

demarrer() {
  etape "Construction de l'image"
  docker build -q -t ghcr.io/drekstord/elan-serveur:1 image

  etape "Démarrage : docker compose up, rien d'autre"
  docker compose up -d
  attendre
  curl -fsS "$URL/" | grep -q "Serveur personnel" || echec "page d'accueil absente"
  attendu "état initial" "$(json "$URL/api/elan/etat" | jq -cS .)" '{"code":true,"premierCompte":true,"serveur":"elan","version":1}'

  etape "Code d'installation : dans donnees et dans le journal ; serveur sans droits d'administrateur"
  sudo test -s donnees/code-premier-compte.txt || echec "fichier du code d'installation absent"
  # Journal lu en entier d'abord : « grep -q » couperait la lecture et ferait échouer la commande.
  local journal
  journal=$(docker compose logs elan)
  grep -q "code d'installation $(sudo cat donnees/code-premier-compte.txt | tr -d '[:space:]')" <<<"$journal" \
    || echec "code d'installation absent du journal"
  attendu "propriétaire des données" "$(docker compose exec -T elan stat -c %U /donnees/data.db)" elan
  attendu "utilisateur du serveur" "$(docker compose exec -T elan ps -o user,pid | awk '$2 == 1 {print $1}')" elan
}

verifier() {
  local jp ip jq_ iq

  etape "Pas d'inscription libre ; premier compte = propriétaire, une seule fois"
  attendu "inscription libre" "$(code -X POST "$URL/api/collections/users/records" -H 'Content-Type: application/json' \
    -d "{\"email\":\"intrus@exemple.fr\",\"password\":\"$MDP\",\"passwordConfirm\":\"$MDP\"}")" 400
  attendu "mot de passe trop court" "$(code -X POST "$URL/api/elan/premier-compte" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$PROPRIO\",\"password\":\"court\"}")" 400
  local installation
  installation=$(sudo cat donnees/code-premier-compte.txt | tr -d '[:space:]')
  attendu "premier compte sans code" "$(code -X POST "$URL/api/elan/premier-compte" -H 'Content-Type: application/json' \
    -d "{\"email\":\"intrus@exemple.fr\",\"password\":\"$MDP\"}")" 401
  attendu "premier compte, mauvais code" "$(code -X POST "$URL/api/elan/premier-compte" -H 'Content-Type: application/json' \
    -d "{\"email\":\"intrus@exemple.fr\",\"password\":\"$MDP\",\"code\":\"ABCD2345\"}")" 401
  attendu "premier compte" "$(code -X POST "$URL/api/elan/premier-compte" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$PROPRIO\",\"password\":\"$MDP\",\"code\":\"${installation,,}\"}")" 204
  sudo test ! -e donnees/code-premier-compte.txt || echec "code d'installation encore présent après le premier compte"
  attendu "second « premier compte »" "$(code -X POST "$URL/api/elan/premier-compte" -H 'Content-Type: application/json' \
    -d "{\"email\":\"intrus@exemple.fr\",\"password\":\"$MDP\",\"code\":\"$installation\"}")" 401
  attendu "état" "$(json "$URL/api/elan/etat" | jq .premierCompte)" false
  read -r jp ip < <(connexion "$PROPRIO" "$MDP")
  [ -n "$ip" ] && [ "$ip" != null ] || echec "connexion du propriétaire"

  etape "Le propriétaire ajoute un proche ; le proche ne peut ni créer de compte ni se nommer propriétaire"
  json -X POST "$URL/api/collections/users/records" -H "Authorization: $jp" \
    -d "{\"email\":\"$PROCHE\",\"password\":\"$MDP\",\"passwordConfirm\":\"$MDP\"}" >/dev/null
  read -r jq_ iq < <(connexion "$PROCHE" "$MDP")
  attendu "compte créé par un proche" "$(code -X POST "$URL/api/collections/users/records" -H "Authorization: $jq_" \
    -H 'Content-Type: application/json' -d "{\"email\":\"x@exemple.fr\",\"password\":\"$MDP\",\"passwordConfirm\":\"$MDP\"}")" 400
  code -X PATCH "$URL/api/collections/users/records/$iq" -H "Authorization: $jq_" -H 'Content-Type: application/json' \
    -d '{"proprietaire":true}' >/dev/null
  attendu "proche devenu propriétaire" "$(json "$URL/api/collections/users/records/$iq" -H "Authorization: $jq_" | jq .proprietaire)" false
  attendu "comptes vus par le proche" "$(json "$URL/api/collections/users/records" -H "Authorization: $jq_" | jq '.items | length')" 1
  attendu "comptes vus par le propriétaire" "$(json "$URL/api/collections/users/records" -H "Authorization: $jp" | jq '.items | length')" 2

  etape "Synchro : envoi, réception dans l'ordre, la plus récente gagne, chacun ses courses"
  attendu "synchro sans connexion" "$(code "$URL/api/elan/courses")" 401
  json -X POST "$URL/api/elan/courses" -H "Authorization: $jp" -d '{"courses":[
    {"id":"a","modifie_ms":1000,"donnees":{"id":"a","race_date":"2026-03-08","title":"Semi de Démoville","distance_m":21100}},
    {"id":"b","modifie_ms":1000,"donnees":{"id":"b","race_date":"2026-05-17","title":"10 km de Valfleuri","distance_m":10000}}]}'
  local tout
  tout=$(json "$URL/api/elan/courses" -H "Authorization: $jp")
  attendu "courses reçues" "$(jq -c '[.courses[].donnees.id]' <<<"$tout")" '["a","b"]'
  local repere
  repere=$(jq '.courses[-1].serveur_ms' <<<"$tout")
  # Version plus ancienne de « a » : ignorée. Version plus récente de « b » : acceptée.
  json -X POST "$URL/api/elan/courses" -H "Authorization: $jp" -d '{"courses":[
    {"id":"a","modifie_ms":500,"donnees":{"id":"a","race_date":"2026-03-08","title":"ANCIEN"}},
    {"id":"b","modifie_ms":2000,"donnees":{"id":"b","race_date":"2026-05-17","title":"10 km de Valfleuri, corrigé","champ_futur":42}}]}'
  attendu "depuis le repère" "$(json "$URL/api/elan/courses?depuis=$repere" -H "Authorization: $jp" | jq -c '[.courses[].donnees | [.id, .title, .champ_futur]]')" \
    '[["b","10 km de Valfleuri, corrigé",42]]'
  attendu "« a » intacte" "$(json "$URL/api/elan/courses" -H "Authorization: $jp" | jq -r '.courses[] | select(.donnees.id=="a") | .donnees.title')" "Semi de Démoville"
  attendu "courses du proche" "$(json "$URL/api/elan/courses" -H "Authorization: $jq_" | jq '.courses | length')" 0
  attendu "pagination" "$(json "$URL/api/elan/courses?limite=1" -H "Authorization: $jp" | jq '.courses | length')" 1

  etape "Horloge d'un appareil en avance : elle ne bloque pas les modifications suivantes"
  json -X POST "$URL/api/elan/courses" -H "Authorization: $jp" -d '{"courses":[
    {"id":"c","modifie_ms":9999999999999,"donnees":{"id":"c","race_date":"2026-06-01","title":"Horloge en avance"}}]}'
  json -X POST "$URL/api/elan/courses" -H "Authorization: $jp" -d "{\"courses\":[
    {\"id\":\"c\",\"modifie_ms\":$(( $(date +%s) * 1000 + 600000 )),\"donnees\":{\"id\":\"c\",\"race_date\":\"2026-06-01\",\"title\":\"Corrigée ailleurs\"}}]}"
  attendu "modification acceptée" "$(json "$URL/api/elan/courses" -H "Authorization: $jp" | jq -r '.courses[] | select(.donnees.id=="c") | .donnees.title')" "Corrigée ailleurs"

  etape "Envoi trop gros refusé"
  attendu "501 courses d'un coup" "$(code -X POST "$URL/api/elan/courses" -H "Authorization: $jp" -H 'Content-Type: application/json' \
    -d "$(jq -nc '{courses: [range(501) | {id: "x\(.)", modifie_ms: 1, donnees: {}}]}')")" 400

  etape "Fichiers : chacun les siens, illisibles sans jeton"
  printf '%%PDF-1.4 facture de test' > /tmp/facture.pdf
  local fiche nom jeton
  fiche=$(curl -fsS -X POST "$URL/api/collections/fichiers/records" -H "Authorization: $jp" \
    -F "proprietaire=$ip" -F "cle=$ip/docs/facture.pdf" -F "fichier=@/tmp/facture.pdf")
  nom=$(jq -r .fichier <<<"$fiche")
  attendu "fichier chez un autre" "$(code -X POST "$URL/api/collections/fichiers/records" -H "Authorization: $jq_" \
    -F "proprietaire=$ip" -F "cle=$ip/docs/intrus.pdf" -F "fichier=@/tmp/facture.pdf")" 400
  attendu "fichiers vus par le proche" "$(json "$URL/api/collections/fichiers/records" -H "Authorization: $jq_" | jq '.items | length')" 0
  local adresse="$URL/api/files/fichiers/$(jq -r .id <<<"$fiche")/$nom"
  [ "$(code "$adresse")" != 200 ] || echec "fichier lisible sans jeton"
  jeton=$(json -X POST "$URL/api/files/token" -H "Authorization: $jq_" | jq -r .token)
  [ "$(code "$adresse?token=$jeton")" != 200 ] || echec "fichier lisible avec le jeton d'un autre"
  jeton=$(json -X POST "$URL/api/files/token" -H "Authorization: $jp" | jq -r .token)
  attendu "contenu du fichier" "$(curl -fsS "$adresse?token=$jeton")" "%PDF-1.4 facture de test"

  etape "Mots de passe : le sien avec l'ancien, celui d'un proche par le propriétaire"
  attendu "changement sans l'ancien" "$(code -X PATCH "$URL/api/collections/users/records/$iq" -H "Authorization: $jq_" \
    -H 'Content-Type: application/json' -d "{\"password\":\"$MDP2\",\"passwordConfirm\":\"$MDP2\"}")" 400
  json -X PATCH "$URL/api/collections/users/records/$iq" -H "Authorization: $jp" \
    -d "{\"password\":\"$MDP2\",\"passwordConfirm\":\"$MDP2\"}" >/dev/null
  read -r jq_ iq < <(connexion "$PROCHE" "$MDP2")
  json -X PATCH "$URL/api/collections/users/records/$iq" -H "Authorization: $jq_" \
    -d "{\"oldPassword\":\"$MDP2\",\"password\":\"$MDP\",\"passwordConfirm\":\"$MDP\"}" >/dev/null
  connexion "$PROCHE" "$MDP" >/dev/null

  # Pour l'étape suivante (code de l'app) : un serveur avec son propriétaire.
  {
    echo "ELAN_SERVEUR_URL=$URL"
    echo "ELAN_EMAIL=$PROPRIO"
    echo "ELAN_MOT_DE_PASSE=$MDP"
  } >> "${GITHUB_ENV:-/dev/null}"
}

durer() {
  local jp ip jq_ iq

  etape "Redémarrage : rien n'est perdu"
  docker compose down
  docker compose up -d
  attendre
  read -r jp ip < <(connexion "$PROPRIO" "$MDP")
  [ "$(json "$URL/api/elan/courses" -H "Authorization: $jp" | jq '.courses | length')" -ge 2 ] || echec "courses perdues au redémarrage"

  etape "Mise à jour d'un serveur installé avant la 1.2 (données à l'administrateur) : rien n'est perdu"
  docker compose down
  sudo chown -R root:root donnees
  docker compose up -d
  attendre
  attendu "données confiées au serveur" "$(docker compose exec -T elan stat -c %U /donnees/data.db)" elan
  read -r jp ip < <(connexion "$PROPRIO" "$MDP")
  [ "$(json "$URL/api/elan/courses" -H "Authorization: $jp" | jq '.courses | length')" -ge 2 ] || echec "courses perdues à la mise à jour"

  etape "Mot de passe du propriétaire perdu : la commande de secours du guide"
  docker compose exec -T elan /pb/mot-de-passe-proprietaire "$MDP2"
  read -r jp ip < <(connexion "$PROPRIO" "$MDP2")
  [ -n "$ip" ] && [ "$ip" != null ] || echec "connexion avec le nouveau mot de passe"
  docker compose exec -T elan /pb/mot-de-passe-proprietaire "$MDP"
  read -r jp ip < <(connexion "$PROPRIO" "$MDP")
  attendu "données après la commande" "$(docker compose exec -T elan stat -c %U /donnees/data.db)" elan

  etape "Sauvegarde complète dans donnees/backups (compte d'administration temporaire, neutralisé ensuite)"
  docker compose exec -T elan /pb/pocketbase superuser upsert secours@exemple.fr "$MDP" --dir=/donnees
  local js
  js=$(json -X POST "$URL/api/collections/_superusers/auth-with-password" -d "{\"identity\":\"secours@exemple.fr\",\"password\":\"$MDP\"}" | jq -r .token)
  json -X POST "$URL/api/backups" -H "Authorization: $js" -d '{"name":"essai.zip"}' >/dev/null
  for _ in $(seq 1 30); do sudo test -s donnees/backups/essai.zip && break; sleep 1; done
  sudo test -s donnees/backups/essai.zip || echec "sauvegarde absente"
  attendu "sauvegarde programmée" "$(json "$URL/api/settings" -H "Authorization: $js" | jq -c '[.backups.cron, .backups.cronMaxKeep]')" '["0 3 * * *",7]'
  attendu "essais du premier compte" "$(json "$URL/api/settings" -H "Authorization: $js"     | jq '.rateLimits.rules[] | select(.label == "/api/elan/premier-compte") | .maxRequests')" 10
  attendu "durée des sessions" "$(json "$URL/api/collections/users" -H "Authorization: $js" | jq .authToken.duration)" 5184000

  etape "Suppression d'un compte : ses données partent avec lui, pas celles des autres"
  read -r jq_ iq < <(connexion "$PROCHE" "$MDP")
  json -X POST "$URL/api/elan/courses" -H "Authorization: $jq_" -d '{"courses":[{"id":"z","modifie_ms":1,"donnees":{"id":"z","title":"Course du proche","race_date":"2026-06-01"}}]}'
  local avant
  avant=$(json "$URL/api/elan/courses?limite=1000" -H "Authorization: $jp" | jq '.courses | length')
  attendu "le propriétaire ne se supprime pas" "$(code -X DELETE "$URL/api/collections/users/records/$ip" -H "Authorization: $jp")" 404
  attendu "suppression du proche" "$(code -X DELETE "$URL/api/collections/users/records/$iq" -H "Authorization: $jp")" 204
  attendu "courses du compte supprimé" "$(json "$URL/api/collections/courses/records?filter=(cle='z')" -H "Authorization: $js" | jq '.items | length')" 0
  attendu "courses du propriétaire" "$(json "$URL/api/elan/courses?limite=1000" -H "Authorization: $jp" | jq '.courses | length')" "$avant"

  etape "Compte d'administration neutralisé (commande de secours du guide)"
  docker compose exec -T elan /pb/fermer-administration
  attendu "connexion d'administration" "$(code -X POST "$URL/api/collections/_superusers/auth-with-password" -H 'Content-Type: application/json' \
    -d "{\"identity\":\"secours@exemple.fr\",\"password\":\"$MDP\"}")" 400

  etape "Tout est bon"
}

"$@"
