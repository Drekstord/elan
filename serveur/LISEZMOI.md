# Installer ton serveur ÉLAN

L'app ÉLAN enregistre tes courses, tes photos et tes justificatifs sur un **serveur** : c'est ce qui
permet de les retrouver sur ton téléphone et sur ton ordinateur. Ce guide t'explique comment
installer ce serveur **chez toi**, sur ton NAS. Tes données ne quittent alors pas ta maison.

Aucune connaissance technique n'est nécessaire : suis les étapes dans l'ordre. Compte **un quart d'heure**.

## En bref

1. Tu déposes **un dossier** sur ton NAS et tu le démarres.
2. Tu ouvres une page dans ton navigateur pour vérifier que ça marche.
3. Dans l'app, tu indiques l'adresse de ton serveur et tu crées ton compte.

C'est tout. Il n'y a rien à configurer, pas de mot de passe technique, pas de clé à recopier.

## Avant de commencer

### Ce qu'il te faut

- Un **NAS** capable de faire tourner **Docker** : Synology (modèles « + » notamment), QNAP,
  Unraid, TrueNAS… Un mini-PC ou un Raspberry Pi sous Linux conviennent aussi.
- Très peu de ressources : moins de **100 Mo de mémoire**, et la place de tes photos sur le disque.
- Le fichier **`ELAN-serveur-vX.zip`**. Il contient ce guide et un dossier **`elan`**.
- L'app ÉLAN pour ton téléphone (`ELAN-vX.apk`) ou ton ordinateur (`ELAN-Installation-vX.exe`).

Ces fichiers se téléchargent librement, sans compte, sur la page des versions d'ÉLAN :
**https://github.com/Drekstord/elan/releases** (rubrique **Assets** de la version la plus récente).

### Quatre mots à connaître

| Mot | Ce que c'est |
|---|---|
| **NAS** | Le boîtier de stockage branché sur ta box, allumé en permanence. |
| **Docker** | Un logiciel du NAS qui fait tourner des programmes dans des boîtes fermées, sans rien salir. Sur Synology, il s'appelle **Container Manager**. |
| **Conteneur** | Une de ces boîtes. Le serveur ÉLAN en est une seule. |
| **Adresse du NAS** | Le numéro qui désigne ton NAS sur ton réseau, par exemple `192.168.1.20`. On la trouve à l'étape 3. |

---

## Étape 1 : déposer le dossier sur le NAS

1. Sur ton ordinateur, dézippe `ELAN-serveur-vX.zip` (clic droit > **Extraire tout**). Tu obtiens ce
   guide et un dossier **`elan`**.
2. Copie le dossier **`elan`** entier sur ton NAS, là où tu ranges ce genre de choses.
   Sur Synology : ouvre **File Station**, va dans le dossier partagé **`docker`** (il existe dès que
   Container Manager est installé) et glisse le dossier `elan` dedans.

Tu obtiens ceci sur le NAS :

```
docker/
  elan/
    docker-compose.yml    le serveur : le NAS lit ce fichier pour savoir quoi lancer
    donnees/              tes données s'enregistreront ici (vide pour l'instant)
```

Ne modifie pas `docker-compose.yml`, sauf cas particulier expliqué plus bas (port déjà utilisé).

## Étape 2 : démarrer le serveur

Choisis la partie qui correspond à ton NAS.

### Sur un Synology

1. Si ce n'est pas déjà fait, installe **Container Manager** : ouvre le **Centre de paquets**,
   cherche « Container Manager », clique sur **Installer**.
2. Ouvre **Container Manager**, puis, dans le menu de gauche, **Projet**.
3. Clique sur **Créer**. Une fenêtre s'ouvre :
   - **Nom du projet** : `elan`
   - **Chemin** : clique sur **Définir le chemin** et choisis le dossier `docker/elan` de l'étape 1.
   - Le NAS détecte le fichier et propose de **l'utiliser** : accepte
     (« Utiliser le fichier docker-compose.yml existant »).
