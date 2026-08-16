# 📜 Fase be00 — El contrato: auditoría del mock

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be00 de be07 · **6 horas**
> Depende de: **Fase 10 del track base terminada** (`fase-10`) · Habilita: be01
> Apéndices de apoyo: ninguno todavía · Incidentes asociados: ninguno
> Estilo de esta fase: **no se escribe PHP.** Se observa, se anota y se automatiza la observación

> 🔥 **Esta fase pertenece al track opcional de backend.** No es requisito de nada del track base: si terminaste la Fase 14 y cerraste el curso, ya está cerrado. Esto es lo que sigue para quien quiera bajar una capa.

---

## 🎯 1. Propósito

Saber exactamente qué promete el servidor que vas a apagar, **antes** de escribir una línea de PHP.

Durante diez fases le hablaste a `npm run mock`. En algún momento de be03 lo vas a apagar y en su lugar va a estar un contenedor con PHP y PostgreSQL, escuchando en el mismo puerto 3000, y la aplicación Angular no va a cambiar ni un archivo. Para que eso salga bien hay una condición, y es toda esta fase: **tener escrito, con precisión de abogado, qué respondía el mock**. No lo que tú crees que respondía. Lo que respondía.

> 🧭 **La regla que gobierna el track entero, y empieza aquí:** el contrato no es lo que el servidor *pretende* devolver, es **lo que el cliente ya consume**. Un campo que nadie lee se puede cambiar; un campo que una plantilla pinta, no — aunque esté mal, aunque sobre, aunque su nombre sea una vergüenza.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `CONTRACT.md` existe en la raíz del proyecto y documenta **los seis recursos y el login**, cada uno con su forma de petición y su forma de respuesta, capturadas del tráfico real.
- [ ] `smoke.sh` existe, es ejecutable (`chmod +x`) y **pasa en verde contra `npm run mock`**. Su salida final es literalmente `OK: 24/24`.
- [ ] `smoke.sh` **falla en rojo** si cambias a mano un solo campo del `db.json` — por ejemplo el `id` de una plantilla. Lo comprobaste y lo volviste a dejar bien con `npm run seed`.
- [ ] La tabla del **dialecto de json-server** está escrita: qué parámetros de consulta usa de verdad el frontend de CertCore, cuáles existen pero nadie usa, y cuáles hay que reimplementar sí o sí.
- [ ] Los **seis modos del inyector de caos** están inventariados con su vía de activación, incluido el que manipula el TTL del token.
- [ ] `git diff fase-10-certificados-vigencia..HEAD -- src/` devuelve **vacío**. Es la comprobación que abre el track y la que vas a repetir al cerrar cada una de las ocho fases: el backend se adapta al contrato, nunca al revés.
- [ ] Sabes explicar, sin mirar, **por qué `certificates.status` es un campo guardado**, por qué el `id` de una plantilla es compuesto, y por qué `GET /inspections` devuelve el objeto entero.

---

## 🚫 3. Qué NO entra todavía

- **Una sola línea de PHP** → be01. Esta fase audita y documenta; no construye.
- **PostgreSQL, migraciones, esquema** → be03.
- **El inyector de caos reimplementado** → be01. Aquí sólo se inventaría el que ya existe.
- **Paginación de servidor** → be03. Aquí sólo se constata que no existe.
- **Cualquier juicio sobre si el contrato está bien diseñado.** Lo está en parte y en parte no, y esa conversación es de be02 y be07. Hoy el contrato no se critica: se transcribe.

---

## 🧠 4. Concepto mínimo

### El contrato observado, y por qué no se lee del código

La tentación, con `mock/` a un `cd` de distancia, es abrir `server.js` y transcribir las rutas. **No lo hagas, y el motivo no es pedagógico: es que te vas a equivocar.**

Un servidor tiene siempre dos contratos. Está el que su código *podría* servir —todas las rutas que json-server expone automáticamente, todos los parámetros que acepta, todos los códigos que sabe devolver— y está el que el cliente *consume de verdad*, que es un subconjunto pequeño y caprichoso. Reimplementar el primero es meses de trabajo inútil. Reimplementar el segundo es be03.

Y hay una asimetría que sólo se ve capturando: el frontend usa cosas que el mock nunca prometió. `GET /inspections/501/findings` funciona porque json-server genera rutas anidadas cuando una colección tiene un campo `<recurso>Id`. Nadie la diseñó. Nadie la documentó. El `FindingApiService` de la Fase 9 la usa, así que **es contrato**, con el mismo peso que si estuviera en un OpenAPI firmado.

