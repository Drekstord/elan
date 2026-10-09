#!/bin/sh
# Crée le fichier .env du serveur avec des secrets neufs (Linux, macOS, NAS en SSH).
# Sous Windows : double-cliquer sur « Préparer le serveur.cmd ».
#
#   sh systeme/preparer.sh http://ADRESSE-DU-NAS:8000
#
# Nécessite openssl. Refuse d'écraser un .env existant : changer les secrets d'un
# serveur déjà lancé couperait l'accès aux données.
set -eu
cd "$(dirname "$0")/.."

adresse=${1:-}
case "$adresse" in
  http://*|https://*) ;;
  *) echo "Usage : sh systeme/preparer.sh http://ADRESSE-DU-NAS:8000" >&2; exit 1 ;;
esac
adresse=${adresse%/}
# Port ouvert sur le NAS : celui de l'adresse en http, sinon 8000 (https passe par un proxy).
port=$(printf '%s' "$adresse" | sed -n 's#^http://[^/:]*:\([0-9]*\).*#\1#p')
port=${port:-8000}

if [ -e .env ]; then
  echo "Un fichier .env existe déjà : rien n'est modifié." >&2
  exit 1
fi
command -v openssl >/dev/null || { echo "openssl est nécessaire." >&2; exit 1; }

hasard() { openssl rand -hex "$1"; }
b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }

jwt_secret=$(hasard 32)
jeton() {
  maintenant=$(date +%s)
  entete=$(printf '{"alg":"HS256","typ":"JWT"}' | b64url)
  contenu=$(printf '{"role":"%s","iss":"supabase","iat":%s,"exp":%s}' "$1" "$maintenant" $((maintenant + 10 * 365 * 24 * 3600)) | b64url)
  signature=$(printf '%s.%s' "$entete" "$contenu" | openssl dgst -sha256 -hmac "$jwt_secret" -binary | b64url)
  printf '%s.%s.%s' "$entete" "$contenu" "$signature"
}
anon=$(jeton anon)
service=$(jeton service_role)
tableau=$(hasard 12)

sed -e "s#^ADRESSE_SERVEUR=.*#ADRESSE_SERVEUR=$adresse#" \
    -e "s#^PORT=.*#PORT=$port#" \
    -e "s#^DASHBOARD_PASSWORD=.*#DASHBOARD_PASSWORD=$tableau#" \
    -e "s#^POSTGRES_PASSWORD=.*#POSTGRES_PASSWORD=$(hasard 24)#" \
    -e "s#^JWT_SECRET=.*#JWT_SECRET=$jwt_secret#" \
    -e "s#^ANON_KEY=.*#ANON_KEY=$anon#" \
    -e "s#^SERVICE_ROLE_KEY=.*#SERVICE_ROLE_KEY=$service#" \
    -e "s#^PG_META_CRYPTO_KEY=.*#PG_META_CRYPTO_KEY=$(hasard 24)#" \
    systeme/modele.env > .env
chmod 600 .env

# Ce qu'il faut saisir dans l'app (rien de secret : la clé publique est faite pour être dans l'app).
printf 'Adresse du serveur : %s\nClé publique : %s\n' "$adresse" "$anon" > connexion-app.txt

echo "Fichier .env créé."
echo
echo "Tableau de bord : $adresse"
echo "  identifiant : elan"
echo "  mot de passe : $tableau"
echo
echo "Dans l'app ÉLAN (aussi dans connexion-app.txt) :"
echo "  Adresse du serveur : $adresse"
echo "  Clé publique : $anon"
