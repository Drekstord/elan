#!/bin/sh
# Met la base au niveau de l'app : applique, dans l'ordre, chaque fichier de /migrations
# qui ne l'a pas encore été. Lancé à chaque démarrage ; ne refait jamais un fichier déjà passé.
set -eu

psql -v ON_ERROR_STOP=1 -q <<'SQL'
create schema if not exists elan;
revoke all on schema elan from public;
create table if not exists elan.migrations (
  fichier text primary key,
  appliquee_le timestamptz not null default now()
);
SQL

nouvelles=0
for f in /migrations/*.sql; do
  nom=$(basename "$f")
  deja=$(psql -tA -v nom="$nom" <<'SQL'
select count(*) from elan.migrations where fichier = :'nom';
SQL
)
  if [ "$deja" = "0" ]; then
    echo "Application de $nom..."
    # Le fichier et son enregistrement passent ensemble, ou pas du tout.
    { cat "$f"; printf "\ninsert into elan.migrations (fichier) values ('%s');\n" "$nom"; } |
      psql -v ON_ERROR_STOP=1 -q --single-transaction
    nouvelles=$((nouvelles + 1))
  fi
done

if [ "$nouvelles" = "0" ]; then
  echo "Base à jour : rien à appliquer."
else
  echo "Base à jour : $nouvelles fichier(s) appliqué(s)."
fi
