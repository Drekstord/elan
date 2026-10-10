-- =====================================================================
-- ÉLAN : Objectifs et classements (version 2.12), à exécuter UNE fois
-- dans Supabase : SQL Editor > New query > coller > Run.
-- Sans risque si on le relance (idempotent). Ne touche à aucune donnée existante.
-- =====================================================================

-- Informations facultatives d'une course : temps visé, classement officiel.
-- Vide (null) tant que rien n'est saisi. Les prochaines informations de ce genre
-- iront dans cette même colonne : plus de script à exécuter pour elles.
alter table public.courses
  add column if not exists details jsonb;

-- Les règles d'accès existantes s'appliquent telles quelles : chacun ses courses.
