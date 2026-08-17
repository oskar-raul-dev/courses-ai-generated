# 🔧 Guía de Ejecución: Traducción de Código a Inglés
## Paso a Paso, Archivo por Archivo

---

## 📋 Template de Trabajo (Copiar para cada archivo)

```markdown
## 📄 [NOMBRE ARCHIVO]

### 🔎 Paso 1: Identificar bloques de código
- [ ] Contar cuántos bloques ` ```js ` hay
- [ ] Contar cuántos bloques ` ```vue ` hay  
- [ ] Contar cuántos bloques ` ```json ` hay
- [ ] Total bloques: ___

### ✏️ Paso 2: Traducir (usar diccionario PROMPT-TRADUCCION)
- [ ] Variables y data properties
- [ ] Funciones y métodos
- [ ] Endpoints y rutas
- [ ] Props y eventos
- [ ] Estados/enums
- [ ] Acciones de Vuex

### 🔍 Paso 3: Validar (linea por linea)
- [ ] No hay funciones `obtener*` en código
- [ ] No hay variables `usuario*` sin traducir
- [ ] No hay endpoints `/usuarios`, `/agentes`, `/comentarios`
- [ ] Comentarios siguen en español ✅
- [ ] Narrativa intacta ✅

### ✅ Paso 4: Checklist Final
- [ ] Código compila (sin errores de sintaxis)
- [ ] Nombres consistentes con otros archivos
- [ ] No hay strings de estado en español en código (enums = inglés)
- [ ] Links internos ajustados si cambió nombre de ruta
- [ ] Listo para commit
```

---

## 📂 Lista de Archivos + Dependencias

### Grupo 1: BASE (sin dependencias)
```
00-setup-hola-mundo.md
  ├─ 1 función demo
  ├─ 2 endpoints mock
  └─ 0 servicios propios
  
01-estructura-base-legacy.md
  ├─ 3 componentes básicos
  ├─ Store básico
  └─ 0 servicios
```

**Traducir primero estos dos.** Definen la convención.

---

### Grupo 2: FUNCIONALIDAD CORE (dependen de Grupo 1)
```
02-autenticacion-minima.md
  ├─ authService.js (función: login, logout)
  ├─ endpoints: /login (mock)
  ├─ variables: token, currentUser, session
  ├─ rutas: /login
  └─ store/modules/auth.js

03-mock-api-minima.md
  ├─ ticketService.js (getTickets, getTicketById, createTicket, updateTicket, deleteTicket)
  ├─ endpoints: /tickets, /comments (mock)
  ├─ variables: tickets, comments, loading, error
  └─ store/modules/tickets.js

Dependen de: 01, 02
```

**Traducir en este orden.** Los servicios definen convenciones de métodos.

---

### Grupo 3: VISTAS Y UI (dependen de Grupo 2)
```
04-dashboard-tickets.md
  ├─ TicketList, DataTable (componentes)
  ├─ TicketDashboardView (vista)
  ├─ props: :tickets, :loading, :filters
  ├─ eventos: @filter, @sort, @paginate
  └─ variables: filters, sorting, pagination

05-crud-tickets.md
  ├─ TicketForm (componente)
  ├─ TicketCreateView, TicketEditView (vistas)
  ├─ props: :initialTicket, :saving
  ├─ eventos: @submit, @cancel, @delete
  ├─ rutas: /tickets/new, /tickets/:id/edit
  └─ variables: form, validating, saving

06-wizard-minimo.md
  ├─ TicketWizard (componente)
  ├─ TicketWizardView (vista)
  ├─ variables: currentStep, formData, wizardSteps
  ├─ métodos: nextStep, previousStep, submitWizard
  └─ rutas: /tickets/wizard (if exists)

Dependen de: 02, 03
```

**Traducir en este orden.** Reutilizan servicios de Grupo 2.

---

### Grupo 4: FEATURES AVANZADAS (dependen de Grupo 3)
```
07-metricas-minimas.md
  ├─ metricService.js (getMetrics)
  ├─ endpoints: /metrics (mock)
  ├─ variables: metrics, chartData
  └─ store/modules/metrics.js

08-websockets-minimos.md
  ├─ notificationService.js (connectWebSocket, disconnectWebSocket)
  ├─ endpoints: ws://localhost:3001
  ├─ variables: notifications, isConnected
  └─ listeners: message, close

09-panel-soporte.md
  ├─ agentService.js (getAgents, getTicketsForAgent)
  ├─ endpoints: /agents, /support-queue
  ├─ variables: agents, assignedTickets, currentQueue
  └─ store/modules/agents.js

