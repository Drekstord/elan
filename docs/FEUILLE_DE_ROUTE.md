# ÉLAN : Feuille de route

Prochaines évolutions, **par ordre de priorité**. On traite les points dans l'ordre ;
chacun est marqué ✅ (avec sa version) une fois terminé, avant de passer au suivant.

| # | Évolution | État |
|---|---|---|
| 1 | Rappel le soir de la course | ✅ terminé |
| 2 | Justificatifs (factures d'inscription) | ✅ terminé |
| 3 | Récapitulatif par association | ✅ terminé |
| 4 | Export de sauvegarde (CSV + Excel) | ✅ terminé |
| 5 | Construction automatique de l'APK sur GitHub | ✅ terminé |
| 6 | Records par année | ✅ terminé |
| 7 | Galerie des médailles et dossards | ✅ terminé |
| 8 | Retirer tous les tirets longs | ✅ terminé |
| 9 | Types de justificatifs (mail de confirmation, facture, résultat…) | ✅ terminé |
| 10 | Chiffres qui défilent au lancement | ✅ terminé |
| 11 | Accessibilité (RGAA) | ✅ terminé (partiellement conforme, voir ACCESSIBILITE.md) |
| 12 | Serveur personnel (Docker sur NAS) | ✅ terminé, refait au point 21 |
| 13 | Choix du serveur dans l'app | ✅ terminé |
| 14 | Guide du serveur personnel | ✅ terminé, refait au point 21 |
| 15 | Installateur Windows (.exe) | ✅ terminé |
| 16 | Clé de signature Android dédiée | ✅ terminé |
| 17 | Sauvegarde automatique depuis l'app | ✅ terminé |
| 18 | Widget Android (prochaine course, km de l'année) | ✅ terminé |
| 19 | Import de plusieurs GPX d'un coup | ✅ terminé |
| 20 | Avertissement « nouvelle version disponible » | ✅ terminé |
| 21 | Serveur personnel refait : un seul conteneur, zéro réglage | ✅ terminé |
| 22 | Dépôt public sous licence libre (GPL-3.0) | ✅ terminé |
| 23 | Triathlon, duathlon, aquathlon | ✅ terminé |
| 24 | Performances de triathlon dans Évolution et Records | ✅ terminé |
| 25 | Objectifs : temps visé par course, objectif annuel de kilomètres | ✅ terminé |
| 26 | Classement officiel (général et catégorie) | ✅ terminé |
| 27 | Bilan de l'année à partager | ✅ terminé |
| 28 | App en anglais | ✅ terminé, complété au point 32 |
| 29 | Import d'un triathlon depuis un fichier de montre (FIT) | ✅ terminé, à confirmer sur un vrai fichier de montre |
| 30 | Comparaison d'une édition à l'autre | ✅ terminé |
| 31 | Courses à venir vers l'agenda (.ics) | ✅ terminé |
| 32 | Finitions : classement à la saisie du résultat, objectif annuel synchronisé, anglais complet | ✅ terminé |
| 33 | Plafonds The Conqueror corrigés : 5 arbres et 50 bouteilles par défi | ✅ terminé |
| 34 | Audit de sécurité et corrections | ✅ terminé |

Écartés : objectifs annuels (non souhaités).

---

## 1. Rappel le soir de la course ✅

- Notification sur le téléphone (Android) le **soir du jour J** de chaque course à venir :
  « Saisis ton temps pour le Marathon de Port-Imaginaire ».
- Un appui sur la notification ouvre la fiche de la course, prête pour « Saisir mon résultat ».
- Les rappels suivent les courses : ajout, changement de date, suppression, résultat saisi.
- Réglage : rappel activé / désactivé et heure du rappel (20 h par défaut).

## 2. Justificatifs (factures d'inscription) ✅

> Prérequis cloud : exécuter une fois `supabase/002_justificatifs.sql` (voir [CLOUD.md](CLOUD.md)).

- Joindre un ou plusieurs justificatifs (**PDF ou photo**, 10 Mo max) **à une course**, depuis sa fiche ; stockés dans le cloud comme les photos (privés, synchronisés).
- **Écran « Justificatifs »** (depuis Impact) : tous les justificatifs, chacun rattaché à sa course
  (nom, date, association, montant), avec un lien direct vers la course.
  Ajouter un justificatif depuis cet écran demande de choisir la course (liste avec recherche).
- **Extraire** : un justificatif seul (ouvrir / enregistrer / partager), ou **tous ceux d'une
  période** (raccourcis comme le bilan, plus « Toutes les dates ») en un fichier ZIP aux noms clairs ;
  le bilan propose aussi « Justificatifs (ZIP) » pour sa période
  (`2026-10-04 Foulée de Démoville - facture.pdf`).
- Simple avant tout : deux appuis pour joindre, deux appuis pour extraire.

## 3. Récapitulatif par association ✅

- Pour chaque association soutenue : total versé, nombre de courses, km, causes,
  liste des courses (avec accès aux justificatifs du point 2).
- Accès depuis Impact (liste « Associations soutenues ») ; export texte / image comme le bilan.

## 4. Export de sauvegarde (CSV + Excel) ✅

- Toutes les courses (à venir comprises), 26 colonnes, en **CSV** (format français : « ; », virgule
  décimale, UTF-8 avec BOM) et en **Excel** mis en forme.
- Accès depuis Réglages. Indépendant du cloud : une copie que l'on garde soi-même.

## 5. Construction automatique de l'APK sur GitHub ✅

> Workflow `.github/workflows/version.yml` (anciennement `apk.yml`), secrets enregistrés ; premier essai réussi (13 min), APK signé
> avec la même clé que celui du PC (empreinte SHA-256 identique).

- À chaque étiquette de version (`v2.6.0`…), GitHub Actions lance les tests, construit l'APK
  et le publie dans une *release* du dépôt. Plus besoin du PC pour mettre à jour le téléphone.
- Configuration Supabase (URL + clé publique) fournie via les secrets du dépôt.

## 6. Records par année ✅

- Dans Records : meilleur temps de l'année sur 5 km, 10 km, semi, marathon, en plus des records
  absolus ; sélecteur d'année.

## 7. Galerie des médailles et dossards ✅

- Depuis Records (icône en haut) : mosaïque de toutes les photos, par année, filtre Tout / Médailles /
  Dossards ; un appui ouvre la course, un appui long affiche la photo en plein écran.

## 8. Retirer tous les tirets longs ✅

- Plus aucun tiret long dans l'app (textes, bilans, exports), le code ni la documentation :
  deux-points, virgule ou point médian « · » à la place.
- Garde-fou : `test/design/no_em_dash_test.dart` échoue si un tiret long réapparaît.

## 9. Types de justificatifs ✅

- Chaque justificatif a un type : mail de confirmation, facture, reçu de don, résultat de course,
  autre. Choisi à l'ajout, modifiable ensuite.
- Le type sert de titre dans l'app et nomme le fichier à l'export :
  `2026-10-04 Foulée de Démoville - Facture.pdf` (au lieu d'un nom de fichier aléatoire).
- Type proposé d'après le nom du fichier ; « Changer le type » dans le menu ⋮. Les justificatifs
  ajoutés avant gardent leur nom de fichier tant qu'on ne leur donne pas de type.

## 10. Chiffres qui défilent au lancement ✅

- Au lancement, les grands chiffres (accueil, Impact) défilent comme un compteur jusqu'à leur valeur.
- Une seule fois par lancement ; désactivé si le système demande de réduire les animations.

## 11. Accessibilité (RGAA) ✅

> Détail, méthode et limites : [ACCESSIBILITE.md](ACCESSIBILITE.md).

- Mise en conformité avec le RGAA sans changer l'apparence : contrastes (déjà vérifiés), textes
  alternatifs, noms des boutons à icône, lecture des graphiques par lecteur d'écran, grands textes
  sans débordement, cibles tactiles suffisantes, animations réductibles, déclaration d'accessibilité.

## 12. Serveur personnel (Docker sur NAS) ✅

- Première version : Supabase auto-hébergé (8 conteneurs, un dossier de réglages, des clés à générer
  et à recopier). Elle fonctionnait mais restait trop complexe pour qui ne connaît pas Docker.
  **Remplacée par le point 21.**

## 13. Choix du serveur dans l'app ✅

- Écran de connexion > **Serveur** : serveur ÉLAN (par défaut) ou « Mon serveur ». Le serveur est
  vérifié avant d'être enregistré, avec un message clair en cas de problème.
- Le même APK sert à tout le monde ; le serveur en cours est rappelé dans Réglages.
- http accepté seulement pour une adresse de réseau local ou de VPN ; https obligatoire sur Internet.
- Depuis le point 21 : une adresse suffit, plus de clé à recopier.

## 14. Guide du serveur personnel ✅

- [serveur/LISEZMOI.md](../serveur/LISEZMOI.md). Réécrit au point 21.

## 15. Installateur Windows (.exe) ✅

- Un seul fichier, `ELAN-Installation-vX.exe`, construit par GitHub à chaque version et joint à la
  release, avec l'APK et le paquet serveur : plus besoin de compiler ni de copier un dossier.
- Installation sans droits administrateur, raccourcis menu Démarrer (et Bureau au choix), mise à jour
  par-dessus, désinstallation depuis Paramètres > Applications ; données conservées.
- Bibliothèques C++ de Microsoft incluses : fonctionne sur un PC neuf.
- Essayé par GitHub à chaque construction : installation silencieuse, lancement, désinstallation.
- Non signé : avertissement de Windows au premier lancement (« Exécuter quand même »).

## 16. Clé de signature Android dédiée ✅

- Remplacer la clé de débogage de ce PC par une clé propre à ÉLAN, gardée en lieu sûr.
- À faire avant que d'autres personnes installent l'app : changer de clé oblige à désinstaller
  l'app une fois (les données sont sur le serveur : il suffit de se reconnecter).
- Fait : clé RSA 4096 valable jusqu'en 2054, sur ce PC (ignorée par git) et dans les secrets GitHub ;
  détails et passage à la nouvelle clé dans [INSTALLATION.md](INSTALLATION.md).

## 17. Sauvegarde automatique depuis l'app ✅

- Chaque semaine (réglable), l'app enregistre toute seule dans un dossier choisi : les courses
  (Excel) et une copie des photos et justificatifs. Les dernières copies sont gardées.
- Complète l'offre gratuite de Supabase, sans sauvegarde restaurable soi-même.
- Fait, sur ordinateur (Réglages > Sauvegarde automatique) : dossier `ELAN` avec un classeur daté par
  semaine (8 gardés) et `Photos et justificatifs/<année>/` aux noms lisibles, chaque fichier copié une
  seule fois. Vérifiée au démarrage, au retour dans l'app et toutes les 6 h. Sur Android, Android
  limite l'écriture dans un dossier choisi : l'ordinateur, synchronisé, s'en charge.

## 18. Widget Android ✅

- Sur l'écran d'accueil du téléphone : la prochaine course avec son compte à rebours (J-12) et les
  kilomètres de l'année. Un appui ouvre l'app. (Le compte à rebours existe déjà dans l'app.)
- Fait : widget 3 × 2 redimensionnable, aux couleurs du bandeau. L'app lui envoie les données à
  chaque changement ; le compte à rebours se recalcule seul chaque nuit. Lecteur d'écran : une
  phrase complète (« Prochaine course : …, dans 12 jours. 1 211 km en 2026. »). Ajout : appui long
  sur l'écran d'accueil > Widgets > ÉLAN.

## 19. Import de plusieurs GPX d'un coup ✅

- Choisir plusieurs fichiers GPX (export Garmin, Strava…) : une course par fichier (date, distance,
  durée, dénivelé), les doublons déjà présents sont ignorés, résumé à la fin.
- Fait : bouton « Importer des fichiers GPX » en haut de l'écran Courses. Doublon = même jour et
  distance à 3 % près (déjà dans l'app ou deux fois dans le lot). Traces sans heure et fichiers
  illisibles comptés dans le résumé. Sans nom dans le GPX : « Course du 1 mai 2026 ».

## 20. Avertissement « nouvelle version disponible » ✅

- Au lancement (une fois par jour au plus), l'app regarde la dernière version publiée sur GitHub
  (dépôt public) et propose de la télécharger si elle est plus récente.
- Fait : bandeau en haut de l'écran, « Télécharger » ouvre le bon fichier (APK sur Android,
  installateur sur Windows), « Plus tard » ne repropose plus cette version d'elle-même.
  Réglages > À propos : version installée et « Rechercher une mise à jour ».

## 21. Serveur personnel refait : un seul conteneur, zéro réglage ✅

> Retour des premières personnes à qui le serveur a été remis : trop de fichiers, trop de pièces,
> incompréhensible sans connaître Docker.

- **Un seul conteneur** (PocketBase réglé pour ÉLAN, image `ghcr.io/drekstord/elan-serveur`) à la
  place des 8 de Supabase : moins de 100 Mo de mémoire, NAS modestes et Raspberry Pi compris.
- **Un seul fichier à déposer** (`docker-compose.yml`, une dizaine de lignes) : plus de dossier de
  réglages, plus de script de préparation, plus de clés.
- **Dans l'app, une adresse suffit.** Sur un serveur tout neuf, l'app propose de créer le premier
  compte, propriétaire du serveur ; il ajoute ensuite ses proches dans Réglages > Gérer les comptes
  (ajout, nouveau mot de passe, suppression). Chacun ne voit que ses courses.
- **Page d'accueil du serveur** (`http://nas:8000`) : « le serveur fonctionne », l'adresse à saisir
  dans l'app et les étapes suivantes.
- **Données dans un seul dossier** (`donnees`), copie complète chaque nuit (7 gardées).
- **Guide réécrit pour débutants** : vocabulaire, chaque écran de Synology, ce qu'on doit voir à
  chaque étape, tableau de dépannage, questions fréquentes. Fourni en page web dans le paquet.
- Le serveur ÉLAN en ligne (Supabase) est inchangé ; l'app parle aux deux par une couche commune
  (`lib/core/backend`). Les courses sont stockées telles que l'app les envoie : un champ ajouté dans
  l'app ne demande pas de mise à jour des serveurs personnels.
- Testé de bout en bout sur GitHub à chaque modification, avec le vrai code de l'app : premier
  compte, comptes des proches, cloisonnement, synchro (la plus récente gagne, envois groupés),
  fichiers, mots de passe, redémarrage, sauvegarde, suppression d'un compte.

## 22. Dépôt public sous licence libre (GPL-3.0) ✅

- Le code est public sur github.com/Drekstord/elan, sous licence GNU GPL version 3 : chacun peut
  l'utiliser, le modifier et le redistribuer, à condition que sa version reste libre.
- Téléchargements sans compte (APK, installateur Windows, paquet du serveur) ; l'image Docker du
  serveur est publique ; l'avertissement « nouvelle version » de l'app (point 20) fonctionne.
- Vie privée : le dépôt public ne reçoit qu'un commit par version, jamais l'historique de travail
  (gardé dans un dépôt privé). `scripts/publier.sh` fait la publication et refuse de partir si le
  code contient une adresse de serveur, une clé ou un fichier personnel.

## 23. Triathlon, duathlon, aquathlon ✅

- Un troisième type de course, à côté de « Course » et « Défi » : triathlon, duathlon (course, vélo,
  course) ou aquathlon (natation, course).
- **Saisie** : un format (XXS à XL, ou libre) préremplit les distances, toutes modifiables ; un temps
  par discipline et par transition, ou seulement le temps total.
- **Transitions comptées dans les disciplines** : pour les chronos qui n'isolent pas les transitions
  (T1 dans la natation, T2 dans le vélo). Les deux temps concernés portent la mention « transition
  comprise », car leur rythme est alors un peu sous-estimé.
- **Fiche** : temps total, puis chaque discipline dans son unité (allure aux 100 m en natation, km/h
  à vélo, allure au km à pied), les transitions et la répartition du temps.
- **Kilomètres courus** (accueil, Évolution, widget) : seule la course à pied compte. **Engagement
  solidaire** (parrainage au kilomètre, bilans) : les trois disciplines comptent.
- **Records** : meilleur temps par épreuve et format (« Triathlon S »…), à part des records de course
  à pied. Filtre « Triathlons » dans la liste, affiché seulement si une épreuve enchaînée existe.
- Carte de partage, bilans et sauvegarde Excel/CSV (une colonne « Disciplines » en plus, en dernier).
- Serveur en ligne : exécuter une fois `supabase/003_multisport.sql` (voir [CLOUD.md](CLOUD.md)) ;
  en attendant, le reste de l'app se synchronise normalement. Serveurs personnels : rien à faire.
- **Corrigé au passage** : modifier une course lui faisait perdre ses justificatifs (depuis la 2.6).

## 24. Performances de triathlon dans Évolution et Records ✅

- **Évolution** : un filtre « Triathlons » (proposé dès qu'une épreuve enchaînée est terminée) ; une
  carte « Triathlons : par discipline » avec le nombre d'épreuves, puis la distance et le temps cumulés
  en natation, à vélo et à pied, comparés à la période précédente.
- **Évolution** : un graphique « Rythme par discipline en triathlon », une discipline à la fois
  (allure aux 100 m, km/h, allure au km), affiché à partir de deux épreuves chronométrées sur la période.
- **Records** : « Meilleurs rythmes en triathlon », un podium par discipline, tous formats confondus.
  Les deux courses d'un duathlon n'en font qu'une.
- Un temps qui contient une transition est signalé (« transition comprise ») partout où il apparaît.
- Badge « Record natation / vélo / course à pied » sur la fiche, à partir de deux épreuves comparables.
- Les kilomètres courus et les records de course à pied restent inchangés.

## 25. Objectifs ✅

- **Temps visé** (facultatif) sur chaque course, à venir ou terminée, épreuves enchaînées comprises.
  Avant la course, la fiche affiche l'objectif et l'allure qu'il demande ; après, « Objectif battu de
  1:12 », « manqué de 0:35 » ou « atteint ».
- **Objectif annuel** de kilomètres courus, sur l'accueil : avancement, pourcentage, et avance ou
  retard sur le rythme de l'année. Le widget Android affiche « 207 / 500 ».
- L'objectif annuel suit d'un appareil à l'autre depuis le point 32.

## 26. Classement officiel ✅

- Place et nombre d'arrivants, au général et dans la catégorie (avec son nom : « SEH », « M1 »…).
  Tout est facultatif.
- La fiche traduit la place : « 142e sur 980, dans les 15 % premiers ».
- **Évolution** : un graphique du classement d'une course à l'autre (part des arrivants devant soi),
  à partir de deux courses classées sur la période.
- Sauvegarde Excel/CSV : deux colonnes de plus, « Temps visé » et « Classement » (26 au total).
- Serveur en ligne : exécuter une fois `supabase/004_details.sql` (voir [CLOUD.md](CLOUD.md)). Cette
  colonne accueillera aussi les prochaines informations de ce genre : plus de script à prévoir pour elles.
  En attendant, les courses sans objectif ni classement se synchronisent normalement.
  Serveurs personnels : rien à faire.

## 27. Bilan de l'année à partager ✅

- Une image au format de la carte de partage : kilomètres courus, courses, temps, dénivelé, records,
  plus longue course, et les dons avec le nombre d'associations.
- Depuis **Évolution** (bouton de partage), pour n'importe quelle année.
- En décembre et en janvier, une annonce sur l'accueil propose le bilan de l'année ; elle se ferme d'un geste.

## 28. App en anglais ✅

- Tous les textes de l'app traduits ; les nombres, les dates et les rangs (« 1st », « 142nd ») suivent
  la langue.
- **Réglages > Apparence > Langue** : Système, Français ou English. « Système » suit la langue de
  l'appareil ; une langue que l'app ne parle pas donne le français.
- Un test vérifie que chaque texte français a sa traduction, avec les mêmes variables.
- Reste en français : le CSV (format prévu pour Excel en français). Le reste a été traduit au point 32.

## 29. Import d'un triathlon depuis un fichier de montre ✅

- Le bouton d'import du formulaire accepte désormais un fichier **GPX** ou **FIT**.
- Un fichier FIT enregistré en mode multisport (Garmin, Coros, Suunto, Wahoo…) remplit l'épreuve, la
  distance et le temps de chaque discipline, chaque transition, la date et le dénivelé. Le format
  (XXS à XL) est reconnu quand les distances s'en approchent à 20 % près.
- Un fichier FIT d'une seule activité remplit distance et temps, comme un GPX.
- **Limite connue** : la lecture suit la spécification du format et elle est testée sur des fichiers
  fabriqués pour les tests, pas encore sur un fichier sorti d'une montre. À confirmer sur un vrai
  fichier ; en cas d'écart, les valeurs restent modifiables avant l'enregistrement.

## 30. Comparaison d'une édition à l'autre ✅

- Sur la fiche d'une course, une carte « Éditions précédentes » : l'écart avec la dernière édition
  (« 2:10 de mieux qu'en 2025 »), puis chaque édition avec son temps et son classement.
- Les éditions sont reconnues toutes seules : même nom au millésime et au numéro d'édition près
  (« 10 km de Valfleuri 2026 », « 10 km de Valfleuri, 12e édition »), même type d'épreuve, distance
  voisine (10 %). Il n'y a pas de rattachement manuel : deux noms vraiment différents ne se comparent pas.
- Pour une course à venir, la carte rappelle les éditions passées, utile pour fixer un temps visé.

## 31. Courses à venir vers l'agenda ✅

- Fiche d'une course à venir : bouton « Ajouter à l'agenda ». Réglages > Sauvegarde : toutes les
  courses à venir d'un coup.
- Un fichier .ics (format lu par tous les agendas), un événement d'une journée par course, avec le
  type, la distance et le temps visé en note.
- Réimporter le fichier met les événements à jour au lieu de les dupliquer. La course n'a pas de
  lieu dans l'app : l'événement n'en a donc pas.

## 32. Finitions ✅

- **Saisir mon résultat** : la place et le nombre d'arrivants se saisissent dans la même fenêtre.
- **Objectif annuel synchronisé** : il suit d'un appareil à l'autre, le changement le plus récent
  l'emporte. Serveur en ligne : rien à faire. Serveur personnel : mettre le serveur à jour (version
  1.1, voir son guide) ; sans cela l'objectif reste sur chaque appareil, comme avant.
- **Anglais complet** : messages de synchronisation, tailles de fichier et descriptions des
  associations du catalogue.

## 34. Audit de sécurité et corrections ✅

Audit de toute l'app (app, serveur personnel, schéma Supabase, Android, Windows, publication).
Corrigé :

1. **Fichiers venus du serveur** : une clé de fichier qui ne suit pas le format de l'app est
   refusée (rien n'est lu ni écrit hors du dossier de l'app) ; seuls les PDF et les images
   s'ouvrent, avec leur vraie extension (un « facture.pdf.exe » ne se lance jamais).
2. **Mot de passe du propriétaire perdu** : commande `/pb/mot-de-passe-proprietaire`, sans compte
   d'administration à créer ni à oublier.
3. **Publication** : actions GitHub figées sur leur empreinte, droits réduits par tâche, clé de
   signature Android présente sur le disque le temps de la construction seulement, image pandoc figée.
4. **Sauvegarde Android** : la session de connexion n'est plus copiée dans la sauvegarde Google.
5. **App publique sans serveur intégré** : l'adresse et la clé publique d'un projet Supabase se
   saisissent dans l'app (écran « Serveur »), une fois par appareil ; la clé secrète est refusée.
6. **Lien de mise à jour** : seulement vers GitHub, en https.
7. **Notes personnelles** (`Idee_app.txt`, `*.protondoc`) ignorées par git et bloquées par `publier.sh`.
8. **Horloge d'un appareil en avance** plafonnée par les deux serveurs (`supabase/005_securite.sql`).
9. **Sessions** : 60 jours sur le serveur personnel ; **Réglages > Déconnecter mes autres appareils**.
10. **Premier compte** : code d'installation (fichier `donnees/code-premier-compte.txt`).
11. **https à la maison** : section du guide du serveur (proxy inversé du NAS).
12. **Image Docker** : empreintes de PocketBase notées dans le Dockerfile ; serveur sans droits
    d'administrateur (repli automatique si le NAS l'interdit).
13. **Volumes** : 500 courses par envoi, 20 000 courses et 10 000 fichiers par compte.
14. **Signature de l'installateur Windows** : documentée (payante), pas mise en place.

Testé de bout en bout sur un vrai serveur (GitHub) : code d'installation, horloge, quotas, serveur
sans droits d'administrateur, mise à jour d'un serveur installé avant, commande de secours,
déconnexion des autres appareils.
