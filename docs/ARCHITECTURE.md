# ÉLAN : Architecture (v2)

## Choix

| Sujet | Choix | Raison |
|---|---|---|
| Plateformes | Flutter natif : Windows, Android | Un seul code, design entièrement maîtrisé, logique métier Dart réutilisée. |
| Backend | Supabase : Auth (e-mail + mot de passe), PostgreSQL + RLS, Storage | Gratuit, tout-en-un, rien à héberger. Voir [CLOUD.md](CLOUD.md). Serveur personnel possible (un conteneur Docker) : [serveur/LISEZMOI.md](../serveur/LISEZMOI.md). |
| État | Riverpod 3 | Testable (overrides), gère chargement/erreur, indépendant du `BuildContext`. |
| Navigation | go_router | Redirection selon la session ; coque responsive (rail ≥ 840 px, barre du bas sinon). |
| Base locale | Drift (SQLite), une base par utilisateur | Requêtes réactives, migrations versionnées, stats rapides pour les graphiques. |
| Synchro | Moteur maison testé (voir plus bas) | Hors-ligne d'abord, dernière écriture gagnante, suppressions logiques. |
| Unités | mètres, secondes, centimes (entiers) ; date de course sans heure | Pas d'arrondis sur les euros, pas de décalage de jour selon le fuseau. |
| Photos | Redimensionnées (2000 px, JPEG 85) + miniature (480 px), bucket privé | Quota gratuit préservé, listes rapides. |
| Textes | `lib/l10n/app_fr.arb` (gen-l10n), français uniquement | Aucun texte en dur dans les écrans. |
| Design | Jetons dans `lib/app/theme/tokens.dart` | La refonte visuelle se fait à un seul endroit. |

## Arborescence

```
lib/
├── main.dart                     # Serveur choisi, dossier de données, puis ServerRoot
├── app/                          # Application : MaterialApp, routeur, coque, thème
│   ├── app.dart
│   ├── server_root.dart          # Connexion au serveur choisi, tout est recréé s'il change
│   ├── router.dart               # Routes + redirection connexion
│   ├── shell.dart                # Navigation responsive, préparation de session, synchro au retour
│   ├── theme/                    # tokens.dart (couleurs, espaces, rayons), app_theme.dart, theme_mode.dart
│   └── widgets/                  # Widgets transverses (badge de synchro…)
├── core/                         # Infrastructure, sans écran
│   ├── config.dart               # URL / clé du serveur intégré, injectées au build
│   ├── backend/                  # Backend : serveur en ligne (Supabase) ou personnel (serveur ÉLAN)
│   ├── server/                   # Serveur personnel : adresse, vérification, choix enregistré
│   ├── providers.dart            # Graphe Riverpod (session, base, synchro)
│   ├── database/                 # Tables Drift + conversions ligne <-> modèle
│   ├── sync/                     # remote_gateway.dart (Supabase), sync_engine.dart
│   ├── media/                    # Photos : import, redimensionnement, cache
│   └── legacy/                   # Reprise unique des données v1
├── features/
│   ├── auth/                     # data/ (AuthRepository) + presentation/ (connexion, choix du serveur)
│   ├── courses/                  # domain/ (Course), data/ (CourseRepository), presentation/
│   ├── records/
│   └── settings/
└── l10n/                         # app_fr.arb + fichiers générés
```

Règle de dépendance : `presentation → data → domain` ; `domain` ne dépend de rien (ni Flutter, ni Supabase).

### Serveurs

L'app parle à son serveur à travers une seule interface, `Backend` (`lib/core/backend`) : comptes,
synchronisation, fichiers. Deux réalisations :

| | Serveur ÉLAN en ligne | Serveur personnel |
|---|---|---|
| Classe | `SupabaseBackend` | `ElanBackend` |
| Technique | Supabase (Auth, PostgreSQL + RLS, Storage) | PocketBase dans un conteneur (`serveur/image`) |
| Désigné par | URL + clé publique, à la compilation (`config/supabase.json`) | Son adresse, saisie dans l'app |
| Comptes | Créés par l'administrateur dans le tableau de bord | Premier compte créé dans l'app, puis par le propriétaire |
| Structure | `supabase/*.sql`, à exécuter dans le SQL Editor ([CLOUD.md](CLOUD.md)) | `serveur/image/pb_migrations`, appliquée au démarrage |

Dossier `serveur/` :

- `docker-compose.yml` et `LISEZMOI.md` : ce que reçoit la personne qui installe son serveur
  (le guide est converti en page web dans le paquet `ELAN-serveur-vX.zip`).
- `image/` : ce qui construit l'image Docker, jamais remis tel quel.
  - `pb_migrations/` : comptes, courses, fichiers, réglages. Une évolution = un nouveau fichier.
  - `pb_hooks/elan.pb.js` : les quatre routes propres à l'app (état, premier compte, envoi et
    réception des courses). Le reste passe par les routes standard de PocketBase et leurs règles d'accès.
  - `pb_public/` : la page d'accueil du serveur.

Le serveur personnel stocke chaque course telle que l'app l'envoie (un bloc JSON) : ajouter un champ
à `Course` ne demande aucune mise à jour des serveurs déjà installés. Le protocole entre l'app et le
serveur a un numéro de version (`elanProtocolVersion`, `/api/elan/etat`) ; l'étiquette de l'image
(`:1`) le suit.

## Flux de données

```
Écran ──watch──> coursesProvider ──> CourseRepository.watchCourses() ──> Drift (réactif)
Écran ──action─> CourseRepository.save()/delete()
                    └─ écrit en local (pending = true), file les opérations photo
                    └─ onLocalChange ──> SyncController.schedule() (2 s)
SyncController.sync() ──> SyncEngine.run()
    1. envoi des photos (photo_ops = upload)
    2. upsert des courses pending ; pending = false si non modifiées entre-temps
    3. suppression distante des photos remplacées (photo_ops = delete)
    4. pull depuis le curseur server_updated_at (−2 min), fusion :
       une version locale pending et plus récente est conservée
```

