; =====================================================================
; ÉLAN : installateur Windows (Inno Setup 6), un seul fichier .exe.
;
; Construit par GitHub à chaque version (workflow « Version », job windows) :
;   iscc /DVersion=2.8.0 /DSource=<dossier de l'app compilée> scripts\windows\elan.iss
;
; - Installation pour l'utilisateur seul, sans droits administrateur, au même endroit que
;   « Installer ELAN.cmd » (%LOCALAPPDATA%\Programs\ELAN) : l'un remplace l'autre sans conflit.
; - Mise à jour : relancer un installateur plus récent par-dessus.
; - Les données (session, courses, photos) sont ailleurs (%APPDATA%\com.example\app_course) :
;   ni la mise à jour ni la désinstallation n'y touchent.
; =====================================================================

#ifndef Version
  #define Version "0.0.0"
#endif
#ifndef Source
  #define Source "..\..\build\windows\x64\runner\Release"
#endif

[Setup]
AppId={{F6340A73-36F9-4035-AD2B-15973DEEDEDC}
AppName=ÉLAN
AppVersion={#Version}
AppVerName=ÉLAN {#Version}
AppPublisher=ÉLAN
VersionInfoVersion={#Version}
VersionInfoDescription=Installation d'ÉLAN
DefaultDirName={localappdata}\Programs\ELAN
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\elan.exe
UninstallDisplayName=ÉLAN
WizardStyle=modern
Compression=lzma2/max
SolidCompression=yes
; ÉLAN ouvert pendant une mise à jour : fermé proprement avant de remplacer les fichiers.
CloseApplications=force
RestartApplications=no
OutputDir=..\..\dist
OutputBaseFilename=ELAN-Installation-v{#Version}

[Languages]
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "bureau"; Description: "Créer un raccourci sur le Bureau"; GroupDescription: "Raccourcis :"

[InstallDelete]
; Ressources de la version précédente (polices, textes) : remplacées en entier.
Type: filesandordirs; Name: "{app}\data"

[Files]
Source: "{#Source}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{userprograms}\ÉLAN"; Filename: "{app}\elan.exe"; WorkingDir: "{app}"; Comment: "ÉLAN · Sport & Impact"
Name: "{userdesktop}\ÉLAN"; Filename: "{app}\elan.exe"; WorkingDir: "{app}"; Comment: "ÉLAN · Sport & Impact"; Tasks: bureau

[Run]
Filename: "{app}\elan.exe"; Description: "Lancer ÉLAN"; Flags: nowait postinstall skipifsilent