> 🧠 **Un contrato de facto pesa igual que uno de derecho, y es más difícil de encontrar** — porque nadie lo escribió, y porque el día que lo rompes el error no aparece en el servidor: aparece tres capas más allá, en un `*ngFor` que recibe `undefined`.

### De dónde salió este backend: la Era 0

Antes de escribir el contrato conviene saber de quién es. Está en [`00-historia-del-sistema.md`](00-historia-del-sistema.md), en la **Era 0 (2016-2018)**, y es el cimiento de todo el track:

`certcore-api` **es de 2016**. Es anterior a la aplicación Angular, anterior a CertCore como producto, anterior a casi todo el que hoy trabaja en la empresa. La empresa certificaba ascensores y calderas antes de tener una sola pantalla: la operación vivía en hojas de cálculo y en una intranet PHP, y la API nació para que esa intranet dejara de escribir en el Excel compartido.

Y el dato que ordena el track: **nadie la revisó nunca**. No hubo una decisión mala. Hubo una decisión buena en 2016 y ninguna decisión más durante ocho años.

Tres rarezas que arrastras desde la Fase 3 del track base, y que hoy por fin tienen explicación:

| Lo que te pareció raro | De dónde viene |
|---|---|
| `GET /inspections` devuelve las inspecciones **enteras**, con todas sus respuestas, sin paginar | En 2016 había cuarenta inspecciones al año. Devolver el objeto completo era correcto y era más simple |
| `certificates.status` está **guardado** como dato, pudiendo derivarse de `validUntil` | La intranet de 2016 no tenía dónde calcular nada al vuelo: lo que se mostraba tenía que estar en una columna |
| El `id` de una plantilla es **compuesto** (`elevator-annual-v2`) con el identificador lógico aparte en `templateId` | Nadie lo diseñó. Alguien necesitó dos versiones de la misma plantilla, la clave primaria ya era el nombre, y concatenó |

Las tres son la misma historia contada tres veces: **una decisión razonable en su momento, congelada por ausencia de revisión.** Ninguna es estupidez. Todas son deuda.

### Y la defensa de Lumen, antes de la primera factura

El track te va a cobrar ocho facturas y conviene poner esto ahora, porque después de la tercera vas a querer decir que elegir Lumen fue una tontería. No lo fue.

En 2016, una empresa mediana latinoamericana con dos personas que sabían PHP del intranet viejo y ninguna que supiera otra cosa, que necesitaba una API REST pequeña y rápida: Lumen era **la decisión sensata**. Era el microframework del ecosistema más grande del mundo PHP, arrancaba en milisegundos, no arrastraba la ceremonia de Laravel completo, y lo podía mantener la gente que ya estaba. El beneficio se cobró durante años, y en be07 vas a tener que ponerle un número a ese beneficio.

> 🧭 **El pecado no fue elegirlo. Fue elegirlo para *un servicio*, acertar, y que nadie volviera a decidir nunca.** Una decisión correcta que no se revisa en ocho años deja de ser correcta sin que nadie lo note, porque nadie estaba mirando.

### Régimen estricto y régimen de crecimiento

Esta distinción decide, fase por fase, qué te puedes permitir. Anótala en el `CONTRACT.md` porque la vas a consultar cincuenta veces:

**Régimen estricto** — lo que el frontend ya consume. No se toca, ni para mejorarlo. Nombres de campo, tipos, forma del sobre, códigos de estado, el formato de las fechas con offset. Si `CertificateListComponent` lee `certificate.status`, el backend nuevo devuelve `status` aunque en be05 pase a ser derivado. **Cambiar aquí significa tocar el frontend, y el frontend no se toca.**

**Régimen de crecimiento** — lo que el backend puede añadir sin romper nada. Campos nuevos que nadie lee todavía, endpoints nuevos, cabeceras nuevas, códigos de estado nuevos en rutas que el frontend no ejerce. Un cliente que ignora lo que no conoce te deja crecer; un cliente que valida estrictamente su entrada, no. **El de CertCore ignora**, y eso lo sabes porque los modelos de la Fase 3 declaran los campos que usan y `HttpClient` no valida nada.

> ⚠️ Y el corolario incómodo, que es la mitad de be03: **el régimen de crecimiento no te salva de un campo de más en el sitio equivocado.** Si añades `pageSize` al sobre de `GET /templates` y el componente hace `templates.map(...)` sobre la respuesta cruda, acabas de romperlo. Crecer es añadir campos *dentro* de los objetos, no cambiar la forma de lo que envuelve.

---

## 💻 5. Código mínimo con comentarios

### 5.1 La captura: el procedimiento, no la herramienta

