-- =====================================================================
-- ÉLAN : Sécurité (version 2.14), à exécuter UNE fois
-- dans Supabase : SQL Editor > New query > coller > Run.
-- Sans risque si on le relance (idempotent). Ne supprime aucune donnée.
-- =====================================================================

-- 1. Horloge d'un appareil en avance : plafonnée à 5 minutes après l'heure du serveur.
--    Sans cela, un téléphone réglé dans le futur empêcherait toute modification faite ailleurs
--    (la version la plus récente gagne).
create or replace function public.courses_before_write()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at > now() + interval '5 minutes' then
    new.updated_at := now();
  end if;
  if tg_op = 'UPDATE' then
    if new.updated_at < old.updated_at then
      return null;  -- version plus ancienne : ignorée
    end if;
    new.user_id := old.user_id;
  end if;
  new.server_updated_at := clock_timestamp();
  return new;
end;
$$;

-- Courses déjà enregistrées « dans le futur » : ramenées à maintenant.
update public.courses set updated_at = now() where updated_at > now() + interval '5 minutes';

-- 2. Contrôle : les deux résultats ci-dessous doivent être VIDES.
--    Une ligne dans l'un d'eux = une table lisible ou modifiable par n'importe qui avec la clé
--    publique de l'app (qui est dans l'app publiée). Voir docs/CLOUD.md, « Vérifier la sécurité ».

-- Tables sans protection par ligne (RLS)
select c.relname as table_sans_rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity;

-- Règles d'accès ouvertes aux visiteurs non connectés
select tablename as table_ouverte, policyname as regle, cmd as action
from pg_policies
where schemaname = 'public' and (roles @> array['anon']::name[] or roles @> array['public']::name[]);
