#!/bin/sh
# Neutralise les comptes d'administration de PocketBase (voir le guide) :
#   /pb/fermer-administration
# Lancé sous le même utilisateur que le serveur, pour que ses fichiers restent les siens.
set -e
if [ "$(id -u)" = 0 ] && [ "$(stat -c %U /donnees/data.db 2>/dev/null)" = elan ]; then
  exec su-exec elan /pb/pocketbase fermer-administration "$@" \
    --dir=/donnees --hooksDir=/pb/pb_hooks --migrationsDir=/pb/pb_migrations
fi
exec /pb/pocketbase fermer-administration "$@" \
  --dir=/donnees --hooksDir=/pb/pb_hooks --migrationsDir=/pb/pb_migrations
