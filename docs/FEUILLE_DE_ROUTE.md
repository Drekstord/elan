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
| 12 | Serveur auto-hébergé (Docker sur NAS) | ✅ terminé |
| 13 | Choix du serveur dans l'app | ✅ terminé |
| 14 | Guide d'auto-hébergement | ✅ terminé |
| 15 | Installateur Windows (.exe) | ✅ terminé |

Écartés : objectifs annuels (non souhaités).

---

## 1. Rappel le soir de la course ✅

- Notification sur le téléphone (Android) le **soir du jour J** de chaque course à venir :
  « Saisis ton temps pour le Marathon de Port-Imaginaire ».
- Un appui sur la notification ouvre la fiche de la course, prête pour « Saisir mon résultat ».
- Les rappels suivent les courses : ajout, changement de date, suppression, résultat saisi.
- Réglage : rappel activé / désactivé et heure du rappel (20 h par défaut).

## 2. Justificatifs (factures d'inscription) ✅

> Prérequis cloud : exécuter une fois `serveur/systeme/migrations/002_justificatifs.sql` (voir [CLOUD.md](CLOUD.md)).

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

- Toutes les courses (à venir comprises), 23 colonnes, en **CSV** (format français : « ; », virgule
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

## 12. Serveur auto-hébergé (Docker sur NAS) ✅

- Dossier `serveur` : Supabase réduit à ce qu'utilise ÉLAN (base, comptes, données, fichiers,
  tableau de bord), un seul port ouvert (8000), inscriptions fermées, aucun e-mail.
- Base mise à jour toute seule au démarrage (`serveur/systeme/migrations`, chaque fichier une seule fois).
- Sauvegarde de la base chaque nuit, 14 gardées ; restauration en une commande.
- Secrets générés par un outil (Windows ou Linux) ; paquet `ELAN-serveur-vX.zip` joint aux releases.
- Testé de bout en bout sur GitHub à chaque modification : démarrage, comptes, règles d'accès,
  synchro de l'app, sauvegarde, perte de la base, restauration.

## 13. Choix du serveur dans l'app ✅

- Écran de connexion > **Serveur** : serveur ÉLAN (par défaut) ou « Mon serveur » (adresse + clé
  publique, avec boutons Coller). Le serveur est vérifié avant d'être enregistré, avec un message
  clair en cas de problème (injoignable, mauvaise clé, base pas prête).
- Le même APK sert à tout le monde ; le serveur en cours est rappelé dans Réglages.
- http accepté seulement pour une adresse de réseau local ou de VPN ; https obligatoire sur Internet.

## 14. Guide d'auto-hébergement ✅

- [serveur/LISEZMOI.md](../serveur/LISEZMOI.md), aussi dans le paquet : préparation,
  installation (Synology ou SSH), comptes, branchement de l'app, accès hors de chez soi,
  sauvegardes, mises à jour, dépannage.

## 15. Installateur Windows (.exe) ✅

- Un seul fichier, `ELAN-Installation-vX.exe`, construit par GitHub à chaque version et joint à la
  release, avec l'APK et le paquet serveur : plus besoin de compiler ni de copier un dossier.
- Installation sans droits administrateur, raccourcis menu Démarrer (et Bureau au choix), mise à jour
  par-dessus, désinstallation depuis Paramètres > Applications ; données conservées.
- Bibliothèques C++ de Microsoft incluses : fonctionne sur un PC neuf.
- Essayé par GitHub à chaque construction : installation silencieuse, lancement, désinstallation.
- Non signé : avertissement de Windows au premier lancement (« Exécuter quand même »).
