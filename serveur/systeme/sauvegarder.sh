#!/bin/sh
# Sauvegarde de la base : une copie par nuit dans /sauvegardes (./donnees/sauvegardes sur le NAS),
# les SAUVEGARDES_A_GARDER plus récentes sont conservées.
#
#   Tourne en continu (service « sauvegarde »).
#   Copie immédiate : docker compose exec sauvegarde sh /sauvegarder.sh maintenant
#
# Contenu : comptes, courses et liste des fichiers (photos, justificatifs). Les fichiers
# eux-mêmes sont dans ./donnees/fichiers : à inclure dans la sauvegarde du NAS.
# Restauration : systeme/restaurer.sh (voir le guide).
set -eu

sauvegarder() {
  nom="elan-$(date +%Y-%m-%d-%H%M).sql.gz"
  tmp="/sauvegardes/.$nom.partiel"
  # Données seulement : la structure est recréée par les migrations sur un serveur neuf.
  pg_dump --data-only --no-owner --no-privileges \
    --table=auth.users --table=auth.identities \
    --table=public.courses \
    --table=storage.objects \
    | gzip > "$tmp"
  mv "$tmp" "/sauvegardes/$nom"
  echo "$(date '+%F %T') Sauvegarde : $nom"

  # Les plus anciennes au-delà de SAUVEGARDES_A_GARDER sont retirées.
  ls -1t /sauvegardes/elan-*.sql.gz 2>/dev/null | tail -n +$((SAUVEGARDES_A_GARDER + 1)) | while read -r vieux; do
    rm -f "$vieux"
    echo "  retirée : $(basename "$vieux")"
  done
}

mkdir -p /sauvegardes

if [ "${1:-}" = "maintenant" ]; then
  sauvegarder
  exit 0
fi

echo "Sauvegarde chaque jour à $HEURE_SAUVEGARDE, $SAUVEGARDES_A_GARDER copies gardées."
while true; do
  maintenant=$(date +%s)
  prochaine=$(date -d "$HEURE_SAUVEGARDE" +%s)
  # Heure déjà passée aujourd'hui : demain à la même heure.
  [ "$prochaine" -le "$maintenant" ] && prochaine=$((prochaine + 86400))
  sleep $((prochaine - maintenant))
  sauvegarder || echo "$(date '+%F %T') Échec de la sauvegarde, nouvel essai demain."
done
