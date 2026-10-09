-- =====================================================================
-- ÉLAN : Justificatifs (factures d'inscription, reçus…), à exécuter UNE fois
-- dans Supabase : SQL Editor > New query > coller > Run.
-- Sans risque si on le relance (idempotent). Ne touche à aucune donnée existante.
-- =====================================================================

-- 1. Liste des justificatifs de chaque course (clé du fichier, nom, taille, date d'ajout).
alter table public.courses
  add column if not exists documents jsonb not null default '[]'::jsonb;

-- 2. Le stockage privé accepte aussi les PDF (en plus des photos), 10 Mo par fichier.
update storage.buckets
   set allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'],
       file_size_limit = 10485760
 where id = 'course-media';

-- Les règles d'accès existantes s'appliquent telles quelles : les justificatifs sont rangés
-- sous <user_id>/docs/, donc chacun ne voit et ne modifie que les siens.
