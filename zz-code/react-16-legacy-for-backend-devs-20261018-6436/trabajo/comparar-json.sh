#!/usr/bin/env bash
# Compara las lecturas del contrato entre el mock (MOCK) y Go (GO), normalizadas con jq -S.
MOCK=${MOCK:-http://mock:3001}; GO=${GO:-http://go:3011}
for path in "/users?email=ibatista@esclusa.test&password=esclusa123" "/wheels?_embed=segments" "/wheels" "/wheels/1" \
            "/segments?wheelId=1" "/players" "/players?name_like=an" "/spinLog?wheelId=4" "/purchases" "/packages" "/grants" "/stock"; do
  a=$(curl -s "$MOCK$path" | jq -S -c .); b=$(curl -s "$GO$path" | jq -S -c .)
  if [ "$a" = "$b" ]; then echo "IGUAL      $path"
  else
    # quita el campo de crecimiento wheelVersion y vuelve a comparar
    b2=$(echo "$b" | jq -S -c 'walk(if type == "object" then del(.wheelVersion) else . end)')
    if [ "$a" = "$b2" ]; then echo "IGUAL+wheelVersion $path"
    else echo "DISTINTO   $path"; diff <(echo "$a" | jq -S . | head -60) <(echo "$b2" | jq -S . | head -60) | head -12; fi
  fi
done
