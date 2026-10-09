#!/bin/sh
# Remet la base dans l'état d'une sauvegarde (comptes, courses, liste des fichiers).
# À lancer sur le NAS (SSH), dans le dossier du serveur, serveur démarré :
#
#   sh systeme/restaurer.sh donnees/sauvegardes/elan-AAAA-MM-JJ-HHMM.sql.gz
#
# Les photos et justificatifs ne sont pas dans la sauvegarde de la base : remettre
# aussi le dossier donnees/fichiers depuis la sauvegarde du NAS si besoin.
set -eu
cd "$(dirname "$0")/.."

fichier=${1:-}
if [ ! -f "$fichier" ]; then
  echo "Usage : sh systeme/restaurer.sh donnees/sauvegardes/elan-....sql.gz" >&2
  exit 1
fi

if [ "${2:-}" != "--oui" ]; then
  printf "Les comptes et courses actuels seront remplacés par %s. Continuer ? (oui/non) " "$(basename "$fichier")"
  read -r reponse
  [ "$reponse" = "oui" ] || { echo "Annulé."; exit 1; }
fi

# Le tout en une seule transaction : en cas d'erreur, rien n'est modifié.
{
  echo "set session_replication_role = replica;"
  echo "truncate auth.users, auth.identities, public.courses, storage.objects cascade;"
  gunzip -c "$fichier"
} | docker compose exec -T db psql -U supabase_admin -d postgres -v ON_ERROR_STOP=1 -q --single-transaction

echo "Restauration terminée. Reconnecte-toi dans l'app, puis « Synchroniser maintenant »."