Seis recorridos, uno por recurso, con el mock limpio (`npm run seed && npm run mock`) y **sin ningún flag de caos**. En cada uno:

1. DevTools abierto en Network, filtro `Fetch/XHR`, **`Preserve log` activado** — sin él, la redirección del login te borra la primera petición, que es justo la que necesitas.
2. Haces el recorrido con la aplicación, no con `curl`. Lo que importa es lo que **el cliente** pide, incluidos los parámetros que añade solo.
3. De cada petición anotas cinco cosas: método, URL **completa con query string**, cabeceras que el cliente manda, código de respuesta, y el cuerpo crudo desde la pestaña **Response** —no desde Preview, que te lo pinta bonito y te oculta si un número vino como cadena—.

| Recorrido | Qué ejercita | Peticiones que tienen que salir |
|---|---|---|
| Entrar con `inspector@certcore.co` | Fase 2 | `POST /auth/login` |
| Abrir Clientes y entrar a uno | Fase 6 | `GET /clients`, `GET /clients/:id`, `GET /assets?clientId=:id` |
| Abrir Plantillas y ver una versión | Fase 7 | `GET /templates`, `GET /templates?templateId=…&version=…` |
| Abrir la inspección 501 y responder un ítem | Fases 8 y 9 | `GET /inspections/501`, `PATCH /inspections/501`, `GET /inspections/501/findings` |
| Abrir un certificado y descargarlo | Fase 10 | `GET /certificates`, `GET /certificates/:id` |
| Abrir el panel | Fase 11 | las cuatro anteriores, en ráfaga cada minuto |

> 💡 **El truco que ahorra media hora:** con Network abierto, clic derecho sobre una petición → *Copy* → *Copy as cURL*. Te da la petición exacta, con todas las cabeceras, lista para pegar en una terminal. Es la traducción literal de "lo que el cliente manda" a "lo que puedo reproducir sin el cliente", y es la materia prima del `smoke.sh`.

### 5.2 `CONTRACT.md` — la forma del documento

No es prosa. Es una ficha por recurso, siempre igual, porque en be03 la vas a leer con la mirada de quien busca un campo concreto a las siete de la tarde.

```markdown
<!-- CONTRACT.md — extracto de la ficha de un recurso -->

## GET /templates

**Quién lo llama:** `TemplateApiService.getAll()` (Fase 4), desde
`TemplateStateService.load()`.

**Petición**
- Cabeceras que manda el cliente: `Authorization: Bearer <jwt>`, `Accept: application/json`.
- Parámetros de consulta usados por el frontend: **ninguno** en esta llamada.

**Respuesta 200** — array desnudo, sin sobre. Tres elementos con la semilla limpia.

​```json
[
  { "id": "elevator-annual-v1", "templateId": "elevator-annual", "version": 1,
    "validFrom": "2021-01-01", "validUntil": "2023-12-31", "items": [ … ] },
  { "id": "elevator-annual-v2", "templateId": "elevator-annual", "version": 2,
    "validFrom": "2024-01-01", "validUntil": null, "items": [ … ] },
  { "id": "boiler-annual-v1", "templateId": "boiler-annual", "version": 1,
    "validFrom": "2022-01-01", "validUntil": null, "items": [ … ] }
]
​```

**Régimen:** estricto. `id`, `templateId`, `version`, `validFrom`, `validUntil` e
`items[].{id,title,criteria,photoRequired,nonComplianceSeverity}` los lee el
frontend. Cualquier campo adicional cae en régimen de crecimiento.

**Trampas**
- `validUntil: null` significa **"vigente indefinidamente"**, no "sin datos".
  `resolveTemplateVersion` depende de esa lectura.
- El array **no viene ordenado** por nada garantizado. json-server devuelve el
  orden de inserción del `db.json`; el frontend no ordena. Si el backend nuevo
  devuelve otro orden, la pantalla cambia sin que nadie haya tocado la pantalla.
```

Repite esa ficha para `/clients`, `/assets`, `/templates`, `/inspections`, `/findings`, `/certificates` y `/auth/login`. Son siete fichas, y son el entregable.

**Detalles con intención**
- **"Quién lo llama" va primero, antes que la forma.** Cuando en be03 rompas algo, la pregunta no va a ser "¿qué devuelve este endpoint?" sino "¿quién se va a enterar?". La ficha tiene que contestar eso en la primera línea.
- **"Trampas" no es una sección de relleno.** Cada una de las que escribas hoy es un `smoke.sh` en rojo que te vas a ahorrar. El orden no garantizado de `/templates` es responsable, él solo, de dos incidentes del track base.
- **El sobre se documenta aunque no exista.** "Array desnudo, sin sobre" es una afirmación fuerte y hay que escribirla: es lo que impide que en be03 alguien devuelva `{ "data": [...] }` porque le pareció más profesional.

