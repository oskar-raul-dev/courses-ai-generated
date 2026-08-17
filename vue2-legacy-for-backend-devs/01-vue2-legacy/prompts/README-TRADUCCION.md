# 🌍 Traducción de Código a Inglés — Curso Vue 2 Legacy
## Resumen Ejecutivo e Índice

---

## 📌 ¿De Qué Va?

Traducir **TODO el código fuente, endpoints y constantes** de español a inglés en los 30 archivos del curso Vue 2 Legacy, manteniendo:
- ✅ **Comentarios en español**
- ✅ **Narrativa del curso en español**
- ✅ **Estructura y filosofía intactas**
- ✅ **Coherencia entre fases y frameworks**

**Scope:** 30 archivos, ~1.5 MB, ~600 bloques de código

---

## 🎯 Qué Cambia (Ejemplos Concretos)

### ❌ Antes
```js
function obtenerTickets(params) {
  return apiClient.get("/usuarios", ...)
}

data() {
  return { 
    usuarios: [], 
    cargando: false,
    formulario: { titulo: "", descripción: "" }
  }
}
```

### ✅ Después
```js
function getTickets(params) {
  return apiClient.get("/users", ...)
}

data() {
  return { 
    users: [], 
    loading: false,
    form: { title: "", description: "" }
  }
}
```

### ✅ Permanece igual (Comentarios)
```js
// Obtener lista de tickets del servidor
// Validar que el usuario esté autenticado
// Actualizar el estado local después de crear el ticket
```

### ✅ Permanece igual (Narrativa)
```
## 🎯 Propósito

Crear tickets de soporte con validación completa y...
Este es un CRUD funcional que sigue el patrón...
```

---

## 📚 Los 3 Documentos (En Orden de Uso)

### 1️⃣ **PROMPT-TRADUCCION-ENDPOINTS-INGLÉS.md** (Autoridad)
📄 **Uso:** Referencia oficial, decisiones finales  
⏱️ **Tiempo de lectura:** 30–40 minutos (primera vez)  
🎯 **Contiene:**
- Diccionario completo y jerarquizado (endpoints, funciones, variables, props, eventos, rutas)
- Patrones de búsqueda/reemplazo por tipo de elemento
- Ejemplos antes/después detallados
- Checklist final por archivo
- Reglas de coherencia entre fases

**↳ Úsalo cuando:**
- Necesites resolver una duda sobre qué traducir
- Verificar que un cambio sea correcto antes de aplicarlo
- Entender la jerarquía de decisiones

---

### 2️⃣ **DICCIONARIO-RAPIDO.md** (Operativo)
📄 **Uso:** Llevar a mano mientras trabajas  
⏱️ **Tiempo de referencia:** 1–2 segundos por búsqueda  
🎯 **Contiene:**
- Tabla de buscar/reemplazar rápida (copy-paste)
- Secciones por tipo: funciones, endpoints, variables, props, eventos, etc.
- Patrones mnemotécnicos
- Casos especiales (¿traducir o no?)

**↳ Úsalo cuando:**
- Estés traduciendo un archivo
- Necesites verificar rápidamente el equivalente en inglés
- Tengas una palabra y necesites ver dónde más aparece

---

### 3️⃣ **GUIA-EJECUCION-TRADUCCION.md** (Implementación)
📄 **Uso:** Plan de trabajo día a día  
⏱️ **Tiempo de comprensión:** 20–30 minutos  
🎯 **Contiene:**
- Orden de traducción (qué archivos traducir primero)
- Dependencias entre archivos (por qué ese orden)
- Plan semanal (cuántas horas/día)
- Template de trabajo para cada archivo
- Script de validación (bash)
- Matriz de verificación
- Checklist pre-commit

**↳ Úsalo cuando:**
- Empieces un archivo nuevo
- Necesites validar lo que hiciste
- Quieras saber si un cambio puede romper otra fase

---

## 🚀 Flujo de Trabajo (El Ciclo)