4. Clique sur **Suivant**. Si une page « Portail Web » apparaît, ne coche rien. **Suivant**, puis **Effectué**.
5. Le NAS télécharge le serveur (quelques dizaines de Mo), puis le démarre. Une fenêtre affiche l'avancement ;
   quand elle indique que c'est terminé, ferme-la.

Dans la liste **Projet**, `elan` apparaît avec une **pastille verte** : le serveur tourne.
Il redémarrera tout seul après une coupure de courant ou un redémarrage du NAS.

### Sur un QNAP

1. Installe **Container Station** depuis l'**App Center**, puis ouvre-le.
2. **Applications** > **Créer**. Nom : `elan`.
3. Ouvre `docker-compose.yml` avec le Bloc-notes, copie tout son contenu et colle-le dans la zone de texte.
4. Dans le texte collé, remplace `./donnees` par le chemin complet du dossier `donnees` copié à
   l'étape 1, par exemple `/share/Container/elan/donnees`. **Créer**.
   (Selon la version de ton NAS, les intitulés peuvent varier légèrement.)

### Sur un autre système (ligne de commande)

Dans le dossier qui contient `docker-compose.yml` :

```bash
docker compose up -d
```

## Étape 3 : vérifier que ça marche

1. Trouve l'**adresse de ton NAS**. C'est celle que tu tapes pour ouvrir son interface, sans ce qui
   suit les deux-points. Si tu ouvres ton NAS avec `http://192.168.1.20:5000`, son adresse est
   `192.168.1.20`. (Sur Synology : **Panneau de configuration** > **Réseau** > **Interface réseau**.)
2. Dans ton navigateur, ouvre cette adresse suivie de **`:8000`** :

   ```
   http://192.168.1.20:8000
   ```

3. Tu dois voir une page **ÉLAN · Serveur personnel**, avec la mention **« ✓ Le serveur fonctionne »**
   et, en dessous, **l'adresse à saisir dans l'app**. Garde cette page ouverte.

Si la page ne s'affiche pas, va à la section [Si quelque chose ne va pas](#si-quelque-chose-ne-va-pas).

## Étape 4 : relier l'app et créer ton compte

1. Installe l'app ÉLAN.
   - **Android** : ouvre `ELAN-vX.apk` et accepte l'installation (l'app ne vient pas du Play Store,
     Android demande donc une autorisation : c'est normal).
   - **Windows** : double-clique sur `ELAN-Installation-vX.exe`. Windows affiche « Windows a protégé
     votre ordinateur » : clique sur **Informations complémentaires**, puis **Exécuter quand même**.
