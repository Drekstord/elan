-- =====================================================================
-- ÉLAN : Schéma cloud
-- À exécuter dans Supabase > SQL Editor > New query > Run.
-- Idempotent : peut être relancé sans risque.
--
--   * chaque ligne appartient à un utilisateur (user_id) ; RLS : chacun ses lignes ;
--   * unités entières : mètres, secondes, centimes ; date de course sans heure ;
--   * updated_at        : dernière modification (la plus récente gagne) ;
--   * server_updated_at : horodatage serveur, curseur de synchronisation ;
--   * deleted_at        : suppression logique, propagée aux autres appareils ;
--   * photos dans le bucket privé "course-media", rangées par user_id.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Mise de côté des tables des versions précédentes
-- ---------------------------------------------------------------------
do $$
declare
  has_courses boolean;
  has_user_id boolean;
  has_distance_m boolean;
  row_count bigint;
begin
  select exists (select 1 from information_schema.tables
                 where table_schema = 'public' and table_name = 'courses') into has_courses;
  if not has_courses then return; end if;

  select exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'courses' and column_name = 'distance_m') into has_distance_m;
  if has_distance_m then return; end if;  -- déjà au bon format

  select exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'courses' and column_name = 'user_id') into has_user_id;

  if has_user_id then
    -- Essai intermédiaire (km / euros décimaux) : supprimé s'il est vide, sinon mis de côté.
    execute 'select count(*) from public.courses' into row_count;
    if row_count = 0 then
      drop table public.courses cascade;
    else
      alter table public.courses rename to courses_backup_v2;
    end if;
  elsif not exists (select 1 from information_schema.tables
                    where table_schema = 'public' and table_name = 'courses_legacy') then
    alter table public.courses rename to courses_legacy;
  else
    alter table public.courses rename to courses_backup_v1;
  end if;
end $$;

-- L'ancienne politique v1 donnait tout à la clé anon : retirée.
-- La table legacy reste sous RLS sans politique, donc inaccessible depuis l'app.
do $$
begin
  if exists (select 1 from information_schema.tables
             where table_schema = 'public' and table_name = 'courses_legacy') then
    execute 'drop policy if exists "Acces complet public courses" on public.courses_legacy';
    execute 'alter table public.courses_legacy enable row level security';
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 2. Table des courses
-- ---------------------------------------------------------------------
create table if not exists public.courses (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  id text not null,

  title text not null,
  race_date date not null,
  course_type text not null default 'officialRace',
  is_planned boolean not null default false,
  distance_m integer not null check (distance_m >= 0),
  duration_s integer not null default 0 check (duration_s >= 0),
  elevation_gain_m integer,
  multisport jsonb,
  details jsonb,
  team_size integer check (team_size is null or team_size >= 1),
  challenge_distance_m integer,

  is_charity boolean not null default false,
  association_id text,
  association_name text,
  association_cause text,
  association_description text,
  sponsor_cents_per_km integer not null default 0,
  registration_donation_cents integer not null default 0,
  fundraising_cents integer not null default 0,
  impact_metric text not null default 'euroDirect',
  impact_quantity double precision,

  bib_photo_key text,
  medal_photo_key text,
  notes text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  deleted_at timestamptz,

  primary key (user_id, id)
);

-- Mise à niveau d'une table créée par une version antérieure de ce script.
alter table public.courses add column if not exists is_planned boolean not null default false;
alter table public.courses add column if not exists fundraising_cents integer not null default 0;
alter table public.courses add column if not exists documents jsonb not null default '[]'::jsonb;  -- justificatifs
alter table public.courses add column if not exists multisport jsonb;  -- triathlon, duathlon, aquathlon
alter table public.courses add column if not exists details jsonb;  -- temps visé, classement
alter table public.courses drop column if exists impact_rate_per_km;  -- équivalences au km abandonnées

create index if not exists courses_user_server_updated_idx
  on public.courses (user_id, server_updated_at);

-- ---------------------------------------------------------------------
-- 3. Horodatage serveur + refus des écritures plus anciennes
-- ---------------------------------------------------------------------
create or replace function public.courses_before_write()
returns trigger
language plpgsql
as $$
begin
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

drop trigger if exists courses_before_write on public.courses;
create trigger courses_before_write
  before insert or update on public.courses
  for each row execute function public.courses_before_write();

-- ---------------------------------------------------------------------
-- 4. Row Level Security : chacun ses courses
-- ---------------------------------------------------------------------
alter table public.courses enable row level security;

drop policy if exists "courses_select_own" on public.courses;
create policy "courses_select_own" on public.courses
  for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists "courses_insert_own" on public.courses;
create policy "courses_insert_own" on public.courses
  for insert to authenticated with check (user_id = (select auth.uid()));

drop policy if exists "courses_update_own" on public.courses;
create policy "courses_update_own" on public.courses
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Pas de politique DELETE : l'app supprime logiquement (deleted_at).

-- ---------------------------------------------------------------------
-- 5. Photos et justificatifs (bucket privé) : <user_id>/<uuid>.jpg, <user_id>/docs/<uuid>.pdf
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('course-media', 'course-media', false, 10485760,
        array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "course_media_select_own" on storage.objects;
create policy "course_media_select_own" on storage.objects
  for select to authenticated
  using (bucket_id = 'course-media' and (storage.foldername(name))[1] = (select auth.uid()::text));

drop policy if exists "course_media_insert_own" on storage.objects;
create policy "course_media_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'course-media' and (storage.foldername(name))[1] = (select auth.uid()::text));

drop policy if exists "course_media_update_own" on storage.objects;
create policy "course_media_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'course-media' and (storage.foldername(name))[1] = (select auth.uid()::text))
  with check (bucket_id = 'course-media' and (storage.foldername(name))[1] = (select auth.uid()::text));

drop policy if exists "course_media_delete_own" on storage.objects;
create policy "course_media_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'course-media' and (storage.foldername(name))[1] = (select auth.uid()::text));
