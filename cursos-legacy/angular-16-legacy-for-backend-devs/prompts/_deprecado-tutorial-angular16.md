> 🪦 **DOCUMENTO DEPRECADO — no es fuente de verdad de nada.**
>
> Este fue el pistoletazo de salida del curso y cumplió su función. Lo sustituyen
> `alcance-del-proyecto.md` y `propuesta-fases-y-alcance.md`, que corrigen tres
> cosas de este texto:
>
> - **El presupuesto.** Aquí decía 96h y 12 fases (0-11). Son **122h**: 108h de
>   catorce fases (0-13) más 14h de cuaderno de incidentes, con una Fase 14
>   opcional 🔥 y sin horas.
> - **La ficción.** Aquí el sistema era el proxy de uno real bajo NDA. Ahora
>   **CertCore es ficticio y el curso lo construye entero**: si el material afirma
>   algo del sistema, tiene que poder mostrarlo.
> - **La numeración de apéndices.** Aquí iban de A1 a A8; los vigentes van de
>   **A01 a A13**.
>
> También quedaron cerradas las decisiones que la §10 dejaba abiertas: estado con
> servicios y `BehaviorSubject`, estilo mixto deliberado, `strict: true`, signals
> como pincelada, i18n fuera del cuerpo, y fase obligatoria de despliegue en
> contenedor.
>
> Se conserva por su modelo de datos, su tabla de criterios pedagógicos y los
> templates de kick off, que siguen siendo útiles como material de consulta.

---

# 🔍 Tutorial Angular 16 — Inspecciones y certificaciones

Documento base del **Track B**. Se lleva al proyecto de Claude que hospedará
el desarrollo del tutorial. Autocontenido: no requiere leer los otros dos
documentos.

---

## 🎯 1. Alcance del tutorial

### Perfil del sistema real que se hereda

- Sistema aeronáutico bajo NDA (no discutir el dominio real; se usa **Inspecciones y certificaciones** como proxy).
- Proyecto migrado a la **última estable de Angular 16 (16.2.12)**.
- Contiene **código legacy** de versiones anteriores (Angular 12-14) que sobrevivió a la migración: NgModules conviviendo con standalone, constructor conviviendo con `inject()`, componentes viejos que no se refactorizaron.
- Cambios normativos/legales son la fuente principal de tickets.
- **TypeScript strict activado** (TS-2).
- Angular Material moderno + mini design system.

### Perfil del estudiante

- Dev backend/full-stack senior en onboarding.
- Sabe HTML/CSS/JS básico. No necesita que le expliquen HTTP, JSON o tokens.
- Puede haber leído sobre Angular 9 o más antiguo pero encuentra el código actual raro.

### Objetivo pedagógico

**NO** formar buenos desarrolladores Angular. Formar **ojo para**:

- Detectar bugs en cualquier capa.
- Debuggear código productivo minificado.
- Comparar ambientes (UAT vs PROD).
- Resolver hotfixes sin romper nada más.
- Reconocer qué código es "moderno 16" y qué es "legacy sobreviviente".
- Escribir post-mortems que sirvan.

### Duración

**96 horas** = 24 días × media jornada.

---

## 🧬 2. Dominio del proyecto: Inspecciones y certificaciones

**Flujo:** Solicitud → programada → en inspección → hallazgos → aprobada/rechazada → certificado → vigencia → vencido → renovación.

Ejemplos de dominio: inspección técnico-mecánica de vehículos, revisión de ascensores, certificación de extintores, inspección sanitaria de restaurantes, revisión de equipos industriales.

### Actores

