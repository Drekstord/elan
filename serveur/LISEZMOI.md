# ÉLAN : héberger ton propre serveur (NAS avec Docker)

ÉLAN enregistre les courses, les photos et les justificatifs sur un serveur. Ce paquet installe ce
serveur **chez toi, sur ton NAS** : tes données ne quittent pas ta maison, et personne d'autre n'y a
accès. L'app est la même que d'habitude ; il suffit de lui indiquer l'adresse de ton serveur.

Compte une demi-heure la première fois.

## Ce qu'il te faut

- Un NAS (ou un ordinateur Linux) qui fait tourner **Docker** : Synology (Container Manager),
  QNAP (Container Station), Unraid, TrueNAS… Processeur 64 bits (Intel, AMD ou ARM64).
- Environ **2 Go de mémoire libre** et 3 Go d'espace disque, plus la place de tes photos.
- Depuis le téléphone, un accès au NAS : même réseau Wi-Fi, ou **ton VPN** vers chez toi.
- Les fichiers reçus : `ELAN-serveur-vX.zip` (ce paquet) et l'app : `ELAN-vX.apk` (Android),
  `ELAN-Installation-vX.exe` (Windows).

## Ce qu'il y a dans le paquet

```
elan-serveur/
  LISEZMOI.md                 ce guide
  Préparer le serveur.cmd     à lancer une fois, au début
  docker-compose.yml          le serveur, lu par Docker
  systeme/                    fonctionnement interne : rien à ouvrir ni à modifier
```

Après installation s'ajoutent :

```
  connexion-app.txt           ce qu'il faut saisir dans l'app (rien de secret)
  donnees/                    tes données : base, photos et justificatifs, sauvegardes
  .env                        tes réglages et clés secrètes (fichier caché) : ne jamais le partager
```

---

## 1. Préparer les réglages (sur ton PC, 5 minutes)

1. Dézippe le paquet.
2. Trouve l'**adresse IP de ton NAS** sur ton réseau (dans l'interface du NAS ou de ta box), par
   exemple `192.168.1.20`. L'adresse du serveur sera alors **`http://192.168.1.20:8000`**.
3. Dans le dossier `elan-serveur`, double-clique sur **`Préparer le serveur.cmd`**, puis saisis cette adresse.

   *Sans Windows* : dans le dossier `elan-serveur`, lance `sh systeme/preparer.sh http://192.168.1.20:8000`.

4. La fenêtre affiche le **mot de passe du tableau de bord** : note-le (il reste aussi dans `.env`).

Deux fichiers sont créés : `.env` et `connexion-app.txt`. Les secrets sont tirés au hasard, propres à
ton serveur.

## 2. Installer sur le NAS

Copie le dossier `elan-serveur` entier sur le NAS, par exemple dans `/docker/elan-serveur`.
Vérifie que le fichier **`.env`** a bien été copié : son nom commence par un point, certains
systèmes le cachent.

### Synology (Container Manager)

1. **Container Manager** > **Projet** > **Créer**.
2. Nom du projet : `elan`. Chemin : le dossier **`elan-serveur`**.
   Source : *utiliser le docker-compose.yml existant*.
3. **Suivant** jusqu'au bout (pas de portail web à configurer), puis **Terminé**.

Le premier démarrage télécharge environ 2 Go : quelques minutes.

### Autres NAS, ou en SSH

```bash
cd /docker/elan-serveur
docker compose up -d
```

### Vérifier que tout va bien

- Le conteneur **migrations** s'arrête tout seul après le démarrage : c'est normal. Son journal doit
  finir par *Base à jour : 2 fichier(s) appliqué(s).*
- Dans un navigateur, ouvre `http://192.168.1.20:8000` : identifiant **`elan`** et le mot de passe
  du tableau de bord. Le tableau de bord Supabase s'affiche.

## 3. Créer ton compte

Les inscriptions depuis l'app sont fermées : les comptes se créent dans le tableau de bord.

1. **Authentication** > **Users** > **Add user** > **Create new user**.
2. Ton e-mail et **le mot de passe que tu utiliseras dans l'app**.
3. Coche **Auto Confirm User**, puis **Create user**.

Même chose pour chaque personne de ta famille qui utilisera ce serveur. Chacun ne voit que ses courses.

## 4. Brancher l'app

1. Installe l'app :
   - **Android** : ouvre `ELAN-vX.apk` et accepte l'installation (application hors Play Store) ;
   - **Windows** : double-clique sur `ELAN-Installation-vX.exe`. Windows affiche « Windows a protégé
     votre ordinateur » (installateur non signé) : **Informations complémentaires** > **Exécuter
     quand même**, puis **Installer**.
2. Sur l'écran de connexion, touche **Serveur : Serveur ÉLAN** tout en bas.
3. Choisis **Mon serveur**, puis remplis :
   - **Adresse du serveur** : `http://192.168.1.20:8000`
   - **Clé publique** : la longue clé de `connexion-app.txt`

   Astuce : envoie-toi `connexion-app.txt` (rien de secret dedans) et utilise les boutons **Coller**.
   À faire sur chaque appareil (téléphone et PC) ; ensuite, ils se synchronisent entre eux.
4. **Vérifier et enregistrer** : l'app contacte le serveur avant d'accepter.
5. Connecte-toi avec l'e-mail et le mot de passe de l'étape 3.

