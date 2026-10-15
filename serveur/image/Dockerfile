# Image du serveur ÉLAN : PocketBase (un seul programme : comptes, données, fichiers, sauvegardes)
# déjà réglé pour l'app. Construite et publiée par GitHub (workflow « Version »), pour
# NAS Intel/AMD et ARM. Les données vivent dans /donnees, à relier à un dossier du NAS.
#
# Changer de version de PocketBase : modifier PB_VERSION et les trois empreintes PB_SHA256_*
# (fichier checksums.txt de la version), puis laisser le test « Serveur ÉLAN » (GitHub)
# confirmer que tout fonctionne avant de publier.

FROM alpine:3.22 AS telechargement
ARG PB_VERSION=0.40.5
# Empreintes notées ici, pas lues sur le serveur de téléchargement : un fichier altéré
# à la source serait refusé.
ARG PB_SHA256_amd64=1dbea1b01eb3dfe64953513859d01e759c96650c4e3264fa4eecd54b769382e4
ARG PB_SHA256_arm64=570baa1c45d2fb92fc0073582b945ca0ece03cbf9837ccabf49a222f99dd02e3
ARG PB_SHA256_armv7=14718c29f71c266b571a74d9b6d90e2924beec72404ed1c4294733c0570ae612
ARG TARGETARCH
RUN apk add --no-cache unzip wget ca-certificates
WORKDIR /tmp/pb
# Programme officiel, vérifié par son empreinte avant d'être accepté.
RUN case "$TARGETARCH" in \
      amd64) arch=amd64; empreinte="$PB_SHA256_amd64" ;; \
      arm64) arch=arm64; empreinte="$PB_SHA256_arm64" ;; \
      arm)   arch=armv7; empreinte="$PB_SHA256_armv7" ;; \
      *) echo "Architecture non prévue : $TARGETARCH" && exit 1 ;; \
    esac \
 && fichier="pocketbase_${PB_VERSION}_linux_${arch}.zip" \
 && wget -q "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/$fichier" \
 && echo "$empreinte  $fichier" | sha256sum -c - \
 && unzip -q "$fichier" pocketbase \
 && chmod +x pocketbase

FROM alpine:3.22
# su-exec : le serveur tourne sous l'utilisateur « elan », sans les droits d'administrateur.
RUN apk add --no-cache ca-certificates tzdata wget su-exec \
 && addgroup -S -g 1000 elan && adduser -S -D -H -u 1000 -G elan elan
COPY --from=telechargement /tmp/pb/pocketbase /pb/pocketbase
COPY pb_migrations /pb/pb_migrations
COPY pb_hooks /pb/pb_hooks
COPY pb_public /pb/pb_public
COPY --chmod=755 demarrer.sh /pb/demarrer
COPY --chmod=755 mot-de-passe-proprietaire.sh /pb/mot-de-passe-proprietaire
COPY --chmod=755 fermer-administration.sh /pb/fermer-administration

# Rattache l'image au dépôt public : elle en hérite la visibilité (téléchargeable sans compte).
LABEL org.opencontainers.image.source="https://github.com/Drekstord/elan" \
      org.opencontainers.image.title="Serveur ÉLAN" \
      org.opencontainers.image.licenses="GPL-3.0-only"

ENV TZ=Europe/Paris
EXPOSE 8000
VOLUME /donnees
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:8000/api/health || exit 1

ENTRYPOINT ["/pb/demarrer"]
