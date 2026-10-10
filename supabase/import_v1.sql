-- =====================================================================
-- ÉLAN : Import des courses de l'ancienne table cloud (v1) vers ton compte
-- Facultatif : seulement si des courses avaient été enregistrées dans
-- Supabase avec la v1 (par exemple depuis le téléphone).
--
-- À exécuter APRÈS 001_schema.sql et après avoir créé ton utilisateur.
-- Remplace TON_EMAIL@exemple.fr (2 fois) par ton adresse, puis Run.
-- Idempotent : une course déjà présente (même id) n'est pas écrasée.
-- =====================================================================

insert into public.courses (
  user_id, id, title, race_date, course_type,
  distance_m, duration_s, elevation_gain_m, team_size, challenge_distance_m,
  is_charity, association_id, association_name, association_cause, association_description,
  sponsor_cents_per_km, registration_donation_cents,
  impact_metric, impact_quantity,
  notes, created_at, updated_at
)
select
  u.id, l.id, l.title, l.date::date, l.course_type,
  round(l.distance_km * 1000)::int, l.duration_seconds, l.elevation_gain,
  case when l.is_team then l.team_size end,
  case when l.total_challenge_distance_km is not null then round(l.total_challenge_distance_km * 1000)::int end,
  l.is_charity,
  case when l.is_charity then l.association_id end,
  case when l.is_charity then l.association_name end,
  case when l.is_charity then l.association_cause end,
  case when l.is_charity then l.association_description end,
  case when l.is_charity then round(l.sponsored_euro_per_km * 100)::int else 0 end,
  case when l.is_charity then round(l.registration_fee_donated * 100)::int else 0 end,
  -- Équivalences v1 calculées au km abandonnées : seules les quantités déclarées restent.
  case when l.is_charity and l.custom_impact_quantity is not null then l.impact_metric else 'euroDirect' end,
  case when l.is_charity then l.custom_impact_quantity end,
  l.notes, l.created_at,
  -- Horodatage ancien : la version importée depuis un appareil l'emporte toujours.
  timestamptz '2000-01-01'
from public.courses_legacy l
cross join (select id from auth.users where email = 'TON_EMAIL@exemple.fr') u
on conflict (user_id, id) do nothing;

-- Vérification
select count(*) as courses_sur_ton_compte
from public.courses c
join auth.users u on u.id = c.user_id
where u.email = 'TON_EMAIL@exemple.fr';

-- Une fois tout vérifié dans l'app, l'ancienne table peut être supprimée :
-- drop table public.courses_legacy;