Dans **Réglages**, la ligne *Serveur : 192.168.1.20:8000* confirme que tu es sur ton serveur.
Pour changer de serveur : se déconnecter, puis **Serveur** sur l'écran de connexion.

| Message de l'app | Que faire |
|---|---|
| Serveur injoignable | VPN actif ? Adresse et port exacts ? Serveur démarré ? |
| Le serveur refuse cette clé | Recopie la clé publique en entier, depuis `connexion-app.txt` |
| La base n'est pas prête | Regarde le journal du conteneur **migrations** |
| Ce n'est pas un serveur ÉLAN | Mauvais port (8000 par défaut) |
| L'adresse doit commencer par https:// | En http, seules les adresses du réseau local ou du VPN sont acceptées |

## Hors de chez toi

- **VPN connecté** : l'app fonctionne comme à la maison.
- **Sans VPN** : l'app marche hors ligne ; tes ajouts partent dès que le serveur est de nouveau joignable.
- **N'ouvre pas le port 8000 sur Internet** (pas de redirection de port sur la box). Pour un accès
  sans VPN, il faut une adresse **https** derrière le proxy inverse du NAS ; l'app refuse le http
  sur Internet, car le mot de passe y circulerait en clair.

Changer l'adresse plus tard : modifie seulement la ligne `ADRESSE_SERVEUR` de `.env`, redémarre le
projet, puis mets à jour l'adresse dans l'app. Ne touche pas aux autres lignes de `.env` : changer
une clé couperait l'accès aux données.

## Sauvegardes

Le serveur ne remplace pas une sauvegarde : si le disque du NAS lâche, tout ce qui n'est que sur
lui est perdu.

- **Chaque nuit à 3 h**, une copie de la base (comptes et courses) est rangée dans
  `donnees/sauvegardes`. Les 14 plus récentes sont gardées. Heure et nombre : lignes
  `HEURE_SAUVEGARDE` et `SAUVEGARDES_A_GARDER` de `.env`.
- **À inclure dans la sauvegarde du NAS** (Hyper Backup sur Synology, par exemple, vers un disque
  externe ou un autre lieu) : `donnees/sauvegardes`, `donnees/fichiers` et le fichier `.env`.
- **Copie immédiate** (avant une mise à jour par exemple) :
  `docker compose exec sauvegarde sh /sauvegarder.sh maintenant`
- **En plus**, l'app exporte toutes tes courses en Excel ou CSV : Réglages > Sauvegarde.

### Restaurer

Sur le NAS, en SSH, dans le dossier `elan-serveur`, serveur démarré :

```bash
sh systeme/restaurer.sh donnees/sauvegardes/elan-2026-10-09-0300.sql.gz
```

Les comptes et courses reviennent à l'état de la sauvegarde. Remets aussi `donnees/fichiers` depuis
la sauvegarde du NAS si les photos ont été perdues. Dans l'app : reconnecte-toi, puis
**Synchroniser maintenant**.

## Mettre à jour

À la réception d'un nouveau `ELAN-serveur-vX.zip` :

1. Copie immédiate de la base (voir plus haut), par prudence.
2. Copie le contenu du nouveau `elan-serveur` **par-dessus** l'ancien. Le paquet ne contient ni `.env`
   ni `donnees` : tes réglages et tes données restent en place.
3. Redémarre : Container Manager > **Projet** > `elan` > **Action** > **Construire**, ou en SSH
   `docker compose pull && docker compose up -d`.

Les changements de structure de la base s'appliquent tout seuls au démarrage (conteneur **migrations**).

## Mot de passe oublié

Tableau de bord > **SQL Editor**, puis (en remplaçant le mot de passe et l'e-mail) :

```sql
update auth.users
set encrypted_password = extensions.crypt('NouveauMotDePasse', extensions.gen_salt('bf'))
where email = 'personne@exemple.fr';
```

## Commandes utiles (SSH, dans le dossier `elan-serveur`)

| | |
|---|---|
| `docker compose ps` | état des services |
| `docker compose logs -f` | journaux en direct (Ctrl+C pour quitter) |
| `docker compose logs migrations` | résultat de la mise à jour de la base |
| `docker compose restart` | redémarrer |
| `docker compose down` | arrêter (les données restent) |

## Ce qui tourne

Une version réduite de **Supabase**, le logiciel libre qui fait aussi tourner le serveur ÉLAN en
ligne : seulement ce dont l'app a besoin, sans e-mails ni service externe.

| Service | Rôle |
|---|---|
| `api` | porte d'entrée unique, port 8000 : l'app et le tableau de bord |
| `db` | base de données PostgreSQL |
| `auth` | comptes et connexion |
| `rest` | lecture et écriture des courses, chacun les siennes |
| `storage` | photos et justificatifs, rangés par compte |
| `studio`, `meta` | tableau de bord d'administration |
| `migrations` | met la base à jour au démarrage, puis s'arrête |
| `sauvegarde` | copie de la base chaque nuit |

---

*Pour qui maintient ÉLAN* : le paquet est construit à chaque version par GitHub (workflow
« Version ») à partir du dossier `serveur` du dépôt, et joint à la
release. Il est testé de bout en bout par le workflow « Serveur auto-hébergé ».