```
1. LEE el archivo actual en el proyecto
   ↓
2. ABRE DICCIONARIO-RAPIDO.md en otra ventana
   ↓
3. TRADUCE usando búsqueda/reemplazo o a mano
   - Función obtener* → get*
   - Variable usuarios → users
   - Endpoint /usuarios → /users
   - Prop :usuarioActual → :currentUser
   - Evento @enviar → @submit
   - Ruta /tickets/nuevo → /tickets/new
   ↓
4. VERIFICA con template de GUIA-EJECUCION-TRADUCCION.md
   - ¿Sin funciones en español?
   - ¿Sin variables en español?
   - ¿Comentarios intactos?
   - ¿Narrativa intacta?
   ↓
5. DUDA? Consulta PROMPT-TRADUCCION-ENDPOINTS-INGLÉS.md
   ↓
6. COMMIT
   - git add archivo.md
   - git commit -m "refactor: translate code to English (phase X)"
```

---

## 📊 Estructura del Proyecto (30 Archivos)

```
TRONCO (12 fases + 3 meta-documentos)
├── 00-setup-hola-mundo.md                    👈 Fase 0
├── 01-estructura-base-legacy.md              👈 Fase 1
├── 02-autenticacion-minima.md                👈 Fase 2
├── 03-mock-api-minima.md                     👈 Fase 3
├── 04-dashboard-tickets.md                   👈 Fase 4
├── 05-crud-tickets.md                        👈 Fase 5
├── 06-wizard-minimo.md                       👈 Fase 6
├── 07-metricas-minimas.md                    👈 Fase 7
├── 08-websockets-minimos.md                  👈 Fase 8
├── 09-panel-soporte.md                       👈 Fase 9
├── 10-vuex-a-fondo.md                        👈 Fase 10
├── 11-testing-minimo.md                      👈 Fase 11
├── README.md                                 👈 Meta
├── 0-plan-del-curso.md                       👈 Meta
└── 0-ESTRUCTURA-CURSO.md                     👈 Meta

APÉNDICES (5 archivos)
├── A1-bootstrap.md
├── A2-node.md
├── A3-npm.md
├── A4-axios.md
└── A5-webpack-babel.md

FRAMEWORKS (15 archivos)
├── Q0-red-de-seguridad.md
├── Q1-leer-quasar.md
├── Q2-migrar-crud-qform.md
├── Q3-migrar-dashboard-qtable.md
├── Q4-timeline-actividad.md
├── VU0-red-de-seguridad.md
├── VU1-leer-vuetify.md
├── VU2-migrar-crud-vuetify.md
├── VU3-migrar-dashboard-vdatatable.md
├── VU4-timeline-vuetify.md
├── NX0-red-de-seguridad.md
├── NX1-leer-nuxt.md
├── NX2-hidratacion-window-not-defined.md
├── NX3-asyncdata-vs-vuex.md
└── NX4-pagina-ssr-nueva.md

TOTAL: 30 archivos
```

---

## 🎯 Orden Recomendado (Crítico)

```
SEMANA 1–2: BASE + SERVICIOS
├── Fase 0–1      (00, 01) → define convención
├── Fase 2–3      (02, 03) → endpoints y servicios
├── Fase 4–6      (04, 05, 06) → vistas y componentes
└── Validar coherencia entre 0–6

SEMANA 3: FEATURES AVANZADAS
├── Fase 7–11     (07, 08, 09, 10, 11) → reutilizan tronco
└── Script validación en todo

SEMANA 4: APÉNDICES + META
├── Apéndices     (A1–A5) → referencias técnicas
├── Meta-docs     (README, plan, estructura)
└── QA final

SEMANA 5: FRAMEWORKS (paralelo)
├── Quasar        (Q0–Q4) → reutiliza tronco
├── Vuetify       (VU0–VU4) → reutiliza tronco
├── NuxtJS        (NX0–NX4) → reutiliza tronco
└── Script validación por framework
```

**Total estimado:** 2–3 semanas (40–60 horas)

---

## ✅ Checklist Pre-Inicio

Antes de empezar a traducir:

- [ ] Leo **PROMPT-TRADUCCION-ENDPOINTS-INGLÉS.md** (entiendo el diccionario)
- [ ] Leo **GUIA-EJECUCION-TRADUCCION.md** (entiendo el orden)
- [ ] Descargo o guardo **DICCIONARIO-RAPIDO.md** (para llevar a mano)
- [ ] Confirmo que van a traducir Fase 0–1 primero (establece convención)
- [ ] Confirmo que van a traducir en el orden propuesto (evita inconsistencias)
- [ ] Preparo editor de texto o IDE con search-replace (para acelerar)
- [ ] Preparo bash/script para validación final

**Listo → empezar con `00-setup-hola-mundo.md`**

---

## 🆘 Troubleshooting Rápido

