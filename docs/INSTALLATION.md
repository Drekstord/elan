# ÉLAN : Installer l'application

**Le plus simple, sans rien compiler** : les fichiers de chaque version sont sur
**github.com/Drekstord/elan/releases** (téléchargement libre, sans compte).

| Fichier | Pour |
|---|---|
| `ELAN-Installation-v….exe` | Windows : double-clic, **Installer** |
| `ELAN-v….apk` | Android (voir « Installer sur le téléphone », plus bas) |
| `ELAN-serveur-v….zip` | Héberger son propre serveur ([serveur/LISEZMOI.md](../serveur/LISEZMOI.md)) |

La suite de ce document explique comment les construire soi-même depuis le code.

---

Prérequis communs : le projet récupéré (`git clone https://github.com/Drekstord/elan.git`)
et le fichier `config/supabase.json` rempli (voir [CLOUD.md](CLOUD.md)).
La configuration est **intégrée à l'application au moment de la compilation** :
une fois installée, l'app se lance comme n'importe quel logiciel, sans ligne de commande.

---

## Windows

### Avec l'installateur (recommandé)
1. Télécharger `ELAN-Installation-v….exe` depuis la dernière release.
2. Double-cliquer. L'installateur n'est pas signé (un certificat coûte 100 à 300 € par an) :
   Windows affiche « Windows a protégé votre ordinateur ». Cliquer sur **Informations
   complémentaires**, puis **Exécuter quand même**.
3. **Installer**, puis lancer **ÉLAN** depuis le menu Démarrer.

Mise à jour : lancer l'installateur d'une version plus récente par-dessus, les données sont conservées.
Désinstallation : **Paramètres** > **Applications** > **ÉLAN** > **Désinstaller**.
Pas besoin de droits administrateur. L'installateur remplace sans conflit une installation faite
avec `Installer ELAN.cmd` (même dossier, mêmes raccourcis).

### Depuis le code

#### Prérequis (une seule fois, sur un nouveau PC)
Flutter et les **Build Tools de Visual Studio** avec la charge « Développement Desktop en C++ »
**et le composant « C++ ATL »** (requis par le module de notifications). Pour ajouter ATL à des
Build Tools déjà installés (une validation administrateur est demandée) :
```powershell
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe" modify --installPath "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools" --add Microsoft.VisualStudio.Component.VC.ATL --passive --norestart
```
Sans lui, la compilation s'arrête sur « Impossible d'ouvrir le fichier include : 'atlbase.h' ».

#### Installer / mettre à jour
1. Double-cliquer sur **`Installer ELAN.cmd`** à la racine du projet.
2. Patienter 1 à 3 minutes (compilation de la version optimisée).
3. Lancer **ÉLAN** depuis le **menu Démarrer** ou le **raccourci du Bureau**.

Pour mettre à jour après une modification du code : relancer `Installer ELAN.cmd`.

Détails :
- l'application est installée dans `%LOCALAPPDATA%\Programs\ELAN` (pas besoin de droits administrateur) ;
- tes données (session, courses, photos) sont dans `%APPDATA%\com.example\app_course` : les mises à jour n'y touchent pas.

#### Désinstaller
Dans un terminal PowerShell, à la racine du projet :
```powershell
powershell -ExecutionPolicy Bypass -File scripts\windows\installer.ps1 -Uninstall
```

---

## Android (téléphone)

La première fois, il faut installer les outils Android sur le PC (≈ 30 min, surtout du téléchargement).
Ensuite, chaque mise à jour prend quelques minutes.

### Étape 1 : Installer Android Studio (une seule fois)
1. Télécharger Android Studio : **https://developer.android.com/studio** (bouton *Download Android Studio*),
   ou dans un terminal : `winget install --id Google.AndroidStudio`.
2. Lancer l'installation, tout laisser par défaut.
3. Ouvrir Android Studio. L'assistant de premier lancement apparaît :
   - choisir **Standard** ;
   - accepter les licences (cliquer sur chaque licence à gauche, puis *Accept*) ;
   - **Finish** : il télécharge le SDK Android (plusieurs Go, patienter).
4. Sur l'écran d'accueil d'Android Studio : **More Actions** (ou ⋮) > **SDK Manager**.
   - Onglet **SDK Tools** : cocher **Android SDK Command-line Tools (latest)** ;
   - **Apply**, puis **OK**.
5. Android Studio peut être fermé ; il n'est plus nécessaire ensuite.

