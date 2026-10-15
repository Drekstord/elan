#!/bin/sh
# Nouveau mot de passe pour le propriétaire du serveur (mot de passe oublié) :
#   /pb/mot-de-passe-proprietaire NOUVEAU_MOT_DE_PASSE
# Lancé sous le même utilisateur que le serveur, pour que ses fichiers restent les siens.
set -e
if [ "$(id -u)" = 0 ] && [ "$(stat -c %U /donnees/data.db 2>/dev/null)" = elan ]; then
  exec su-exec elan /pb/pocketbase mot-de-passe-proprietaire "$@" \
    --dir=/donnees --hooksDir=/pb/pb_hooks --migrationsDir=/pb/pb_migrations
fi
exec /pb/pocketbase mot-de-passe-proprietaire "$@" \
  --dir=/donnees --hooksDir=/pb/pb_hooks --migrationsDir=/pb/pb_migrations
