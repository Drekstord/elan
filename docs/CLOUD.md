# ÉLAN : Mise en place de Supabase (serveur en ligne)

> Pour héberger le serveur chez soi (NAS avec Docker), c'est un autre serveur, bien plus simple :
> voir [serveur/LISEZMOI.md](../serveur/LISEZMOI.md).

Quatre actions dans le tableau de bord, une fois. Aucune ne touche aux e-mails.

## 1. Créer la base

1. Barre de gauche : **SQL Editor** (icône `>_`) > **New query**.
2. Ouvrir `supabase/001_schema.sql` dans le Bloc-notes, tout copier (Ctrl+A, Ctrl+C), coller dans Supabase.
3. **Run**. Résultat attendu : *Success. No rows returned*.
   Un avertissement « destructive operation » peut apparaître : le script met de côté les anciennes tables sans les effacer (il ne supprime qu'une table d'essai vide). Confirmer.

## 2. Fermer les inscriptions

**Authentication** > **Sign In / Providers** > désactiver **Allow new users to sign up** > **Save**.
(Le fournisseur *Email* doit rester activé.)

## 3. Créer ton compte

**Authentication** > **Users** > **Add user** > **Create new user** :
- ton e-mail et **le mot de passe que tu utiliseras dans l'app** ;
- cocher **Auto Confirm User** ;
- **Create user**.

Même procédure pour chaque proche (ils pourront changer leur mot de passe dans Réglages).

## 4. Brancher l'app

1. **Project Settings** (engrenage en bas à gauche) :
   - *Data API* : copier l'**URL du projet** (`https://xxxx.supabase.co`) ;
   - *API Keys* : copier la clé **publishable** (`sb_publishable_…`), à défaut la clé **anon**.
     Jamais la clé *secret* / *service_role*.
2. Coller ces deux valeurs dans `config/supabase.json` (fichier ignoré par git) :
   ```json
   {
     "SUPABASE_URL": "https://xxxx.supabase.co",
     "SUPABASE_ANON_KEY": "sb_publishable_xxxx"
   }
   ```
3. Lancer :
   ```bash
   flutter run -d windows --dart-define-from-file=config/supabase.json
   ```
   À la première connexion, les courses et photos de la v1 présentes sur l'appareil sont importées automatiquement.

## Mise à jour : justificatifs (version 2.6)

Les justificatifs (factures d'inscription…) demandent une colonne de plus et l'accès aux PDF
dans le stockage. **Une seule fois, avant d'installer la version 2.6 :**
SQL Editor > New query > coller le contenu de [`supabase/002_justificatifs.sql`](../supabase/002_justificatifs.sql) > **Run**.
Le script ne touche à aucune donnée existante et peut être relancé sans risque.
(Une installation neuve avec `001_schema.sql` l'inclut déjà.)

## Mise à jour : triathlons, duathlons, aquathlons (version 2.10)

Les épreuves enchaînées demandent une colonne de plus. **Une seule fois :**
SQL Editor > New query > coller le contenu de [`supabase/003_multisport.sql`](../supabase/003_multisport.sql) > **Run**.
Tant que ce n'est pas fait, tout le reste de l'app se synchronise normalement ; seuls les triathlons
restent sur l'appareil, avec un message qui le signale dans Réglages.
(Une installation neuve avec `001_schema.sql` l'inclut déjà. Les serveurs personnels n'ont rien à faire.)

## Mise à jour : objectifs et classements (version 2.12)

Le temps visé et le classement d'une course demandent une colonne de plus. **Une seule fois :**
SQL Editor > New query > coller le contenu de [`supabase/004_details.sql`](../supabase/004_details.sql) > **Run**.
Tant que ce n'est pas fait, les courses sans objectif ni classement se synchronisent normalement ; les
autres restent sur l'appareil, avec un message qui le signale dans Réglages.
Cette colonne accueillera aussi les prochaines informations de ce genre : plus de script à prévoir pour elles.
(Une installation neuve avec `001_schema.sql` l'inclut déjà. Les serveurs personnels n'ont rien à faire.)

## Facultatif : courses de l'ancienne table cloud

Si des courses avaient été enregistrées dans Supabase avec la v1 : remplacer l'e-mail (2 fois) dans
`supabase/import_v1.sql`, l'exécuter dans le SQL Editor, puis **Synchroniser maintenant** dans l'app.

## Mot de passe oublié

Sans e-mail personnalisé, la réinitialisation se fait par l'administrateur, dans le SQL Editor :

```sql
update auth.users
set encrypted_password = crypt('NouveauMotDePasse', gen_salt('bf'))
where email = 'personne@exemple.fr';
```

## Bon à savoir

- Offre gratuite : 500 Mo de base, 1 Go de photos, 50 000 utilisateurs actifs/mois.
- Un projet gratuit est **mis en pause après ~7 jours sans activité** : le réactiver depuis le tableau de bord (aucune perte).