### 5.3 El dialecto de json-server, medido

json-server 0.17.4 acepta una cantidad enorme de parámetros. CertCore usa cuatro. Esta tabla es lo que be03 tiene que reimplementar, ni más ni menos:

| Forma | ¿La usa el frontend? | Dónde | Qué hay que hacer en be03 |
|---|---|---|---|
| `GET /recurso` | ✅ | los seis `*ApiService` | Reimplementar |
| `GET /recurso/:id` | ✅ | detalles | Reimplementar |
| `?campo=valor` (igualdad exacta) | ✅ | `assets?clientId=…`, `templates?templateId=…&version=…` | Reimplementar. **Varios parámetros se combinan con AND** |
| `GET /inspections/:id/findings` (ruta anidada) | ✅ | `FindingApiService.getByInspection()` | Reimplementar. **Nadie la diseñó y es contrato** |
| `_page` / `_limit` + `X-Total-Count` | ❌ | — | **No implementar todavía.** Es la 💸 1 y se paga en be03, con el frontend intacto |
| `_sort` / `_order` | ❌ | — | No implementar. Ojo: **no usarlo no significa que el orden dé igual** (ver trampa de `/templates`) |
| `_embed` / `_expand` | ❌ | — | No implementar |
| `q` (búsqueda de texto completo) | ❌ | el filtro de clientes es **en cliente**, sobre la lista ya cargada | No implementar |
| `POST` / `PUT` / `PATCH` / `DELETE` | ✅ salvo `PUT` | `PATCH` en inspecciones y hallazgos; `POST` en clientes y plantillas | Reimplementar los tres usados |

```
💸 DEUDA TÉCNICA INTENCIONAL — el contrato no tiene paginación
GET /inspections devuelve las cinco inspecciones enteras, con todas sus
respuestas. El frontend no manda _page ni _limit porque el mock nunca se lo
pidió, y con cinco filas nadie lo notó.
SE PAGA EN be03, y con una restricción que la vuelve interesante: la paginación
se añade SIN QUE EL FRONTEND CAMBIE. Un cliente que no manda _page tiene que
seguir recibiendo todo. La compatibilidad hacia atrás no es un adorno: es la
regla del track.
```

### 5.4 El inyector de caos, inventariado

Lo construiste en la Fase 3 y en be01 lo vas a reimplementar en PHP con el mismo comportamiento. Aquí se anota exactamente qué hace, porque "más o menos lo mismo" no basta: los ejercicios de diagnóstico de la Fase 3 tienen que poder repetirse contra el backend nuevo **sin cambiar una palabra del enunciado**.

| Modo | Activación | Qué hace | Dónde vive |
|---|---|---|---|
| `latency` | `CHAOS=latency`, `CHAOS_DELAY_MS` (por defecto 2500) | Retrasa **toda** respuesta | middleware |
| `error` | `CHAOS=error`, `CHAOS_RATE` (por defecto 0.3) | `500` con esa probabilidad | middleware |
| `malformed` | `CHAOS=malformed`, `CHAOS_RATE` | `200` con un cuerpo que no cumple el tipo | middleware |
| `cors` | `CHAOS=cors` | Omite `Access-Control-Allow-Origin` | middleware |
| `timeout` | `CHAOS=timeout`, `CHAOS_RATE` | No responde nunca | middleware |
| `expired` | `CHAOS=expired` | **Firma un token que ya nació vencido** (`ttl = -60`) | **`auth.js`, no el middleware** |

Y las dos reglas del inyector, que son contrato tanto como los endpoints:

- **El caos no toca `/auth/login`, salvo `expired`.** Si no puedes entrar, no puedes diagnosticar nada.
- **Un modo desconocido hace fallar el arranque**, no se ignora. `CHAOS=latencia` —en español, mal escrito— tiene que matar el proceso con un mensaje que nombre los seis válidos. Un inyector de caos que se encoge de hombros es peor que no tenerlo, porque te deja creyendo que estás probando algo.

### 5.5 `smoke.sh` — el juez de todas las fases

Este archivo es el entregable que más veces vas a ejecutar en todo el track. Corre contra el mock hoy, y contra el backend en PHP a partir de be03, **sin cambiar una línea**. El día que las dos salidas sean idénticas, be03 terminó.

```bash
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
         # ejecutar las 24 comprobaciones aunque una falle.

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

# La ruta anidada que nadie diseñó y que la Fase 9 consume.
check "la ruta anidada de hallazgos existe" "array" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/inspections/503/findings" | jq -r 'type')"
check "y devuelve sólo los de esa inspección" "true" \
  "$(curl -s "${AUTH[@]}" "$BASE_URL/inspections/503/findings" \
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
```