10-vuex-a-fondo.md
  ├─ acciones: loadTickets, createTicket, updateTicket, deleteTicket
  ├─ mutaciones: SET_TICKETS, ADD_TICKET, UPDATE_TICKET
  ├─ getters: getTicketById, getOpenTickets, getTicketsByStatus
  └─ referencias a todas las fases anteriores

11-testing-minimo.md
  ├─ test files (*.spec.js)
  ├─ test methods: describe, it, expect
  ├─ referencias a funciones de fases 1–10
  └─ ejemplos de testing services y components

Dependen de: 02, 03, 04, 05
```

**Traducir en orden.** Cada uno reutiliza lo anterior.

---

### Grupo 5: APÉNDICES (Referencias, no scripts)
```
A1-bootstrap.md         → clases CSS (no traducir), componentes (inglés si son propios)
A2-node.md              → comandos npm (no traducir)
A3-npm.md               → comandos npm (no traducir)
A4-axios.md             → métodos de axios (no traducir), ejemplos propios (inglés)
A5-webpack-babel.md     → config files (no traducir)
```

**Traducir solo código de ejemplo** (rest in peace, español).

---

### Grupo 6: DOCUMENTACIÓN META
```
README.md               → pocos bloques de código
0-plan-del-curso.md     → algunos ejemplos de JSON (endpoints = inglés)
0-ESTRUCTURA-CURSO.md   → referencias de rutas (=/tickets/new)
```

**Traducir después de Grupo 4.** Dependen de todo.

---

### Grupo 7: FRAMEWORKS (CADA UNO = tronco traducido)

#### Quasar
```
Q0-red-de-seguridad.md
  ├─ reutiliza servicios (tronco)
  ├─ reutiliza store (tronco)
  └─ solo cambia: componentes, props

Q1-leer-quasar.md       → referencia de QTable, QForm
Q2-migrar-crud-qform.md → reutiliza form component pero con QForm
Q3-migrar-dashboard-qtable.md → reutiliza list pero con QTable
Q4-timeline-actividad.md → nuevos componentes Quasar
```

Dependen de: todo el tronco traducido.

#### Vuetify
```
VU0-red-de-seguridad.md
VU1-leer-vuetify.md
VU2-migrar-crud-vuetify.md
VU3-migrar-dashboard-vdatatable.md
VU4-timeline-vuetify.md
```

Dependen de: todo el tronco traducido.

#### NuxtJS
```
NX0-red-de-seguridad.md
NX1-leer-nuxt.md
NX2-hidratacion-window-not-defined.md
NX3-asyncdata-vs-vuex.md
NX4-pagina-ssr-nueva.md
```

Dependen de: todo el tronco traducido.

---

## 🚀 Plan de Trabajo Diario

### Día 1: Base (2–3 horas)
1. [ ] Traducir `00-setup-hola-mundo.md`
2. [ ] Traducir `01-estructura-base-legacy.md`
3. [ ] Validar coherencia entre 00 y 01

### Día 2–3: Servicios (3–4 horas/día)
1. [ ] Traducir `02-autenticacion-minima.md`
2. [ ] Traducir `03-mock-api-minima.md`
3. [ ] Validar que servicios tengan nombres consistentes
4. [ ] Validar que endpoints sean el mismo en ambos

### Día 4–5: Vistas (3–4 horas/día)
1. [ ] Traducir `04-dashboard-tickets.md`
2. [ ] Traducir `05-crud-tickets.md`
3. [ ] Traducir `06-wizard-minimo.md`
4. [ ] Validar que props y eventos sean consistentes

### Día 6–7: Features (3–4 horas/día)
1. [ ] Traducir `07-metricas-minimas.md`
2. [ ] Traducir `08-websockets-minimos.md`
3. [ ] Traducir `09-panel-soporte.md`
4. [ ] Validar nuevos servicios

### Día 8–9: Vuex + Testing (3–4 horas/día)
1. [ ] Traducir `10-vuex-a-fondo.md`
2. [ ] Traducir `11-testing-minimo.md`
3. [ ] Validar acciones, mutaciones, getters
4. [ ] Validar que tests se refieran a funciones inglés

### Día 10–11: Apéndices (2–3 horas/día)
1. [ ] Traducir `A1-bootstrap.md`
2. [ ] Traducir `A2-node.md`, `A3-npm.md`, `A4-axios.md`, `A5-webpack-babel.md`
3. [ ] Traducir `README.md`, `0-plan-del-curso.md`, `0-ESTRUCTURA-CURSO.md`

### Día 12–14: Frameworks (2 horas/día, paralelo)
1. [ ] Quasar (Q0–Q4)
2. [ ] Vuetify (VU0–VU4)
3. [ ] NuxtJS (NX0–NX4)

---

## 🔍 Script de Validación (Bash)

Ejecutar después de cada grupo de traducción:

```bash
#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Validando Traducción ===${NC}\n"

