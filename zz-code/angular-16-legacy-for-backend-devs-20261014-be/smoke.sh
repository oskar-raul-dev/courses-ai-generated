#!/usr/bin/env bash
# smoke.sh — el contrato, ejecutable.
#
# Corre contra CUALQUIER servidor que diga hablar el dialecto de CertCore:
# el mock de la Fase 3 hoy, el backend en PHP desde be03.
#
#   ./smoke.sh                      # contra http://localhost:3000
#   BASE_URL=http://localhost:8000 ./smoke.sh
#
# Requiere curl y jq. Nada más: sin Node, sin PHP, sin frameworks de prueba.
# Es deliberado — el juez del contrato no puede depender de ninguno de los dos
# lados que está juzgando.

set -u   # una variable sin definir es un error; -e NO, porque queremos
         # ejecutar las 26 comprobaciones aunque una falle.

BASE_URL="${BASE_URL:-http://localhost:3000}"
EMAIL="inspector@certcore.co"
PASSWORD="certcore123"

passed=0
failed=0

# Compara lo observado con lo esperado y lo cuenta. Toda la mecánica del
# archivo está en esta función: el resto son llamadas a ella.
check() {
  local description="$1" expected="$2" actual="$3"

  if [ "$expected" = "$actual" ]; then
    passed=$((passed + 1))
    printf '  ✅ %s\n' "$description"
  else
    failed=$((failed + 1))
    printf '  ❌ %s\n     esperado: %s\n     recibido: %s\n' \
      "$description" "$expected" "$actual"
  fi
}

# --- 1. Autenticación -------------------------------------------------------
printf '\n🔐 Autenticación\n'

login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

TOKEN=$(printf '%s' "$login_response" | jq -r '.accessToken // empty')

check "el login devuelve accessToken" "sí" \
  "$([ -n "$TOKEN" ] && echo "sí" || echo "no")"
check "el login devuelve expiresIn numérico" "number" \
  "$(printf '%s' "$login_response" | jq -r '.expiresIn | type')"

# El JWT tiene tres partes separadas por punto. No verificamos la firma acá
# —eso es trabajo del servidor— pero sí que la FORMA sea la que el
# interceptor de la Fase 2 sabe leer.
check "el token tiene tres segmentos" "3" \
  "$(printf '%s' "$TOKEN" | awk -F. '{print NF}')"

# Las credenciales malas responden 401, y el frontend DEPENDE de ese código:
# el interceptor distingue 401 de 500 para decidir si cierra la sesión.
check "credenciales inválidas devuelven 401" "401" \
  "$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/auth/login" \
      -H 'Content-Type: application/json' \
      -d '{"email":"nadie@certcore.co","password":"x"}')"
check "una ruta protegida sin token devuelve 401" "401" \
  "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/inspections")"

AUTH=(-H "Authorization: Bearer $TOKEN")

# --- 2. Forma de las colecciones -------------------------------------------
printf '\n📚 Colecciones\n'

for resource in clients assets templates inspections findings certificates; do
  body=$(curl -s "${AUTH[@]}" "$BASE_URL/$resource")
  # Array DESNUDO, sin sobre. Si alguien envuelve esto en {"data": …} el
  # frontend hace .map sobre un objeto y la pantalla sale en blanco.
  check "GET /$resource devuelve un array" "array" \
    "$(printf '%s' "$body" | jq -r 'type')"
done

# --- 3. El dialecto que el frontend usa de verdad ---------------------------
printf '\n🔤 Dialecto\n'

# Igualdad exacta por campo.
check "?clientId= filtra assets" "true" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/assets?clientId=CLI-001" \
      | jq -r 'all(.[]; .clientId == "CLI-001")')"

# Dos parámetros se combinan con AND. La Fase 7 depende de esto.
check "?templateId=&version= devuelve una sola plantilla" "1" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/templates?templateId=elevator-annual&version=1" \
      | jq -r 'length')"

# El filtro que nadie diseñó y que la Fase 9 consume (FindingApiService).
check "?inspectionId= filtra hallazgos" "array" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/findings?inspectionId=503" | jq -r 'type')"
check "y devuelve sólo los de esa inspección" "true" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/findings?inspectionId=503" \
      | jq -r 'all(.[]; .inspectionId == 503)')"

# Un recurso que no existe es 404, no 200 con cuerpo vacío.
check "un id inexistente devuelve 404" "404" \
  "$(curl -s -o /dev/null -w '%{http_code}' "${AUTH[@]}" "$BASE_URL/clients/NO-EXISTE")"

# --- 4. Las rarezas que son contrato ---------------------------------------
printf '\n🔍 Rarezas del contrato\n'

# El id compuesto. Si el backend nuevo devuelve 7 en vez de
# "elevator-annual-v2", la pantalla de plantillas se rompe entera.
check "el id de plantilla es compuesto" "elevator-annual-v2" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/templates?templateId=elevator-annual&version=2" \
      | jq -r '.[0].id')"
check "y el identificador lógico vive en templateId" "elevator-annual" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/templates?templateId=elevator-annual&version=2" \
      | jq -r '.[0].templateId')"

# validUntil null significa "vigente indefinidamente". No es ausencia de dato.
check "la v2 tiene validUntil null" "null" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/templates?templateId=elevator-annual&version=2" \
      | jq -r '.[0].validUntil')"

# status GUARDADO, no derivado. Es un error de diseño y es contrato.
check "el certificado trae status guardado" "string" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/certificates/CERT-2023-000501" | jq -r '.status | type')"

# La inspección 501 es la bomba del curso: v1, tres respuestas.
check "la inspección 501 declara templateVersion 1" "1" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/inspections/501" | jq -r '.templateVersion')"
check "y guarda sus tres respuestas" "3" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/inspections/501" | jq -r '.answers | length')"

# El objeto completo, sin paginar. Documentamos la deuda ejecutándola.
check "GET /inspections devuelve las respuestas embebidas" "true" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/inspections" | jq -r 'all(.[]; has("answers"))')"

# --- 5. Fechas --------------------------------------------------------------
printf '\n🕐 Fechas\n'

# Offset explícito, nunca Z ni fecha desnuda. La Fase 10 entera vive de esto.
check "los instantes llevan offset -05:00" "true" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/certificates" \
      | jq -r 'all(.[]; .validUntil | test("[+-][0-9]{2}:[0-9]{2}$"))')"
# Las vigencias de plantilla son días, NO instantes. Son dos tipos distintos y
# confundirlos en be03 produce el peor bug del track.
check "las vigencias de plantilla son días desnudos" "true" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/templates" \
      | jq -r 'all(.[]; .validFrom | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$"))')"

# --- 6. Escritura -----------------------------------------------------------
printf '\n✍️  Escritura\n'

patch_response=$(curl -s -X PATCH "$BASE_URL/inspections/500" "${AUTH[@]}" \
  -H 'Content-Type: application/json' \
  -d '{"status":"in_progress"}')

# PATCH devuelve el objeto COMPLETO, no sólo lo modificado ni un 204. El
# autosave de la Fase 8 se apoya en eso.
check "PATCH devuelve el objeto completo" "true" \
  "$(printf '%s' "$patch_response" | jq -r 'has("answers") and has("assetId")')"

# --- Resultado --------------------------------------------------------------
total=$((passed + failed))
printf '\n'
if [ "$failed" -eq 0 ]; then
  printf 'OK: %d/%d\n' "$passed" "$total"
  exit 0
fi
printf 'FALLOS: %d de %d\n' "$failed" "$total"
exit 1
