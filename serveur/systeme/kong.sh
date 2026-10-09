#!/bin/sh
# Démarrage de la porte d'entrée (Kong), d'après la composition officielle de Supabase :
# remplace les $VARIABLES de kong.yml par les valeurs du fichier .env, puis lance Kong.

# Une session ouverte (Authorization) passe telle quelle ; sinon la clé publique (apikey) sert de jeton.
export LUA_AUTH_EXPR="\$((headers.authorization ~= nil and headers.authorization:sub(1, 10) ~= 'Bearer sb_' and headers.authorization) or headers.apikey)"

awk '{
  result = ""
  rest = $0
  while (match(rest, /\$[A-Za-z_][A-Za-z_0-9]*/)) {
    varname = substr(rest, RSTART + 1, RLENGTH - 1)
    if (varname in ENVIRON) {
      result = result substr(rest, 1, RSTART - 1) ENVIRON[varname]
    } else {
      result = result substr(rest, 1, RSTART + RLENGTH - 1)
    }
    rest = substr(rest, RSTART + RLENGTH)
  }
  print result rest
}' /home/kong/temp.yml > "$KONG_DECLARATIVE_CONFIG"

exec /entrypoint.sh kong docker-start