# 1. Buscar funciones en español en bloques de código
echo -e "${YELLOW}[1] Buscando funciones en español...${NC}"
if grep -E '```(js|vue)' -A 100 *.md | grep -E 'function (obtener|crear|actualizar|eliminar|cargar|guardar|validar)' > /tmp/spanish_funcs.txt 2>&1; then
  echo -e "${RED}❌ Encontradas funciones en español:${NC}"
  cat /tmp/spanish_funcs.txt
else
  echo -e "${GREEN}✅ No hay funciones en español${NC}"
fi

# 2. Buscar variables comunes en español
echo -e "\n${YELLOW}[2] Buscando variables en español...${NC}"
if grep -E '```(js|vue)' -A 100 *.md | grep -E '(usuario|agente|comentario|cargando|guardando|formulario|estado|prioridad)' \
  | grep -v '// ' | grep -v '^.*es\.' > /tmp/spanish_vars.txt 2>&1; then
  echo -e "${YELLOW}⚠️  Revisar posibles variables en español:${NC}"
  cat /tmp/spanish_vars.txt | head -20
else
  echo -e "${GREEN}✅ No hay variables en español evidentes${NC}"
fi

# 3. Buscar endpoints en español
echo -e "\n${YELLOW}[3] Buscando endpoints en español...${NC}"
if grep -E '"/usuarios"|"/agentes"|"/comentarios"|"/métricas"|"/notificaciones"|"/buscar"' *.md > /tmp/spanish_endpoints.txt 2>&1; then
  echo -e "${RED}❌ Encontrados endpoints en español:${NC}"
  cat /tmp/spanish_endpoints.txt
else
  echo -e "${GREEN}✅ No hay endpoints en español${NC}"
fi

# 4. Verificar consistencia de nombres de función
echo -e "\n${YELLOW}[4] Verificando consistencia de getTickets...${NC}"
if grep -c 'getTickets' *.md > /tmp/get_tickets_count.txt; then
  COUNT=$(cat /tmp/get_tickets_count.txt | awk '{sum+=$NF} END {print sum}')
  echo -e "${GREEN}✅ getTickets aparece $COUNT veces${NC}"
fi

# 5. Buscar rutas sin traducir
echo -e "\n${YELLOW}[5] Buscando rutas sin traducir...${NC}"
if grep -E '/tickets/(nuevo|editar|crear)' *.md > /tmp/spanish_routes.txt 2>&1; then
  echo -e "${RED}❌ Encontradas rutas en español:${NC}"
  cat /tmp/spanish_routes.txt
else
  echo -e "${GREEN}✅ No hay rutas en español${NC}"
fi

# 6. Verificar comentarios están en español
echo -e "\n${YELLOW}[6] Verificando comentarios en español...${NC}"
if grep -E '```(js|vue)' -A 100 *.md | grep '// ' | grep -E '(obtener|crear|actualizar|eliminar)' | wc -l > /tmp/spanish_comments.txt; then
  COUNT=$(cat /tmp/spanish_comments.txt)
  if [ "$COUNT" -gt 5 ]; then
    echo -e "${GREEN}✅ Comentarios en español encontrados ($COUNT líneas)${NC}"
  fi
fi

