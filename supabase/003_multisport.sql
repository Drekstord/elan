-- =====================================================================
-- ÉLAN : Triathlons, duathlons, aquathlons (version 2.10), à exécuter UNE fois
-- dans Supabase : SQL Editor > New query > coller > Run.
-- Sans risque si on le relance (idempotent). Ne touche à aucune donnée existante.
-- =====================================================================

-- Détail d'une épreuve enchaînée : épreuve, format, distance et temps de chaque discipline,
-- transitions. Vide (null) pour les autres courses.
alter table public.courses
  add column if not exists multisport jsonb;

-- Les règles d'accès existantes s'appliquent telles quelles : chacun ses courses.
