#!/usr/bin/env bash
# Publie une version d'ÉLAN.
#
#   bash scripts/publier.sh 2.9.0
#
# Deux dépôts GitHub :
#   origin  (privé,  Drekstord/elan-dev)  le travail au quotidien, avec tout son historique ;
#   public  (public, Drekstord/elan)      une photo du code par version : un commit par version,
#                                         jamais l'historique de travail (il contient d'anciennes
#                                         données personnelles : noms de courses, alias e-mail).
#
# Le script envoie « main » sur le dépôt privé, ajoute au dépôt public un commit contenant
# exactement le code de « main », pose l'étiquette vX.Y.Z dessus et l'envoie : GitHub construit
# alors l'APK, l'installateur Windows, l'image Docker du serveur et le paquet du serveur.
#
# Ne jamais pousser « main » ni une ancienne étiquette (avant v2.9.0) vers « public » à la main.
set -euo pipefail
cd "$(dirname "$0")/.."

version=${1:-}
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Usage : bash scripts/publier.sh 2.9.0" >&2; exit 1; }
etiquette="v$version"

arret() { echo "Arrêt : $*" >&2; exit 1; }

[ "$(git branch --show-current)" = main ] || arret "se placer sur la branche main."
[ -z "$(git status --porcelain --untracked-files=no)" ] || arret "des modifications ne sont pas enregistrées (git status)."
grep -q "^version: $version+" pubspec.yaml || arret "pubspec.yaml n'est pas en version $version."
git remote get-url public >/dev/null 2>&1 || arret "remote « public » absent (git remote add public https://github.com/Drekstord/elan.git)."
[ "$(gh repo view "$(git remote get-url origin)" --json visibility --jq .visibility)" = PRIVATE ] || arret "origin devrait être le dépôt privé."
git rev-parse -q --verify "refs/tags/$etiquette" >/dev/null && arret "l'étiquette $etiquette existe déjà."

# Garde-fous : rien de personnel ni de secret dans ce qui part en public.
if git grep -nIE "passmail|supabase\.co/|sb_(publishable|secret)_[A-Za-z0-9]{8}|BEGIN (RSA |EC )?PRIVATE KEY" -- . ':!scripts/publier.sh' ':!docs/CLOUD.md' ':!config/supabase.example.json'; then
  arret "le code contient une adresse ou une clé qui ne doit pas être publiée (lignes ci-dessus)."
fi
if git ls-files | grep -iE "(^|/)(supabase\.json|key\.properties|.*\.jks|.*\.keystore|\.env|Idee_app\.txt)$"; then
  arret "un fichier secret ou personnel est suivi par git (ci-dessus)."
fi

echo "Envoi de main sur le dépôt privé..."
git push -q origin main

echo "Commit de la version $version sur le dépôt public..."
git fetch -q public main
arbre=$(git rev-parse "main^{tree}")
if [ "$arbre" = "$(git rev-parse "public/main^{tree}")" ]; then
  commit=$(git rev-parse public/main)
else
  commit=$(git commit-tree "$arbre" -p public/main -m "ÉLAN $version")
fi
git push -q public "$commit:refs/heads/main"

git tag -a "$etiquette" "$commit" -m "ÉLAN $version"
git push -q public "refs/tags/$etiquette"

echo
echo "Version $version envoyée. Construction en cours :"
echo "  https://github.com/Drekstord/elan/actions"
echo "Fichiers, une fois prêts :"
echo "  https://github.com/Drekstord/elan/releases/tag/$etiquette"
