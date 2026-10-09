# ÉLAN : Mise en place de Supabase (serveur en ligne)

> Pour héberger le serveur chez soi (NAS avec Docker), voir [serveur/LISEZMOI.md](../serveur/LISEZMOI.md).

Quatre actions dans le tableau de bord, une fois. Aucune ne touche aux e-mails.

## 1. Créer la base

1. Barre de gauche : **SQL Editor** (icône `>_`) > **New query**.
2. Ouvrir `serveur/systeme/migrations/001_schema.sql` dans le Bloc-notes, tout copier (Ctrl+A, Ctrl+C), coller dans Supabase.
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
SQL Editor > New query > coller le contenu de [`serveur/systeme/migrations/002_justificatifs.sql`](../serveur/systeme/migrations/002_justificatifs.sql) > **Run**.
(Ce fichier s'appelait `003_justificatifs.sql` jusqu'à la version 2.7 : déjà passé, rien à refaire.)
Le script ne touche à aucune donnée existante et peut être relancé sans risque.
(Une installation neuve avec `001_schema.sql` l'inclut déjà.)

## Facultatif : courses de l'ancienne table cloud

Si des courses avaient été enregistrées dans Supabase avec la v1 : remplacer l'e-mail (2 fois) dans
`serveur/systeme/import_v1_cloud.sql`, l'exécuter dans le SQL Editor, puis **Synchroniser maintenant** dans l'app.

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