- **Cliente**: dueño del ascensor, del restaurante, del vehículo.
- **Activo**: la cosa que se inspecciona (Ascensor #3 del Edificio X).
- **Inspector**: quien va a campo y llena el checklist.
- **Certificado**: el documento resultante, con vigencia.

### Módulos CRUD

1. **Clientes y activos** — quién y qué se inspecciona.
2. **Plantillas de checklist versionadas** — el **corazón del proyecto**. Lista de ítems con criterio Sí/No/N.A., foto de evidencia, severidad. **Cambia la norma → plantilla v2** sin corromper histórico de v1.
3. **Inspecciones** — ejecución del checklist, formulario dinámico generado desde plantilla.
4. **Hallazgos** — no conformidades con severidad (crítico / mayor / menor). Crítico bloquea certificado.
5. **Certificados** — emisión, vigencia, PDF, renovación programada.

### Dashboard

Certificados por vencer (30/60/90 días), tasa de rechazo por inspector, hallazgos frecuentes, activos vencidos.

### Modelo de datos JSON de referencia

```json
{
  "clientes": [
    { "id": 1, "razonSocial": "Edificio Central S.A.", "nit": "900..." }
  ],
  "activos": [
    { "id": "ASC-CENTRAL-03", "clienteId": 1, "tipo": "ascensor",
      "descripcion": "Ascensor lado norte, torre A", "instalado": "2015-06-10" }
  ],
  "plantillas": [
    {
      "id": "ascensor-anual",
      "version": 2,
      "vigenteDesde": "2024-01-01",
      "vigenteHasta": null,
      "items": [
        { "id": "cable-principal", "titulo": "Estado del cable principal",
          "criterio": ["sin_desgaste", "desgaste_leve", "desgaste_critico"],
          "requiereFoto": true, "severidadNoConforme": "critico" }
      ]
    }
  ],
  "inspecciones": [
    {
      "id": 500,
      "activoId": "ASC-CENTRAL-03",
      "inspectorId": "INS-15",
      "plantillaId": "ascensor-anual",
      "plantillaVersion": 2,
      "estado": "en_curso",
      "iniciada": "2024-03-15T09:00:00Z",
      "respuestas": [
        { "itemId": "cable-principal", "respuesta": "desgaste_leve",
          "evidenciaUrl": "...", "observacion": "revisar en 6 meses" }
      ]
    }
  ],
  "certificados": [
    {
      "id": "CERT-2024-000500",
      "inspeccionId": 500,
      "emitido": "2024-03-15T15:00:00Z",
      "vigenteHasta": "2025-03-15T23:59:59Z",
      "estado": "vigente"
    }
  ]
}
```

Estados de inspección: `solicitada` → `programada` → `en_curso` → `finalizada` → `aprobada` | `rechazada`.
Estados de certificado: `emitido` → `vigente` → `por_vencer` → `vencido` | `revocado`.

**Regla clave (fuente de bugs):** una inspección ejecutada con `plantillaVersion: 1` **no puede re-renderizarse con la v2** aunque la plantilla haya cambiado. El histórico usa la versión que se ejecutó.

---

## 📊 3. Criterios pedagógicos del proyecto

| Criterio | Nivel | Cómo se manifiesta |
|---|---|---|
| **C1 Máquina de estados** | ⬛ | Inspección y certificado con transiciones ilegales |
| **C2 Concurrencia** | ▫ | Casi todo secuencial |
| **C3 Tiempo** | ⬛ | Vigencia + zona horaria + "¿vence hoy o ya venció?" + renovación programada |
| **C4 Dinero** | ▫ | Fuera de alcance |
| **C5 Cambio normativo** | ⬛ | Plantillas versionadas — corazón del proyecto |
| **C6 Trazabilidad** | ⬛ | Quién marcó cada ítem, cuándo, quién lo modificó |
| **C7 Reactividad** | ▫ | Casi nada en tiempo real |
| **C8 Integración** | ◼ | Mock de registro nacional de certificaciones |
| **C9 Formularios** | ⬛ | Checklist dinámico desde plantilla — muy denso |
| **C10 Kiosco** | ◼ | Inspector en campo con conexión intermitente |
| **C11 Curva de dominio** | ▫ | Requiere media hora de contexto — riesgo controlado |
| **C12 Alcance en 96h** | ◼ | Justo, motor de plantillas consume tiempo |

---

## 🧱 4. Stack oficial

| Herramienta | Versión | Nota |
|---|---|---|
| Node.js | **18.19.x** (Hydrogen LTS) | `.nvmrc`. Angular 16 requiere Node 16.14+ / 18.10+ |
| npm | 9.x | El que viene con Node 18 |
| Angular | **16.2.12** (última estable de la 16) | Confirmar con `ng version` del sistema real |
| Angular CLI | **16.2.12** | Pinneado |
| TypeScript | **4.9.5** o **5.1.6** | Angular 16 acepta 4.9.3–5.1.x |
| RxJS | **7.8.1** | Uso medio, más idiomático que Track A |
| Angular Material | **16.2.14** | Con MDC components |
| Angular CDK | **16.2.14** | — |
| zone.js | 0.13.x | Pinneado |
| json-server | 0.17.x | Mock API |
| Express + middleware caos | propio | Inyector de fallos |
| Jasmine | 4.6.x | Unitarios |
| Karma | 6.4.x | Runner |
| Playwright | última LTS | Smoke + e2e |

### Regla de mocks

- **Fase 0:** endpoint mínimo para el hola mundo.
- **Fase 3 en adelante:** json-server + middleware Express caos propio.

---

## 💻 4.b Entornos de desarrollo — notas por plataforma

**Windows 11:** Node 18.x vía nvm-windows, sin dramas de compilación.

**macOS Apple Silicon:** Node 18 funciona nativo en M1/M2/M3/M4 sin fricciones. 
Si prefieres contenedores para reproducir exactamente el ambiente PROD (Linux amd64):
- Opción simple: **Colima** con `colima start --arch aarch64` (arm64 nativo, funciona sin problemas de dependencias).
- Opción amd64 emulado (si necesitas paridad PROD exacta): `colima start --arch x86_64 --vm-type vz --vz-rosetta`.

**Linux amd64:** Node 18 nativo, sin sorpresas.

---

### Nota sobre el estilo mixto

El proyecto refleja la realidad: **standalone components de Fase 4+ conviviendo con NgModules** heredados de Fase 1-3. **`inject()` conviviendo con constructor**. Se muestra explícitamente cuándo usar cada uno y por qué el código real es mixto. **No se refactoriza el legacy** — se aprende a leerlo y modificarlo sin romperlo.

---

## 🪜 5. Mapa de fases

| Fase | Nombre | Horas | Qué entra | Qué NO entra |
|---|---|---|---|---|
| 🛠️ **0** | Setup + hola mundo standalone | 6h | NVM, Angular CLI 16, standalone bootstrap, form, POST | routing, servicios, Material |
| 🏗️ **1** | Estructura base + NgModules legacy | 8h | Módulos, routing, layout — estilo pre-standalone | standalone (viene fase 4) |
| 🔐 **2** | Autenticación mínima | 8h | Login mock, guard funcional, interceptor con `inject()`, localStorage | roles, refresh token |
| 🧪 **3** | Mock API + Express caos | 6h | json-server, `db.json`, middleware caos, servicios tipados | paginación server, cache |
| 🏗️ **4** | Migración a standalone | 6h | Convertir vistas nuevas a standalone, mezclar con NgModules legacy | eliminar módulos existentes |
| 👥 **5** | Clientes y activos | 8h | CRUD tipado, formularios reactivos tipados, Material 16 | trazabilidad completa |
| 📋 **6** | **Plantillas versionadas** ⭐ | 14h | Plantilla como entidad, versiones, `vigenteDesde/Hasta`, editor de plantilla | motor de render (viene fase 7) |
| 📝 **7** | Formulario dinámico desde plantilla ⭐ | 12h | Render desde plantilla, respuestas versionadas, `FormGroup<T>` dinámico | evidencia offline |
| ⚠️ **8** | Hallazgos y severidad | 6h | Cálculo de severidad, bloqueo de certificado por crítico | workflow multi-nivel |
| 📜 **9** | Certificados y vigencia | 8h | Emisión, PDF, vigencia con TZ, renovación programada | firma digital real |
| 📊 **10** | Dashboard + alertas | 6h | Certificados por vencer, KPIs, gráficos básicos | BI real |
| ✅ **11** | Testing + puente hacia 17 | 8h | Jasmine + TestBed, Signals-lite, control flow — solo lectura | refactor a Signals completo |

**Total: 96h de construcción + track forense y cuaderno de incidentes embebidos.**

⭐ = fases centrales del proyecto.

### Fases extra 🔥 (post-onboarding, asignables por el líder)

- 🔥 Migración de un módulo legacy a standalone.
- 🔥 Signals: reemplazar `BehaviorSubject` de un servicio.
- 🔥 Control flow nuevo (`@if/@for`) en una vista.
- 🔥 Testing e2e con Playwright avanzado.
- 🔥 Feature flag para exponer plantilla v3 en canary.
- 🔥 Optimización de performance de un formulario denso.

---

## 🕵️ 6. Track forense (integrado en todas las fases)

| Fase | Pieza forense |
|---|---|
| 0 | Consola, Network tab, DevTools básicos |
| 1 | Logs y errores de NgModules — dónde salen y qué significan |
| 2 | Debug de interceptor con `inject()` |
| 3 | Simular caos del backend con Express — cómo reacciona la SPA |
| 4 | Standalone vs NgModule en producción: cómo se ve un error de cada uno |
| 5 | Reproducir un bug de usuario sin acceso a PROD |
| 6 | Debug del versionado: "¿por qué esta inspección se ve con la plantilla vieja?" |
| 7 | Formularios dinámicos: dirty state, valueChanges infinito, referencias circulares |
| 8 | Bug de severidad: `null` vs `undefined` en TS strict |
| 9 | Timezone en producción: el certificado que "venció ayer" según el server pero no según el usuario |
| 10 | Performance del dashboard: cuándo culpar a `ChangeDetectionStrategy` |
| 11 | Test de regresión que reproduce el bug antes del fix |

Cierre: **checklist de hotfix** de 1 página.

---

## 📓 7. Cuaderno de incidentes

**15-20 incidentes** repartidos. Cada uno: repo roto + ticket de usuario → post-mortem.

### Distribución sugerida

- **Semana 1 (fases 0-3):** 3-4 🟢 — configuración, endpoints, CORS.
- **Semana 2 (fases 4-7):** 5-6 🟡 — standalone bootstrap mal, plantilla versionada renderizada con versión equivocada, `FormGroup` dinámico corrupto.
- **Semana 3 (fases 8-10):** 4-5 🟠 — hallazgo crítico que no bloquea, certificado emitido con hallazgo pendiente, PDF con datos stale.
- **Semana 4 (fases 11 + repaso):** 3-4 🔴 — bug intermitente, timezone en producción, memory leak de suscripción a `valueChanges`.

### Categorías

Máquina de estados · Versionado normativo · Tiempo · Trazabilidad · Formularios dinámicos · Integración · Performance · UI.

### Plantilla de post-mortem

1. **Síntoma** (palabras del usuario).
2. **Reproducción** (pasos exactos).
3. **Causa raíz** (línea o commit).
4. **Fix**.
5. **Prevención** (test, feature flag, alerta).

---

## 🎨 8. Apéndices

| Apéndice | Contenido | Horas est. |
|---|---|---|
| **A1 Angular Material 16 (MDC)** | Theming, componentes clave, form-field moderno, tokens | 3h |
| **A2 Bootstrap + Sass** | Solo si el sistema mezcla; customización mini design system | 2h |
| **A3 Node y npm** | Lockfiles, `npm ci` vs `npm i` | 1h |
| **A4 `inject()` vs constructor** | Cuándo usar cada uno, qué se rompe | 2h |
| **A5 Formularios reactivos tipados** | `FormGroup<T>`, `FormControl<T>` — desde Angular 14 | 3h |
| **A6 RxJS 7 idiomático** | Los operadores que sí aparecen: `map`, `switchMap`, `combineLatest`, `takeUntil`, `catchError` | 3h |
| **A7 Puente Angular 9 → 16** | Diff conceptual para lectores del Track A | 3h |
| **A8 Puente Angular 16 → 17** (opcional) | Signals, control flow, deferrable views | 2h |

---

## 🧪 9. Convenciones del curso

### Plantilla de cada capítulo (9 secciones)

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué NO entra todavía
4. 🧠 Concepto mínimo
5. 💻 Código mínimo con comentarios
6. ⚠️ Errores comunes
7. 🧪 Ejercicios (20-30, 🟢🟡🟠🔴)
8. 📚 Referencias
9. 🚀 Cierre

### Convenciones

- **Deuda técnica intencional** con 💸. En Track B **sí se paga** cuando corresponde (proyecto más nuevo, hay margen).
- **Fases extra opcionales** con 🔥.
- **Standalone + NgModule mezclado**: se muestra ambos estilos porque el código real es mixto.
- **`inject()` preferido en código nuevo**, constructor tolerado en código legacy.
- **TypeScript strict activado** desde el principio.
- **Signals mencionados como pincelada** en Fase 11 y Apéndice A8, no como estilo dominante (Angular 16 los tiene experimentales).

### Autodiagnóstico inicial

20 preguntas de nivel 🟢🟡🟠, más 5 preguntas específicas para lectores del Track A ("¿qué cambió entre 9 y 16?").

---

## 📌 10. Pendientes de confirmar antes de arrancar

- ¿Versión exacta? (`ng version` → confirmar 16.2.12).
- ¿Standalone al 100% o mezclado? (asumimos mezclado).
- ¿NgRx o servicios con `BehaviorSubject`?
- ¿Signals ya en uso en el sistema real?
- ¿Bootstrap conviviendo con Material?
- ¿Testing preexistente y cobertura?

---

# 🛠️ Guía operativa: cómo crear y organizar el proyecto

## 📐 Estructura de chats dentro del proyecto

Un solo proyecto de Claude para todo el tutorial. Adentro **~18-20 chats**:

| Tipo de chat | Cantidad | Entregable |
|---|---|---|
| Chat maestro — Temario | 1 | `plan-del-curso.md` |
| Chat de Fase N | 12 (Fases 0-11) | `fase-NN-slug.md` |
| Chat de apéndice | 6-8 | `apendice-slug.md` |
| Chat del track forense | 1 | `forense-*.md` |
| Chat del cuaderno de incidentes | 1 | `incidente-NN-*.md` + catálogo |
| Chat de smoke + regresión | 1 | `smoke-tests.md`, `regresion-*.md` |
| Chat "sala de dudas" | 1 | ninguno fijo |

**Regla:** cada chat produce **un archivo `.md` entregable**.

---

## 🎬 Pasos para crear el proyecto

### Paso 1 — Crear el proyecto en Claude

- **Nombre**: `Tutorial Angular 16 — Inspecciones y certificaciones`
- **Descripción**: `Onboarding de 96h para equipo de Maintenance del sistema Angular 16.2.12. Código mixto standalone/NgModule con TypeScript strict.`

### Paso 2 — Cargar archivos base al Project Knowledge

- ✅ Este documento (`tutorial-angular16.md`).
- ✅ `00-setup-hola-mundo.md` del curso Vue 2 (referencia de tono).
- ✅ `0-plan-del-curso.md` del curso Vue 2 (referencia de estructura).
- ✅ Opcional: `catalogo-futuros-proyectos.md`.

### Paso 3 — Pegar las instrucciones del proyecto

### Paso 4 — Abrir el chat maestro de temario

### Paso 5 — Ir abriendo un chat por fase / apéndice

---

## 📝 Prompt de instrucciones del proyecto

```
Eres colaborador en la construcción de un tutorial de Angular 16 para
un equipo de Maintenance que hereda un sistema aeronáutico bajo NDA
(no discutir el dominio real; usar Inspecciones y certificaciones como
proxy).

Contexto:
- Duración total: 96h (24 días × media jornada).
- Perfil del estudiante: dev backend/full-stack senior en onboarding.
- Objetivo: NO formar buenos desarrolladores Angular. Formar ojo para
  detectar bugs, debuggear código productivo, comparar UAT vs PROD,
  y resolver hotfixes.
- Estilo del código real: proyecto migrado a Angular 16.2.12 (última
  estable de 16). Contiene código legacy de versiones anteriores que
  sobrevivió a la migración: NgModules conviviendo con standalone,
  constructor conviviendo con inject(). No se refactoriza el legacy,
  se aprende a leerlo.
- TypeScript strict activado (TS-2).
- Signals no dominan el estilo — mencionar como pincelada en Fase 11.
- Stack fijo: Node 18.19, Angular 16.2.12, Angular CLI 16.2.12,
  TypeScript 4.9.5 o 5.1.6, RxJS 7.8.1, Angular Material 16.2.14
  (MDC), json-server, Express con inyector de caos propio.

Foco pedagógico especial:
- Plantillas de checklist versionadas (cambio normativo → v2 sin
  corromper histórico v1). Es el corazón del proyecto (Fase 6).
- Formularios reactivos tipados y dinámicos desde plantilla (Fase 7).
- Puente Angular 9 → 16 como apéndice para lectores del Track A.

Convenciones:
- Cada capítulo sigue la plantilla oficial de 9 secciones (definida en
  "tutorial-angular16.md" del Project Knowledge).
- Deuda técnica intencional se marca con 💸 y en Track B SÍ se paga
  cuando corresponde.
- Fases extra opcionales se marcan con 🔥.
- Formato Markdown, tono directo tipo curso Vue 2.
- Emojis en encabezados con moderación.
- Preferir prosa a bullets; tablas cuando comparen.
- Referencias oficiales primero (v16.angular.io), blogs después.

Cada chat produce UN archivo .md entregable. Si aparece algo fuera de
alcance del chat actual, anotarlo y sugerir chat aparte.

Cuando falte información del sistema real (versión de dependencia,
presencia de NgRx, uso de Signals), preguntar antes de asumir.

No romper el NDA: cero referencia a dominio aeronáutico. Todo en clave
de inspecciones y certificaciones.
```

---

## 🚀 Prompt de kick off — Chat maestro de temario

```
Este es el chat maestro del temario del tutorial Angular 16 + Inspecciones
y certificaciones.

Con base en el documento "tutorial-angular16.md" del Project
Knowledge, genera un plan-del-curso.md con:

1. Portada breve: filosofía, perfil del estudiante, cómo estudiar.
2. Descripción del proyecto Inspecciones: dominio, actores, módulos,
   modelo de datos JSON de referencia.
3. Stack unificado en tabla con versiones pinneadas.
4. Regla de mocks (json-server + Express caos).
5. Mapa de fases: Fase | Nombre | Qué entra | Qué NO entra | Horas.
   Total debe sumar 96h contando forense y cuaderno embebidos.
6. Apéndices sugeridos (Material MDC, Bootstrap+Sass opcional, Node/npm,
   inject() vs constructor, formularios tipados, RxJS 7, puente 9→16,
   puente 16→17 opcional).
7. Track forense: qué pieza en qué fase.
8. Cuaderno de incidentes: distribución 15-20 por semana y dificultad.
9. Fases extra 🔥.
10. Convenciones + plantilla de 9 secciones.
11. Autodiagnóstico inicial (20 preguntas 🟢🟡🟠 + 5 puente 9→16).

Restricciones:
- Total = 96h.
- 12 fases construcción máximo (0-11). No inflar.
- La Fase 6 (motor de plantillas versionadas) es la más pesada: ~14h.
- La Fase 7 (formulario dinámico desde plantilla) le sigue: ~12h.
- Estilo mixto standalone/NgModule por decisión pedagógica, no accidente.
- TypeScript strict activo.

Antes de generar, hazme las preguntas críticas:
- Confirmación de versión (¿16.2.12 exacto?).
- ¿NgRx o BehaviorSubject en el sistema real?
- ¿Signals ya usados o solo experimentales?
- ¿Bootstrap mezclado con Material?
- Cualquier otra crítica.
```

---

## 🧩 Templates de kick off por chat

### Template A — Chat de Fase N

```
Chat de la Fase {{N}} — {{Nombre de la fase}} del tutorial Angular 16 +
Inspecciones y certificaciones.

Referencias del proyecto:
- Documento base: tutorial-angular16.md (mapa de fases fila {{N}}).
- Plan del curso: plan-del-curso.md (fase {{N}}).
- Fases previas cerradas: {{lista}}.
- Próxima fase que dependerá: {{nombre}}.

Alcance:
- Propósito: {{una línea}}.
- Qué queda listo al terminar: {{lista}}.
- Qué NO entra (se deja para fase {{M}}): {{lista}}.
- Horas: {{X}}h.
- Conceptos clave: {{lista}}.
- Deuda técnica intencional 💸 (si aplica): {{describir}} — se paga en
  fase {{P}} (o "no se paga en este tutorial").

Estilo del código de esta fase:
- Standalone si es código nuevo (fase 4+); NgModule si es legacy (fase 1-3).
- inject() preferido en código nuevo; constructor tolerado en legacy.
- TypeScript strict activo.
- RxJS 7 idiomático moderado (no todo con async pipe, pero tampoco todo
  con .subscribe() a pelo).
- Signals: mencionar como pincelada solo si es Fase 11.

Genera el archivo fase-{{NN}}-{{slug}}.md siguiendo la plantilla oficial
de 9 secciones.

Extras a integrar:
- Pieza forense: {{descripción según sección 6 del doc base}}.
- Incidente(s) del cuaderno: {{cuáles}}.
- Guiño al puente 9→16 (si aplica): {{sí/no y qué}}.
- Guiño al puente 16→17 (solo Fase 11): {{sí/no}}.

Antes de escribir, hazme preguntas sobre versiones concretas, alcance
del ejemplo, y decisiones heredadas de fases anteriores.
```

### Template B — Chat de apéndice

```
Chat del apéndice "{{Nombre}}" del tutorial Angular 16 + Inspecciones.

Referencias:
- Documento base: tutorial-angular16.md (sección apéndices).
- Plan del curso: plan-del-curso.md.
- Fases que dependen: {{lista}}.

Alcance:
- Propósito: {{una línea}}.
- CONSULTA RÁPIDA, no lectura secuencial.
- Solo lo que aparece en el código real que van a mantener.
- Horas: {{X}}h.

Contenido esperado:
- {{Lista de secciones}}.

Genera apendice-{{slug}}.md con índice, secciones cortas con ejemplos,
tabla "cuándo usar qué", referencias oficiales, 5-10 ejercicios cortos.

Antes de escribir, pregúntame por versión exacta, convenciones ya
conocidas del sistema real, y qué queda fuera.
```

### Template C — Chat del track forense

```
Chat del track forense del tutorial Angular 16 + Inspecciones.

Este chat produce N piezas cortas insertables en fases.

Referencias:
- Documento base: tutorial-angular16.md (sección Track forense).
- Plan del curso: plan-del-curso.md.

Genera:
1. forense-master.md con índice, filosofía, módulos:
   - Lectura de logs (SPA vs backend, request-id).
   - Debugging productivo (DevTools 16, source maps).
   - Comparación UAT vs PROD (diff environment.ts).
   - Feature flags.
   - Checklist "funciona en UAT no en PROD".
   - Checklist "antes de hotfix".
   - Especial: debug del versionado de plantillas.
   - Especial: timezone en certificados.
2. forense-fase-{{N}}.md por fase (2-3 páginas cada uno).
3. forense-checklists.md con checklists sueltos.

Antes de escribir, hazme preguntas de alcance.
```

### Template D — Chat del cuaderno de incidentes

```
Chat del cuaderno de incidentes del tutorial Angular 16 + Inspecciones.

Genera 15-20 incidentes con:
- Título en lenguaje de usuario.
- Ticket simulado (2-3 frases).
- Fase donde se puede resolver.
- Categoría: máquina de estados / versionado / tiempo / trazabilidad /
  formularios dinámicos / integración / performance / UI.
- Dificultad 🟢🟡🟠🔴.
- Descripción técnica.
- Solución de referencia (una línea).
- Plantilla de post-mortem.

Distribución:
- Semana 1 (fases 0-3): 3-4 🟢.
- Semana 2 (fases 4-7): 5-6 🟡.
- Semana 3 (fases 8-10): 4-5 🟠.
- Semana 4 (fases 11 + repaso): 3-4 🔴.

Al menos 3 incidentes deben ser sobre versionado de plantillas
(cambio normativo), que es el corazón del proyecto.

Genera cuaderno-incidentes.md (catálogo) + incidente-NN-{{slug}}.md.

Antes de generar, hazme preguntas sobre incidentes que quieras ver
representados (sin violar NDA).
```

### Template E — Chat de smoke + regresión

```
Chat de smoke tests y regresión del tutorial Angular 16 + Inspecciones.

Genera:
1. smoke-tests.md con 8-10 casos Playwright: login, dashboard carga,
   CRUD clientes/activos, editar plantilla, ejecutar inspección, emitir
   certificado, no hay 500 en páginas principales.
2. regresion-como-escribir.md metodología "test primero".
3. regresion-no-reproducible.md metodología para bugs intermitentes.
4. Archivos de test listos para copiar.

Antes de generar:
- ¿Tests contra mock server o ambiente configurable?
- ¿Runner de CI simulado?
- ¿Playwright fixtures para autenticación?
```
