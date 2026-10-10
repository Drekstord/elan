# Image du serveur ÉLAN : PocketBase (un seul programme : comptes, données, fichiers, sauvegardes)
# déjà réglé pour l'app. Construite et publiée par GitHub (workflow « Version »), pour
# NAS Intel/AMD et ARM. Les données vivent dans /donnees, à relier à un dossier du NAS.
#
# Changer de version de PocketBase : modifier PB_VERSION, puis laisser le test
# « Serveur ÉLAN » (GitHub) confirmer que tout fonctionne avant de publier.

FROM alpine:3.22 AS telechargement
ARG PB_VERSION=0.40.5
ARG TARGETARCH
RUN apk add --no-cache unzip wget ca-certificates
WORKDIR /tmp/pb
# Programme officiel, vérifié par son empreinte avant d'être accepté.
RUN case "$TARGETARCH" in \
      amd64) arch=amd64 ;; \
      arm64) arch=arm64 ;; \
      arm)   arch=armv7 ;; \
      *) echo "Architecture non prévue : $TARGETARCH" && exit 1 ;; \
    esac \
 && base="https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}" \
 && fichier="pocketbase_${PB_VERSION}_linux_${arch}.zip" \
 && wget -q "$base/$fichier" "$base/checksums.txt" \
 && grep " $fichier\$" checksums.txt | sha256sum -c - \
 && unzip -q "$fichier" pocketbase \
 && chmod +x pocketbase

FROM alpine:3.22
RUN apk add --no-cache ca-certificates tzdata wget
COPY --from=telechargement /tmp/pb/pocketbase /pb/pocketbase
COPY pb_migrations /pb/pb_migrations
COPY pb_hooks /pb/pb_hooks
COPY pb_public /pb/pb_public

# Rattache l'image au dépôt public : elle en hérite la visibilité (téléchargeable sans compte).
LABEL org.opencontainers.image.source="https://github.com/Drekstord/elan" \
      org.opencontainers.image.title="Serveur ÉLAN" \
      org.opencontainers.image.licenses="GPL-3.0-only"

ENV TZ=Europe/Paris
EXPOSE 8000
VOLUME /donnees
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:8000/api/health || exit 1

ENTRYPOINT ["/pb/pocketbase", "serve", \
  "--http=0.0.0.0:8000", \
  "--dir=/donnees", \
  "--migrationsDir=/pb/pb_migrations", \
  "--hooksDir=/pb/pb_hooks", \
  "--publicDir=/pb/pb_public"]