| Problema | Solución | Dónde buscar |
|----------|----------|--------------|
| "¿Traduzco X?" | Busca en DICCIONARIO-RAPIDO.md | Sección correspondiente |
| "¿Ya traduje esto?" | Busca en GUIA-EJECUCION-TRADUCCION.md > Matriz | Matriz de verificación |
| "Cambié un nombre, ¿qué más?" | Usa grep para encontrar referencias | GUIA-EJECUCION > Troubleshooting |
| "Esto no anda después de traducir" | Valida con script de bash | GUIA-EJECUCION > Script de validación |
| "¿Conflicto entre dos fases?" | Consulta PROMPT-TRADUCCION > Checklist Final | Sección de coherencia |

---

## 📖 Lectura Recomendada

**Si tienes poco tiempo:**
1. Este README (5 min)
2. DICCIONARIO-RAPIDO.md > Tabla (3 min)
3. Empieza a traducir Fase 0

**Si tienes tiempo normal:**
1. Este README (5 min)
2. PROMPT-TRADUCCION-ENDPOINTS-INGLÉS.md (30 min) — entiende la lógica
3. GUIA-EJECUCION-TRADUCCION.md (20 min) — entiende el plan
4. DICCIONARIO-RAPIDO.md (referencia mientras trabajas)
5. Empieza a traducir Fase 0

**Si eres obsesivo-compulsivo (la mejor opción):**
1. PROMPT-TRADUCCION-ENDPOINTS-INGLÉS.md (40 min) — autoridad total
2. GUIA-EJECUCION-TRADUCCION.md (30 min) — plan de batalla
3. DICCIONARIO-RAPIDO.md (aprender de memoria)
4. Empieza a traducir Fase 0
5. Reivindica a PROMPT-TRADUCCION cuando haya dudas

---

## 🎬 Empezar Ahora

### Opción A: Traducción Manual (Diligente)
```bash
1. Abre 00-setup-hola-mundo.md
2. Mantén DICCIONARIO-RAPIDO.md en otra ventana
3. Reemplaza línea por línea
4. Verificar con template de GUIA-EJECUCION
5. Commit
```

### Opción B: Buscar/Reemplazar (Rápido)
```bash
# Usar el editor con regex
# Search: function obtener
# Replace: function get

# Search: const usuarios
# Replace: const users

# Search: "/usuarios"
# Replace: "/users"

# ... repetir para cada patrón del DICCIONARIO-RAPIDO
```

### Opción C: Script (Automatizado)
```bash
# (Ejercicio: escribir script Node/Python que use DICCIONARIO-RAPIDO
#  como JSON y reemplace automáticamente)
```

---

## 📋 Salida Esperada

**Después de terminar:**

```
✅ 30 archivos traducidos
├─ Código 100% inglés
├─ Comentarios 100% español
├─ Narrativa 100% español
├─ Sin conflictos entre fases
├─ Sin falsos positivos (variables nativos JS intactos)
└─ Listo para producción / publicación

✅ Validación completada
├─ Script de bash sin errores
├─ Matriz de verificación 100% ✅
└─ Commit message limpio
```

---

## 🔗 Quick Links

| Documento | Tamaño | Propósito |
|-----------|--------|----------|
| [PROMPT-TRADUCCION-ENDPOINTS-INGLÉS.md](./PROMPT-TRADUCCION-ENDPOINTS-INGLÉS.md) | ~50 KB | Autoridad, decisiones finales |
| [DICCIONARIO-RAPIDO.md](./DICCIONARIO-RAPIDO.md) | ~30 KB | Referencia operativa (llevar a mano) |
| [GUIA-EJECUCION-TRADUCCION.md](./GUIA-EJECUCION-TRADUCCION.md) | ~40 KB | Plan de trabajo, dependencias, validación |
| [README-TRADUCCION.md](./README-TRADUCCION.md) | ~15 KB | Este documento (índice y resumen) |

---

## 🎯 Última Cosa

**Esta es una tarea de REFACTORING editorial, no de reescritura.**

- El curso no cambia de filosofía ✅
- La pedagogía es idéntica ✅
- Solo el código es inglés ✅
- Los comentarios siguen siendo la antorcha que ilumina el aprendizaje ✅

**Objetivo final:** Un curso Vue 2 Legacy en español, con código profesional en inglés, listo para un team internacional.

---

**¡Adelante! Empezá con Fase 0. 🚀**