**Detalles con intención**
- **`set -u` sí, `set -e` no.** Con `-e`, la primera comprobación en rojo aborta el archivo y pierdes las veintitrés restantes. Un juez de contrato tiene que dar el informe completo: en be03 vas a querer ver las once que fallan a la vez, no la primera once veces.
- **Sólo `curl` y `jq`.** El juez no puede depender de Node —que es el lado que va a desaparecer— ni de PHP —que es el que va a llegar—. Un árbitro que se va con uno de los dos equipos no es un árbitro.
- **Cada comprobación nombra a quién protege.** `PATCH devuelve el objeto completo` lleva escrito que el autosave de la Fase 8 se apoya en eso. Dentro de tres fases, el comentario es la diferencia entre arreglar la causa y "ajustar el test".
- **`jq -r 'type'` en vez de mirar el cuerpo.** Compara la **forma**, que es lo que el frontend consume, y no el contenido, que cambia en cuanto el alumno cree un cliente. Un `smoke.sh` que se rompe porque hiciste tu trabajo es un `smoke.sh` que vas a comentar.

**El patrón a memorizar**
> **Un contrato que no se puede ejecutar es una opinión.** La ficha de `CONTRACT.md` explica *por qué*; `smoke.sh` decide *si*. Hacen falta los dos, y el que manda cuando discrepan es el que se ejecuta.

**Prueba de fuego**

Con el mock limpio, `./smoke.sh` tiene que imprimir `OK: 24/24`. Ahora rompe el contrato a mano:

```bash
# Cambia el id compuesto de la v2 por un entero, como haría cualquier ORM
# que no supiera de esta rareza.
sed -i '' 's/"elevator-annual-v2"/"7"/' mock/db.json
./smoke.sh          # → FALLOS: 2 de 24
npm run seed        # y lo devuelves
```

**Dos** fallos, no uno: el `id` y el filtro `?templateId=&version=`, porque la fila dejó de encontrarse por su clave. Ésa es exactamente la cascada que vas a ver en be03 el día que las migraciones generen claves primarias enteras, y verla hoy —cuando todavía es un `sed`— es la mitad de esta fase.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Documentar el servidor en vez del contrato.**
*Síntoma:* tu `CONTRACT.md` tiene fichas de `_sort`, `_embed` y `q`, y ocupa treinta páginas.
*Causa:* abriste `mock/server.js` en vez de Network. Documentaste lo que json-server sabe hacer, no lo que CertCore le pide.
*Fix mínimo:* borra toda ficha que no tenga un "quién lo llama" con nombre y apellido de un servicio real. Si no puedes nombrar el archivo del frontend que la ejerce, no es contrato: es capacidad del servidor, y muere con él.

**Leer el cuerpo desde Preview.**
*Síntoma:* documentas `version: 2` y en be03 el frontend recibe `"2"` y `resolveTemplateVersion` deja de encontrar nada.
*Causa:* la pestaña Preview de DevTools **te pinta el JSON ya interpretado** y no distingue `2` de `"2"`. La pestaña Response te da el texto crudo.
*Fix mínimo:* recaptura desde Response. Y mete el tipo en el `smoke.sh` con `jq -r '.version | type'`, que es la única forma de que no vuelva a pasar.

**Dar por hecho el orden.**
*Síntoma:* en be03 la pantalla de plantillas muestra la v2 arriba y antes mostraba la v1, y nadie tocó la pantalla.
*Causa:* json-server devuelve el orden de inserción del `db.json` y el frontend no ordena. Un `SELECT` sin `ORDER BY` no garantiza nada, y PostgreSQL te lo va a demostrar en cuanto la tabla tenga actualizaciones.
*Fix mínimo:* anótalo como trampa hoy. El arreglo de verdad —`ORDER BY` explícito en be03— no es de esta fase, pero la nota sí.

### Pieza forense de esta fase

**Dos peticiones que juras que son iguales.**

En el recorrido de plantillas salen estas dos, con dos segundos de diferencia:

```
GET /templates?templateId=elevator-annual&version=1
GET /templates?version=1&templateId=elevator-annual
```

Son la misma petición: json-server evalúa los parámetros como un AND sin importar el orden, y las dos devuelven la v1. **Y aun así hay que anotar las dos**, porque el día que be03 las sirva con un `WHERE` construido concatenando en el orden de llegada, una de las dos va a ser distinta y el ticket va a decir *"a veces la plantilla sale mal"*.

