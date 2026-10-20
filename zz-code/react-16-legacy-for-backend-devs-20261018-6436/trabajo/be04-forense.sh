#!/bin/sh
# Pieza forense de be04 contra el binario del 3011: token manipulado, alg none, y la versión de la librería.
B=localhost:3011; H='Content-Type: application/json'
TOKEN=$(curl -s -X POST $B/login -H "$H" -d '{"email":"ibatista@esclusa.test","password":"esclusa123"}' | sed 's/.*"token":"\([^"]*\)".*/\1/')
echo "payload legible sin clave: $(echo "$TOKEN" | cut -d. -f2 | tr '_-' '/+' | base64 -d 2>/dev/null)"
# token manipulado: otro sub, la misma firma
P2=$(printf '{"email":"ibatista@esclusa.test","sub":"2","iat":1,"exp":9999999999,"iss":"esclusa-api"}' | base64 | tr '+/' '-_' | tr -d '=\n')
FORGED="$(echo $TOKEN | cut -d. -f1).$P2.$(echo $TOKEN | cut -d. -f3)"
echo "manipulado: $(curl -s -w ' %{http_code}' $B/wheels -H "Authorization: Bearer $FORGED")"
HEADER=$(printf '{"alg":"none","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=\n')
PAYLOAD=$(printf '{"sub":"1","exp":9999999999}' | base64 | tr '+/' '-_' | tr -d '=\n')
echo "alg none: $(curl -s -w ' %{http_code}' $B/wheels -H "Authorization: Bearer $HEADER.$PAYLOAD.")"
echo "== log del servidor"; grep "401:" /tmp/api.log | tail -2