echo -e "\n${YELLOW}=== Validación Completa ===${NC}"
```

**Uso:**
```bash
chmod +x validate_translation.sh
./validate_translation.sh
```

---

## 📊 Matriz de Verificación por Archivo

Copiar esta tabla y marcar ✅ mientras avanzas:

```markdown
| Archivo | Funciones | Variables | Endpoints | Props/Events | Rutas | Comentarios ✅ | Narrativa ✅ | Estado |
|---------|-----------|-----------|-----------|--------------|-------|----------------|-------------|--------|
| 00-setup-hola-mundo.md | ✅ | ✅ | ✅ | — | — | ✅ | ✅ | DONE |
| 01-estructura-base-legacy.md | ✅ | ✅ | — | ✅ | ✅ | ✅ | ✅ | DONE |
| 02-autenticacion-minima.md | — | — | — | — | — | — | — | TODO |
| ... | | | | | | | | |
```

---

## 🎯 Checklist Pre-Commit (cada archivo)

Antes de dar por finalizado un archivo:

### Código
- [ ] No hay `function obtener*`, `function crear*`, etc. (todas en inglés)
- [ ] No hay `var usuario`, `let comentario`, `const formulario` (todas en inglés)
- [ ] No hay endpoints con `/usuarios`, `/agentes`, `/comentarios`
- [ ] Todas las props empiezan con `:` y están en camelCase inglés
- [ ] Todos los eventos `@` están en camelCase inglés
- [ ] Todas las rutas están en inglés (`/tickets/new`, no `/tickets/nuevo`)
- [ ] Estados (status, priority) están en inglés en enums

### Consistencia
- [ ] Si el archivo 03 usa `getTickets()`, este archivo también usa `getTickets()`
- [ ] Si el archivo 02 usa `/login`, este archivo también usa `/login`
- [ ] Las acciones Vuex siguen el patrón `namespace/actionName` en inglés

### Integridad
- [ ] Comentarios en código 100% español ✅
- [ ] Narrativa (títulos, párrafos) 100% español ✅
- [ ] Sin cambios accidentales en explicaciones
- [ ] Links internos correctos (si cambió nombre de ruta)

### Validación Final
- [ ] Archivo compila (sin errores de sintaxis JavaScript)
- [ ] Bloques de código tienen cierre correcto (` ``` `)
- [ ] Markdown válido (linter pasaría)
- [ ] No quedan referencias `[TODO]` o `[REVISAR]`

---

## 📝 Template de Commit

```bash
git add 00-setup-hola-mundo.md 01-estructura-base-legacy.md
git commit -m "refactor: translate endpoints and code to English (phase 0–1)

- Rename functions: obtener* → get*, crear* → create*, etc.
- Rename variables: usuario* → user*, comentario* → comment*, etc.
- Rename endpoints: /usuarios → /users, /agentes → /agents
- Rename props: :ticketInicial → :initialTicket
- Rename events: @enviar → @submit, @cancelar → @cancel
- Rename routes: /tickets/nuevo → /tickets/new
- Rename components: TicketFormulario.vue → TicketForm.vue
- Keep comments in Spanish ✅
- Keep narrative in Spanish ✅
- Validate consistency with upcoming phases"
```

---

## 🆘 Troubleshooting

### Problema: "¿Traduzco X sí o no?"

| Cosa | ¿Traducir? | Razón |
|------|-----------|-------|
| `// Obtener lista de tickets` | ❌ NO | Comentario |
| `Obtener lista de tickets` (párrafo) | ❌ NO | Narrativa |
| `function obtenerTickets()` | ✅ SÍ | Código |
| `const tickets = []` | ✅ SÍ | Variable |
| `"/tickets"` | ✅ SÍ | Endpoint |
| `status: "abierto"` | ✅ SÍ | Valor de enum |
| `"Cargando tickets..."` | ❌ NO | String UI (muestra usuario) |
| `case "abierto": return "Abierto"` | ⚠️ PARCIAL | Traducir solo el case, no el return |
| `methods: { obtenerTickets() }` | ✅ SÍ | Método |
| `@click="obtenerTickets"` | ✅ SÍ | Referencia a método |

### Problema: "Cambié un nombre de ruta, ¿qué más cambia?"

Ejemplo: `/tickets/nuevo` → `/tickets/new`

Buscar y reemplazar en TODO el proyecto:
```bash
grep -r "/tickets/nuevo" .
# Cambiar en:
# - Router definition
# - router-link :to bindings
# - this.$router.push() calls
# - Tests (si existen)
# - Documentación (si menciona la ruta)
```

### Problema: "¿Puedo traducir un archivo parcialmente?"

**No.** Cada archivo debe estar 100% traducido. Si está incompleto, marcar como `[WIP]` en el nombre del commit.

---

## 🏁 Final Checklist

Después de traducir TODOS los 30 archivos:

- [ ] Ejecutar script de validación → sin errores
- [ ] Revisar matriz de verificación → todo ✅
- [ ] Buscar inconsistencias entre fases:
  - [ ] Si F3 define `getTickets()`, F4–F11 también usan `getTickets()`
  - [ ] Si F2 define ruta `/login`, no hay `/Login` en F3
  - [ ] Si F0 tiene `ticketService`, F1+ importan desde `ticketService`
- [ ] Revisar frameworks (Q/VU/NX) reutilizan nombres del tronco
- [ ] Validar documentación meta (README, plan) menciona cambios sin contradicciones
- [ ] Commit único grande (o series pequeñas, como prefieras)

---

**¡Listo para empezar!** 🚀