La ruta es corta y son tres pasos:

1. **¿Difieren en el cuerpo?** `diff <(curl -s "…&version=1") <(curl -s "…version=1&…")`. Si el diff está vacío, no es el cuerpo.
2. **¿Difieren en las cabeceras?** `curl -sD - -o /dev/null`. Compara `Content-Length` y `ETag`. **Aquí sí hay señal**: json-server calcula el `ETag` sobre el cuerpo, así que dos cuerpos idénticos dan el mismo `ETag` — y si no lo dan, los cuerpos no eran idénticos aunque el `diff` dijera que sí (espacios, orden de claves).
3. **¿Difieren en lo que el cliente mandó?** *Copy as cURL* de las dos y diff de los comandos. Ahí aparece lo que Network no te enseña de un vistazo: una lleva `Cache-Control: no-cache` porque venía de una recarga forzada.

**Aquí termina la ruta.** No hay bug: hay dos peticiones equivalentes hoy que **no está garantizado que lo sigan siendo**, y eso se anota en Trampas.

> 🧨 **Rompe a propósito y observa.** Arranca con `CHAOS=malformed CHAOS_RATE=1 npm run mock` y corre `./smoke.sh`. Anota cuántas comprobaciones caen y **cuáles**. Después hazlo con `CHAOS=cors`. La lección está en la diferencia: `malformed` tumba las de forma y deja pasar las de estado; `cors` **no tumba ninguna**, porque `curl` no aplica la política del mismo origen. Un juez de contrato que corre fuera del navegador es ciego a una familia entera de fallos, y eso hay que saberlo antes de confiar en él.

---

## 🧪 7. Ejercicios (26)

**🟢 Fácil (1–7)**

