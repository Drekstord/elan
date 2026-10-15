#!/bin/sh
# Démarrage du serveur ÉLAN dans son conteneur.
#
# Le serveur tourne sous l'utilisateur « elan », sans les droits d'administrateur : une faille
# dans le serveur ne donnerait pas la main sur le conteneur. Le dossier des données lui est
# d'abord confié (seuls les fichiers qui ne sont pas encore à lui changent de propriétaire).
# Si le NAS l'interdit, le serveur démarre quand même, comme avant, et le signale.
set -e

serveur() {
  exec "$@" /pb/pocketbase serve \
    --http=0.0.0.0:8000 \
    --dir=/donnees \
    --migrationsDir=/pb/pb_migrations \
    --hooksDir=/pb/pb_hooks \
    --publicDir=/pb/pb_public
}

if [ "$(id -u)" = 0 ]; then
  if find /donnees ! -user elan -exec chown elan:elan {} + 2>/dev/null; then
    serveur su-exec elan
  fi
  echo "Serveur ÉLAN : le dossier des données ne peut pas être confié à l'utilisateur elan ; le serveur tourne en administrateur." >&2
fi
serveur