2. Ouvre l'app. Sur l'écran de connexion, touche **Serveur : Serveur ÉLAN**, tout en bas.
3. Choisis **Mon serveur** et saisis l'adresse affichée par la page de l'étape 3,
   par exemple `http://192.168.1.20:8000`. (Sur la page, le bouton **Copier l'adresse** évite de la retaper.)
4. Touche **Vérifier et enregistrer**. L'app contacte ton serveur.
5. L'app te propose de créer le **premier compte** : choisis ton e-mail et un mot de passe
   (8 caractères au moins). Ce compte est le **propriétaire du serveur**.

Tu es connecté : tes courses s'enregistrent maintenant chez toi.

Sur un **second appareil** (ton ordinateur, par exemple), refais les points 1 à 4, puis connecte-toi
avec le même e-mail et le même mot de passe : tes courses s'y affichent.

> L'e-mail ne sert que d'identifiant. Le serveur n'envoie jamais d'e-mail et ne vérifie pas l'adresse.

## Étape 5 (facultative) : ajouter tes proches

Chaque personne a son propre compte et ne voit **que ses propres courses**.

1. Dans l'app, connecté avec le compte propriétaire : **Réglages** > **Gérer les comptes**.
2. **Ajouter un compte** : saisis l'e-mail de la personne et un mot de passe provisoire.
3. Transmets-lui l'adresse du serveur, son e-mail et ce mot de passe. Elle suit l'étape 4
   (sans le point 5), puis change son mot de passe dans **Réglages**.

Depuis le même écran, le propriétaire peut **redonner un mot de passe** à quelqu'un qui a oublié le
sien, ou **supprimer un compte** (ses courses et ses fichiers sont alors effacés du serveur).

---

## Utiliser ÉLAN hors de chez toi

L'adresse `192.168.…` ne fonctionne que **chez toi**, sur ton réseau.

- **Sans rien faire** : dehors, l'app fonctionne quand même. Elle garde tes ajouts et les envoie au
  serveur dès que tu rentres. C'est suffisant pour la plupart des usages.
- **Avec un VPN vers chez toi** (WireGuard, Tailscale, le VPN de ta box ou de ton NAS) : l'app
  synchronise partout, comme à la maison, tant que le VPN est actif.

> **N'ouvre pas le port 8000 sur Internet** (pas de « redirection de port » sur ta box). Ton mot de
> passe y circulerait en clair. L'app refuse d'ailleurs une adresse `http://` qui n'est pas celle
> d'un réseau privé.

## Tes données et leur sauvegarde

Tout est dans **un seul dossier**, nommé **`donnees`**, à côté de `docker-compose.yml` :

```
docker/
  elan/
    docker-compose.yml
    donnees/            <- comptes, courses, photos, justificatifs
      backups/          <- une copie complète par nuit, les 7 dernières
```

- **Chaque nuit à 3 h**, le serveur range tout seul une copie complète dans `donnees/backups`
  (un fichier `.zip` par nuit, les 7 plus récents sont gardés).
- **Mais** ces copies sont sur le même disque que le reste : si le disque du NAS lâche, tout est perdu.
  Inclus donc le dossier **`elan`** dans la sauvegarde habituelle de ton NAS vers un autre endroit
  (sur Synology : **Hyper Backup**, vers un disque externe ou un service en ligne).
- En plus, l'app sait exporter toutes tes courses en Excel : **Réglages** > **Sauvegarde**.

### Retrouver ses données après un problème

1. Arrête le serveur (Synology : **Container Manager** > **Projet** > `elan` > **Action** > **Arrêter**).
2. Remets le dossier `donnees` tel qu'il était dans ta sauvegarde, à côté de `docker-compose.yml`.
   (À partir d'un fichier de `backups` : vide `donnees`, puis dézippe ce fichier à l'intérieur.)
3. Redémarre (**Action** > **Démarrer**). Dans l'app : **Réglages** > **Synchroniser maintenant**.

### Changer de NAS

Copie le dossier `elan` entier (avec `donnees`) sur le nouveau NAS et refais l'étape 2. Dans l'app,
indique la nouvelle adresse (se déconnecter, puis **Serveur** sur l'écran de connexion).

## Mettre à jour le serveur

Les mises à jour sont rares. Tes données ne bougent pas : elles sont dans `donnees`.

- **Synology** : **Container Manager** > **Projet** > `elan` > **Action** > **Arrêter**. Puis onglet
  **Image** : sélectionne `ghcr.io/drekstord/elan-serveur`, **Action** > **Mettre à jour**. Reviens à
  **Projet** > `elan` > **Action** > **Construire**.
  (Selon la version de ton NAS, les intitulés peuvent varier légèrement.)
- **Ligne de commande** : `docker compose pull`, puis `docker compose up -d`.

Si l'app affiche « Ce serveur est plus récent que l'app », mets l'app à jour.
Si elle affiche « Serveur pas à jour », mets le serveur à jour.

---

## Si quelque chose ne va pas

| Ce que tu vois | Ce qu'il faut vérifier |
|---|---|
| La page `http://…:8000` ne s'ouvre pas | Le projet `elan` a-t-il sa pastille verte ? L'adresse est-elle bien celle du NAS ? As-tu bien mis `:8000` à la fin, et `http://` (pas `https://`) au début ? Ton ordinateur est-il sur le même réseau que le NAS ? |
| Le projet ne démarre pas : « port déjà utilisé » (*port is already allocated*) | Un autre programme du NAS occupe le port 8000. Ouvre `docker-compose.yml` avec le Bloc-notes, remplace `"8000:8000"` par `"8010:8000"`, enregistre, puis relance le projet. Ton adresse se termine alors par `:8010`. |
| L'app dit « Serveur injoignable » | Le téléphone est-il sur le Wi-Fi de la maison (ou le VPN est-il actif) ? Ouvre l'adresse dans le navigateur **du téléphone** : si la page ÉLAN ne s'affiche pas, le problème vient du réseau, pas de l'app. |
| L'app dit « Ce n'est pas un serveur ÉLAN » | L'adresse mène à autre chose (souvent l'interface du NAS). Vérifie le `:8000` à la fin. |
| L'app dit « L'adresse doit commencer par https:// » | Tu as saisi un nom de domaine Internet. Utilise l'adresse locale du NAS (`http://192.168.…:8000`). |
| L'app ne propose pas de créer un compte | Le premier compte existe déjà. Connecte-toi, ou demande un compte au propriétaire (étape 5). |
| Un proche a oublié son mot de passe | Le propriétaire lui en redonne un : **Réglages** > **Gérer les comptes**. |
| Le **propriétaire** a oublié son mot de passe | Voir « Mot de passe du propriétaire perdu », ci-dessous. |

### Mot de passe du propriétaire perdu

C'est le seul cas qui demande une commande. Sur Synology : **Container Manager** > **Conteneur** >
`elan` > **Action** > **Ouvrir le terminal** > **Créer**, puis tape (en choisissant ton propre mot de passe) :

```bash
/pb/pocketbase superuser upsert secours@exemple.fr UnMotDePasseDeSecours --dir=/donnees
```

Ouvre ensuite `http://192.168.1.20:8000/_/` dans ton navigateur, connecte-toi avec
`secours@exemple.fr` et ce mot de passe. Dans **users**, clique sur ton compte, saisis un nouveau
mot de passe dans **Password** et **Password confirm**, puis **Save changes**.

## Questions fréquentes

**Combien de place faut-il ?** Le serveur lui-même : quelques dizaines de Mo. Une course avec ses deux
photos : environ 0,5 Mo. Compte quelques Go pour mille courses, les 7 sauvegardes comprises.

**Le serveur consomme-t-il beaucoup ?** Non : moins de 100 Mo de mémoire et presque pas de processeur.

**Qui peut voir mes courses ?** Dans l'app, seulement toi : chaque compte ne voit que ses propres
courses et ses propres fichiers. Le propriétaire gère les comptes, il ne lit pas les courses des
autres. En revanche, la personne qui administre le NAS a accès aux fichiers de son disque, comme
pour tout ce qui y est rangé.

**Et si mon NAS est éteint ?** L'app continue de fonctionner sur chaque appareil. La synchronisation
entre tes appareils reprend quand le NAS est rallumé.

**Comment tout désinstaller ?** Synology : **Projet** > `elan` > **Action** > **Supprimer**. Tes données
restent dans le dossier `donnees` tant que tu ne le supprimes pas toi-même.

**Puis-je revenir au serveur ÉLAN en ligne ?** Dans l'app : se déconnecter, **Serveur**, puis
**Serveur ÉLAN**. Les deux serveurs sont indépendants : les courses ne passent pas de l'un à l'autre.

## Pour les curieux

Le serveur est un seul conteneur, construit sur **PocketBase**, un logiciel libre qui réunit en un
petit programme la gestion des comptes, des données, des fichiers et des sauvegardes. Les données
sont dans une base SQLite, un simple fichier du dossier `donnees`. Le serveur n'envoie aucun e-mail,
ne contacte aucun service extérieur et n'a besoin d'Internet que pour être téléchargé.

Le code de ce serveur est dans le dossier `serveur/image` du projet ÉLAN. Il est testé de bout en
bout à chaque modification : démarrage, comptes, cloisonnement entre comptes, synchronisation avec
l'app, fichiers, redémarrage, sauvegarde.