### Étape 2 : Vérifier les outils (une seule fois)
Dans un terminal :
```powershell
flutter doctor
```
La ligne **Android toolchain** doit être cochée ✓.
(Avec les outils Android récents, `flutter doctor --android-licenses` répond que les licences
ne sont plus nécessaires : c'est normal.)

Puis installer le **NDK** utilisé par le projet (≈ 2 Go, une seule fois) :
```powershell
& "$env:LOCALAPPDATA\Android\sdk\cmdline-tools\latest\bin\android.exe" sdk install "ndk/28.2.13676358"
```
Sans lui, la construction s'arrête sur « sdkmanager did not install NDK ».

### Étape 3 : Construire l'application
Double-cliquer sur **`Construire APK Android.cmd`** à la racine du projet.
La première construction prend 5 à 10 minutes. Résultat : **`dist\ELAN.apk`**.

### Étape 4 : Installer sur le téléphone

**Méthode A : sans câble (la plus simple)**
1. Envoyer `dist\ELAN.apk` sur le téléphone : par Proton Drive, Google Drive, e-mail à toi-même,
   ou en copiant le fichier par câble USB (mode « Transfert de fichiers »).
2. Sur le téléphone, ouvrir le fichier `ELAN.apk` (depuis l'app Fichiers, Drive…).
3. Android demande l'autorisation d'**installer des applications inconnues** pour l'app utilisée
   (Fichiers, Drive…) : **Paramètres** > activer **Autoriser cette source**, puis revenir.
4. **Installer**. Si Play Protect affiche un avertissement (« app inconnue ») :
   **Plus de détails** > **Installer quand même**. C'est normal pour une app qui ne vient pas du Play Store.
5. Ouvrir **ÉLAN**, se connecter avec le même e-mail et mot de passe que sur le PC :
   les courses se téléchargent automatiquement.

**Méthode B : par câble, en une commande**
1. Sur le téléphone, activer les **options pour les développeurs** :
   **Paramètres** > **À propos du téléphone** > appuyer **7 fois** sur **Numéro de build**.
2. **Paramètres** > **Système** > **Options pour les développeurs** > activer **Débogage USB**.
3. Brancher le téléphone au PC ; accepter « Autoriser le débogage USB » sur le téléphone.
4. Après l'étape 3 (APK construit), dans un terminal à la racine du projet :
   ```powershell
   flutter install --release
   ```

### Mettre à jour l'app sur le téléphone
**Le plus simple : l'APK construit par GitHub** (aucun PC nécessaire).
À chaque étiquette de version (`v2.6.0`…), GitHub lance les tests, construit l'APK et le publie :
1. Sur le téléphone, ouvrir **github.com/Drekstord/elan/releases** (sans compte).
2. Dernière version > **Assets** > `ELAN-v….apk` : télécharger, ouvrir, **Mettre à jour**.

Construction à la demande, sans étiquette : onglet **Actions** > **Version** > **Run workflow** ;
l'APK (et l'installateur Windows) se téléchargent ensuite depuis la page de l'exécution (rubrique *Artifacts*, 30 jours).

Les secrets nécessaires (configuration Supabase, clé de signature d'ÉLAN) sont enregistrés dans le dépôt :
*Settings > Secrets and variables > Actions*. Ils ne sont jamais écrits dans le code.

**Ou depuis le PC** : refaire l'étape 3, puis réinstaller `ELAN.apk` (méthode A ou B) : Android propose
**Mettre à jour**, tes données sont conservées.

> **Important : clé de signature.** Android n'accepte une mise à jour que si elle est signée
> avec la même clé. Depuis la version 2.9, ÉLAN a **sa propre clé** (RSA 4096, valable jusqu'en 2054) :
> - `android/app/elan-release.jks` et son mot de passe dans `android/key.properties`, sur ce PC
>   (ignorés par git, sauvegardés par Proton Drive avec le dossier du projet) ;
> - une copie dans les secrets GitHub, pour les APK construits par GitHub.
>
> **Garde aussi ces deux fichiers dans ton gestionnaire de mots de passe** : sans eux, plus aucune
> mise à jour possible (il faudrait désinstaller l'app partout et repartir d'une nouvelle clé).
>
> Passage de l'ancienne clé (débogage de ce PC, jusqu'à la 2.8) à la nouvelle : **une seule fois**,
> synchroniser, désinstaller ÉLAN du téléphone, installer la nouvelle version, se reconnecter.
> Les courses sont sur le serveur, rien n'est perdu. Les mises à jour suivantes se font par-dessus.