1. Corre `npm run seed && npm run mock` y después `./smoke.sh`. Copia la salida entera en `CONTRACT.md`, en una sección "Línea base", con la fecha. Es la foto contra la que vas a comparar durante siete fases.
2. Escribe la ficha completa de `GET /clients` siguiendo el formato de §5.2, con sus cuatro apartados. Criterio: un compañero que no haya visto el mock tiene que poder implementar ese endpoint leyendo sólo la ficha.
3. **Diagnóstico.** Entra a la aplicación y cuenta cuántas peticiones salen al abrir el panel principal. Anota el número exacto y cuáles se repiten. ¿Cuántas serían con dos mil inspecciones?
4. Captura `POST /auth/login` con credenciales buenas y con malas. Documenta los dos cuerpos de respuesta **literalmente**, incluidos los mensajes en español.
5. Decodifica el `accessToken` en [jwt.io](https://jwt.io) y anota los cinco claims. ¿Cuál usa el frontend y dónde?
6. Añade al `smoke.sh` una comprobación de que `GET /assets` devuelve activos con `clientId` no nulo. Que pase, y que falle si lo rompes a mano.
7. Lista los seis modos de caos y, para cada uno, escribe en una línea **qué pantalla del track base lo usaba** en sus ejercicios.

**🟡 Intermedio (8–16)**

8. **Diagnóstico.** Con `CHAOS=latency CHAOS_DELAY_MS=8000`, corre `./smoke.sh` y mide cuánto tarda. Después añade `--max-time 3` a los `curl`. ¿Qué cambia en el informe, y qué decisión de diseño te obliga a tomar eso para be03?
9. Documenta la ruta anidada `GET /inspections/:id/findings`: quién la llama, qué devuelve, y **por qué existe** aunque nadie la escribiera. Busca en `mock/server.js` la línea que la genera.
10. **Diagnóstico.** Pide `GET /templates?version=1` sin `templateId`. ¿Cuántas filas devuelve y por qué? ¿Qué pasaría si el frontend hiciera esa llamada?
11. Compara `GET /inspections` con `GET /inspections/500`. ¿La inspección viene igual en los dos? Documenta cualquier diferencia; si no la hay, escribe que no la hay — eso también es contrato.
12. Escribe la tabla de §5.3 con tus propias mediciones, marcando cada fila como "usado" o "no usado" **con la evidencia**: el archivo del frontend y la línea.
13. **Diagnóstico.** Manda `PATCH /inspections/500` con un campo que no existe (`{"colorFavorito":"azul"}`). ¿Qué responde? ¿Qué implica eso para el régimen de crecimiento?
14. Añade tres comprobaciones al `smoke.sh` sobre `/findings`: que es un array, que cada elemento tiene `inspectionId`, y que `resolvedAt` es `string` o `null` **pero nunca falta**. La tercera es la que importa: explica por qué en el bloque de 📌.
15. **Diagnóstico.** Con `CHAOS=error CHAOS_RATE=1`, corre `./smoke.sh` tres veces. ¿Da el mismo resultado siempre? ¿Debería?
16. Escribe en `CONTRACT.md` la sección "Régimen estricto y régimen de crecimiento" aplicada a `/certificates`: qué campo no se puede tocar nunca, cuál se podría añadir, y cuál **se podría dejar de enviar** sin que nadie se entere.

**🟠 Difícil (17–22)**

17. **Diagnóstico.** Rompe el contrato de tres formas distintas editando `mock/db.json` a mano —una de tipo, una de forma, una de contenido— y anota cuántas comprobaciones del `smoke.sh` cae cada una. La conclusión que buscas: ¿cuál de las tres es la que menos ruido hace, y por qué es la más peligrosa?
18. El `smoke.sh` no comprueba nada sobre el **orden** de `/templates`. Escribe una comprobación que sí lo haga, y después argumenta en cinco líneas si debería estar ahí o no. Las dos respuestas son defendibles; lo que se evalúa es el argumento.
19. **Diagnóstico.** Levanta el mock, entra a la aplicación, y deja el panel abierto diez minutos con Network grabando. Calcula el tráfico total en KB y extrapola a cien usuarios. Anota el número en `CONTRACT.md`: es un insumo directo del *assessment* de be07.
20. Escribe la ficha de `POST /templates` incluyendo algo que las demás no tienen: **qué pasa si falla a mitad**. Publicar una versión son dos escrituras (nace la nueva, se cierra la anterior) y el mock no tiene transacciones. Documenta el estado intermedio posible.
21. **Diagnóstico.** El `expired` vive en `auth.js` y los otros cinco en el middleware. Explica qué habría que cambiar para moverlo al middleware, y por qué **no se hizo**. Pista: mira en qué momento se firma el token.
22. Toma las siete fichas y escribe, debajo de cada una, la línea *"si esto cambia, se rompe: …"* nombrando el archivo y el componente del frontend. Las siete líneas juntas son el mapa de impacto de be03.

**🔴 Muy difícil (23–26)**

23. **Diagnóstico.** Encuentra un campo del `db.json` que **ningún componente del frontend lee jamás**. Demuéstralo con `grep` sobre `src/`, no por inspección visual. ¿Qué régimen le corresponde? ¿Lo implementarías en be03?
24. Escribe un segundo guion, `contract-diff.sh`, que corra `smoke.sh` contra dos URLs base y muestre sólo las comprobaciones cuyo resultado difiere. Hoy no tiene contra qué compararse; desde be03 es la herramienta más útil del track.
25. **Diagnóstico adversarial.** Un compañero propone que el backend nuevo devuelva `{"data": [...], "total": 5}` en todas las colecciones, *"porque es lo estándar"*. Escribe la respuesta de dos párrafos: qué se rompe exactamente —nombra componentes—, cuánto costaría adaptarlo del lado del frontend, y por qué la regla del track lo prohíbe igual aunque costara poco.
26. Las tres rarezas de §4 se explican por la Era 0. Elige **una** y escribe la ficha de decisión que alguien tendría que haber escrito en 2016: qué se decidió, qué alternativa había, qué la habría hecho cambiar. Después responde lo difícil: **¿qué señal, en 2019, tendría que haber disparado su revisión?** Esa pregunta es el track entero.

**🔥 Opcionales**

- 🔥 Reescribe `smoke.sh` en PHP puro, sin dependencias, y compara las dos versiones en líneas y en legibilidad. Después decide cuál conservas y justifica — ojo con lo que dice §5.5 sobre árbitros.
- 🔥 Genera un OpenAPI 3.0 a partir de tus siete fichas y sírvelo con Swagger UI. Después contesta: ¿el documento describe el contrato, o ya describe lo que te gustaría que fuera el contrato?

---

## 📚 8. Referencias

**Documentación oficial**
- https://github.com/typicode/json-server/tree/v0.17.4 — el README de la versión exacta del curso. La rama `main` documenta json-server 1.x, que es **otro producto**: distinto dialecto de filtros y distinto comportamiento por defecto. Si acabas ahí, te va a mentir en todo lo que importa.
- https://curl.se/docs/manpage.html — la página de manual completa. Para esta fase interesan `-w`, `-D`, `-o` y `--max-time`.
- https://jqlang.github.io/jq/manual/ — `type`, `all`, `test` y `//` son los cuatro que usa el `smoke.sh`.
- https://developer.mozilla.org/es/docs/Web/HTTP/Methods/PATCH — la semántica de `PATCH`, y por qué devolver el objeto completo es una decisión y no una obligación.

**Libros / artículos de referencia**
- *Building Microservices* (Sam Newman, 2.ª ed., O'Reilly, 2021), capítulo 5 — la distinción entre contrato explícito e implícito, y el coste de los implícitos. Es el marco conceptual de esta fase entera.

**Video / apoyo**
- https://www.youtube.com/results?search_query=consumer+driven+contract+testing — la familia de ideas a la que pertenece el `smoke.sh`. Busca charlas sobre *consumer-driven contracts*: lo que aquí se hace a mano es la versión artesanal de eso.

**Orden de lectura sugerido:** el README de json-server 0.17.4 **antes** de capturar nada, para reconocer qué parámetros existen → el manual de `jq` **durante**, como referencia → Newman capítulo 5 **después**, cuando ya tengas las siete fichas y la distinción te resuene.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y con json-server en particular, **comprueba siempre la versión que estás leyendo**: la diferencia entre 0.17 y 1.x no es cosmética, y la mitad de las respuestas que encuentres en foros se refieren a una de las dos sin decir cuál.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminaste con dos archivos y ninguna línea de PHP, y ése era el trato. `CONTRACT.md` explica el porqué de cada campo; `smoke.sh` decide si un servidor cumple. Entre los dos definen, en el único sentido que importa, **qué significa que el backend nuevo funcione**: no que esté bien escrito, no que sea rápido, no que use el framework de moda — que `./smoke.sh` diga `OK: 24/24` y que la aplicación Angular no se entere de nada.

**be01** es el paso natural porque ahora tienes contra qué escribir. Vas a levantar el monolito de 2016 —Lumen sobre PHP 7.4, con Composer y el contenedor congelado— y a descubrir, en carne propia, que la parte difícil no es PHP: es que **Lumen se parece a Laravel lo bastante como para que todo lo que sabes de Laravel te lleve al sitio equivocado con total confianza**. Ahí empieza la factura de verdad.

> **La señal de que quedó bien:** *"rompí un campo del `db.json` a propósito, el `smoke.sh` me dijo exactamente qué se había roto y a quién le importaba, y no tuve que abrir el navegador."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-00-el-contrato-auditoria-del-mock \
>   -m "be00 cerrada: CONTRACT.md con siete fichas; smoke.sh en OK: 24/24;
> dialecto de json-server medido; seis modos de caos inventariados;
> las tres rarezas de la Era 0 explicadas"
> ```
>
> Los commits de esta fase llevan `be00: …` y los de ejercicio `be00 ej17: …`. El namespace `be-fase-*` es propio del track **para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base**; todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.
>
> Y esta fase estrena algo que va a valer en las siete siguientes: `git show be-fase-00-…:smoke.sh` te devuelve el juez tal como era el día que lo escribiste, antes de que ninguna fase tuviera la tentación de ajustarlo para aprobar.

---

## 📌 Pendientes sugeridos

- **El `smoke.sh` no comprueba nada sobre CORS, y no puede.** `curl` no aplica la política del mismo origen, así que el modo `cors` del caos le es invisible (ejercicio 🧨 de §6). La comprobación real necesitaría un navegador sin cabeza, que es una dependencia que este track no quiere. → **Declarado como límite conocido en `CONTRACT.md`**; si alguna vez entra, es un 🔥 de be06 junto con las pruebas.
- **`POST /templates` y la ausencia de transacciones** (ejercicio 20) apareció al escribir las fichas y no cabe en esta fase: publicar una versión son dos escrituras y el mock no puede hacerlas atómicas. Es el mismo agujero que el incidente 09 del cuaderno base declaró sin poder cerrar. → **be05**, que es donde la invariante de plantillas se mira de frente.
- **El tráfico medido del panel** (ejercicio 19) es el único número duro que esta fase produce y el *assessment* de be07 lo va a necesitar. Conviene que quede en `CONTRACT.md` y no sólo en la libreta del alumno. → **Insumo de be07**, anotado también en `bea-10`.
- **La versión exacta de Lumen sigue sin fijar** (§5.5 de la propuesta, ⚠️ 1). No bloqueó esta fase, como estaba previsto, pero **bloquea be01**: decide el ticket que abre el track. → **Cerrar antes del chat de be01**, verificándolo contra Packagist y el changelog, nunca de memoria.

### Reservas para el cuaderno de incidentes

Esta fase **no reserva ningún ID**, y es deliberado: un incidente necesita un sistema que se pueda romper, y aquí todavía no hay sistema propio — sólo un mock que el track base ya rompió doce veces. Los doce incidentes del track BE empiezan en be01.

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| — | Sin reservas: esta fase audita, no construye | — | — |