Déclencheurs de synchro : ouverture de session, 2 s après une modification, retour dans l'app, bouton manuel.

## Session

`currentUserProvider` (flux Supabase Auth) → `userIdProvider` → base, photos, dépôt et synchro
sont recréés si le compte change (une base SQLite `elan_<uid>.sqlite` par utilisateur).
`sessionBootstrapProvider` importe les données v1 une seule fois, puis lance la première synchro.

## Règles métier (étape 2)

| Règle | Décision |
|---|---|
| Impact | Mesure principale : euros réellement engagés (parrainage au km + inscription + collecte). Une équivalence (arbres, repas…) n'existe que si l'organisateur l'annonce et qu'elle est saisie ; rien n'est extrapolé des kilomètres. |
| The Conqueror | Plafonds 5 arbres / 50 bouteilles par défi ; part personnelle = distance du défi / taille de l'équipe. |
| Courses à venir | `isPlanned` : « à venir » avant la date, « résultat à saisir » à partir du jour J (remonte en tête de liste). Ne compte nulle part tant que le résultat n'est pas saisi. |
| Records | Par distance de référence (5 km, 10 km, semi, marathon, avec tolérance de mesure), plus longue distance, plus gros D+. Courses terminées et chronométrées, défis virtuels exclus. Badge seulement face à au moins une autre course comparable. |
| Annuaire | Catalogue intégré (hors ligne) + répertoire officiel SIRENE (`recherche-entreprises.api.gouv.fr`, associations actives). Cause déduite du nom puis du code NAF. |
| GPX | Distance par segment (pauses non comptées), D+ filtré à 3 m contre le bruit GPS. |
| Recherche | Insensible aux accents et à la casse (titre, association, notes). |

Modules : `features/courses/domain/` (course, course_query, course_stats, course_rules), `features/records/domain/`,
`features/impact/domain/` + `data/` (catalogue, recherche), `features/courses/data/gpx_parser.dart`.
Fournisseurs prêts pour les écrans : `courses_providers.dart`, `records_providers.dart`, `impact_providers.dart`.

## Charte graphique (étape 4)

| Élément | Choix |
|---|---|
| Direction | Athlétique, nature et solidarité : « Élan », l'impulsion de l'effort et l'animal des forêts boréales. Fort contraste, angles francs, aucun dégradé, aucun emoji. |
| Fonds et bandeaux | Papier lichen `#F2EEE4` ; bandeaux des chiffres héros vert forêt `#15301F` ; mode sombre « forêt de nuit ». |
| Accent d'action | Vert mousse `#3F7D2B` (clair) / `#9CCB52` (sombre) : boutons, distance, rappels, état « à jour ». |
| Solidarité | Terre cuite `#C0502C` / `#E88560` : euros, dons, associations, causes. |
| Autres sens | Or d'automne (records), bleu lac (à venir), rouge (erreur). |
| Emblème | Tête d'élan géométrique aux bois en palme (`lib/app/widgets/elan_emblem.dart`, vectoriel), associée au mot « ÉLAN » dans le logotype. Icône d'application : élan vert mousse sur vert forêt (`assets/icon/`, `dart run flutter_launcher_icons`). |
| Mode sombre | Anthracite chaud quasi neutre ; vert forêt réservé au bandeau héros ; accents désaturés ; texte adouci ; pas de grand aplat saturé. |
| Polices | Barlow Condensed (chiffres, titres, libellés en capitales) + Plus Jakarta Sans (texte), intégrées (`assets/fonts`, licence OFL). Chiffres tabulaires. |
| Motifs | Bandeau noir souligné d'orange pour les chiffres héros ; titres de course en capitales condensées ; lignes numérotées 01, 02… ; sur-titres espacés. |
| Thème | Suit le réglage clair / sombre de l'appareil. |

Jetons : `lib/app/theme/tokens.dart` ; thème Material : `app_theme.dart` ; composants : `lib/app/widgets/common.dart`.
Captures de relecture : `flutter test test/screenshots --tags screenshots --run-skipped --update-goldens` (images dans `test/screenshots/out/`).

## Commandes

```bash
dart run build_runner build   # après modification des tables Drift
flutter gen-l10n              # après modification de app_fr.arb (aussi fait au build)
flutter analyze
flutter test
flutter run -d windows --dart-define-from-file=config/supabase.json
```

## Feuille de route

1. Fondations : base locale, connexion, synchro, migration v1. **Fait.**
2. Logique métier + tests : impact, records, statistiques, courses à venir, import GPX, annuaire. **Fait.**
3. Écrans fonctionnels : liste (totaux, filtres, tri, recherche, rappel « résultat à saisir »), formulaire complet (course à venir, GPX, défi en équipe, volet solidaire, association, photos), fiche (saisie du résultat), Impact, Records. **Fait.**
4. Design « athlétique audacieux » appliqué via les jetons. **Fait.**
5. Installation comme un vrai logiciel (Windows : `Installer ELAN.cmd` ; Android : APK), onglet Évolution (distance et dons par période, cumul annuel comparé, allure par course ; couleurs de graphique validées, vue tableau), carte de partage d'une course (image 1080 × 1350). **Fait.**
6. Clarté (Évolution, filtres, sections), Material You, contrastes WCAG, bilan d'engagement (texte, Excel, image, copie riche Word/Excel). **Fait (v2.5.2).**

Suite : voir **[FEUILLE_DE_ROUTE.md](FEUILLE_DE_ROUTE.md)** (priorités et état de chaque évolution).
