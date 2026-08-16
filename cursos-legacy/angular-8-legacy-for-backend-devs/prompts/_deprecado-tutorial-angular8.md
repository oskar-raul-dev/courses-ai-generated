> # 🪦 DOCUMENTO DEPRECADO — no es fuente de verdad de nada
>
> Este archivo es el encuadre **original** del proyecto, anterior a que se
> escribiera una sola fase. Se conserva por su valor histórico y porque explica
> de dónde salieron varias decisiones, no porque describa el curso de hoy.
>
> **Lo que dice y ya no vale:** habla de **96h y 12 fases**, cuando el reparto
> cerrado y verificado es de **122h y quince fases**; numera los apéndices de
> **A1 a A9**, cuando van de **A01 a A13**; y organiza el trabajo alrededor de un
> `plan-del-curso.md` que nunca llegó a existir.
>
> **Dónde está lo vigente:** el alcance en `alcance-del-proyecto.md`, el reparto
> de fases y apéndices en `propuesta-fases-y-alcance.md`, la voz y las reglas en
> `guia-de-estilo-y-convenciones.md`, y el stack en el `README.md` del curso.

---

# ⚠️ Documento histórico — no es fuente de verdad

> **Estado (confirmado en el chat de la Fase 12): DEPRECADO.** La fuente de
> verdad primaria del proyecto es **`ALCANCE-DEL-PROYECTO.md`**, seguida de
> `propuesta-fases-y-alcance.md`. Este archivo **no** se cita en ningún
> entregable y solo sobrevive como material de consulta histórica. Ante
> cualquier discrepancia, gana `ALCANCE-DEL-PROYECTO.md`.

Este archivo fue la propuesta inicial del tutorial y se conserva **solo por
tres cosas**: el dominio del laboratorio clínico, el modelo de datos JSON de
referencia, y los criterios pedagógicos de la sección 3.

**Todo lo demás quedó superado.** No lo uses para tomar decisiones ni lo cites
en un entregable. En concreto, están obsoletos:

- **La duración y el mapa de fases.** Acá dice 96h y 12 fases (0-11), con
  nombres y numeración distintos a los vigentes. Lo vigente son **122h** —
  108h de fases (0-13) + 14h de cuaderno de incidentes — con la Fase 13
  opcional y sin horas. Ojo: la numeración cambió, así que "Fase 4" de este
  documento no es la Fase 4 del curso.
- **Las horas por fase.** Todas se redistribuyeron. La Fase 1, por ejemplo,
  pasó de 8h a 12h cuando NgRx dejó de ser "store preparado" y se volvió el
  centro de la fase.
- **El mapa del track forense y la distribución de incidentes**, que siguen
  la numeración vieja.
- **La lista de apéndices**, que pasó de 9 a 13 y renumeró casi todos.
- **La guía operativa del final** (estructura de chats, prompts de kick off,
  templates): se rehizo por completo y vive en los documentos vigentes.
- **El tratamiento de la configuración por ambiente.** Este documento la daba
  por horneada y cerrada. Lo vigente es que la **Fase 12** enseña a inyectarla
  en tiempo de arranque (`assets/config.json` + `APP_INITIALIZER` +
  `entrypoint.sh` con `envsubst`), dejando el horneado de `environment.ts` como
  deuda 💸 declarada del sistema real. Ver `fase-12-build-despliegue.md`.

**Fuentes de verdad, en este orden:** instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `ALCANCE-DEL-PROYECTO.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`plan-del-curso.md`, y los entregables de fases ya cerradas.

Si algo de este archivo contradice a los anteriores, ganan ellos. Si crees
que algo de acá debería seguir vigente, se decide en el chat correspondiente
y se sube al documento que toque — no se rescata desde este.

# 🏥 Tutorial Angular 8 — Laboratorio clínico

Documento base del **Track A**. Se lleva al proyecto de Claude que hospedará
el desarrollo del tutorial. Autocontenido: no requiere leer los otros dos
documentos.

---

## 🎯 1. Alcance del tutorial

### Perfil del sistema real que se hereda

- Sistema aeronáutico bajo NDA (no discutir el dominio real; se usa **Laboratorio clínico** como proxy).
- Ciclo de vida H2 2019 → 2023, ahora en **mantenimiento** con posible decomisión en 2-3 años.
- Casi sin features nuevas, salvo cambios normativos o legales.
- Código estilo **"Java Swing con TypeScript"**: componentes gordos, lógica de negocio en modelos, `subscribe()` a pelo, `any` por todos lados.
- **RxJS de uso mínimo** — no idiomático.
- **TypeScript nivel TS-0**: usado solo porque el CLI obliga, `strict: false`.
- Angular Material con theme personalizado (mini design system).

### Perfil del estudiante

- Dev backend/full-stack senior en onboarding.
- Sabe HTML/CSS/JS básico. No necesita que le expliquen HTTP, JSON o tokens.
- Quiere autonomía: pasos concretos + enlaces oficiales.

### Objetivo pedagógico

**NO** formar buenos desarrolladores Angular. Formar **ojo para**:

- Detectar bugs en cualquier capa.
- Debuggear código productivo minificado.
- Comparar ambientes (UAT vs PROD).
- Resolver hotfixes sin romper nada más.
- Escribir post-mortems que sirvan.

### Duración

**96 horas** = 24 días × media jornada (1 mes de onboarding).

---

## 🧬 2. Dominio del proyecto: Laboratorio clínico

**Flujo:** Orden → toma de muestra → proceso → resultado → validación → entrega → vencimiento.

### Módulos CRUD

1. **Pacientes y órdenes** — datos del paciente, orden médica, exámenes solicitados.
2. **Muestras** — código único, tipo (sangre/orina/...), estado, cadena de custodia.
3. **Procesos** — asignación a analista, equipos, tiempos.
4. **Resultados** — valor + unidad + **rango de referencia versionado** + validación por profesional habilitado.
5. **Entrega** — al paciente, al médico, PDF firmado, vigencia.

### Dashboard

Órdenes por estado, tiempos promedio por examen, resultados críticos del día, resultados fuera de rango.

### Modelo de datos JSON de referencia

```json
{
  "pacientes": [
    { "id": 1, "documento": "1015...", "nombre": "María Pérez", "nacimiento": "1985-03-12" }
  ],
  "ordenes": [
    {
      "id": 1001,
      "pacienteId": 1,
      "medico": "Dr. López",
      "fecha": "2024-03-10T08:00:00Z",
      "examenes": ["hemograma", "glicemia"],
      "estado": "en_proceso"
    }
  ],
  "muestras": [
    {
      "id": "M-2024-000123",
      "ordenId": 1001,
      "tipo": "sangre",
      "estado": "recibida",
      "custodia": [
        { "por": "auxiliar1", "en": "2024-03-10T08:30:00Z", "accion": "toma" }
      ]
    }
  ],
  "resultados": [
    {
      "id": 5001,
      "muestraId": "M-2024-000123",
      "examen": "glicemia",
      "valor": 98,
      "unidad": "mg/dL",
      "rangoRefId": "glicemia-adultos-v2",
      "estado": "pendiente_validacion"
    }
  ],
  "rangosReferencia": [
    {
      "id": "glicemia-adultos-v2",
      "examen": "glicemia",
      "poblacion": "adultos",
      "min": 70,
      "max": 110,
      "unidad": "mg/dL",
      "vigenteDesde": "2023-01-01",
      "vigenteHasta": null
    }
  ]
}
```

Estados de orden: `pendiente` → `en_proceso` → `resultados_parciales` → `completa` → `entregada` → `vencida`.
Estados de muestra: `programada` → `tomada` → `recibida` → `en_proceso` → `procesada` → `descartada`.

---

## 📊 3. Criterios pedagógicos del proyecto

Escala: ⬛ fuerte · ◼ medio · ▫ débil.

| Criterio | Nivel | Cómo se manifiesta |
|---|---|---|
| **C1 Máquina de estados** | ⬛ | Orden y muestra con transiciones estrictas; resultado con validación irreversible |
| **C2 Concurrencia** | ◼ | Dos analistas validando el mismo resultado |
| **C3 Tiempo** | ◼ | Vigencia del resultado, orden vencida sin toma, resultados de fin de semana |
| **C4 Dinero** | ▫ | Fuera de alcance |
| **C5 Cambio normativo** | ⬛ | Rangos de referencia versionados: cambia la norma → v2 → histórico intacto |
| **C6 Trazabilidad** | ⬛ | Quién tomó, procesó, validó, entregó (audit log obligatorio) |
| **C7 Reactividad** | ◼ | Alertas de resultado crítico |
| **C8 Integración** | ◼ | Mock de equipo de laboratorio (analizador) que envía resultados |
| **C9 Formularios** | ⬛ | Densos por tipo de examen, validaciones cruzadas |
| **C10 Kiosco/offline** | ▫ | No aplica |
| **C11 Curva de dominio** | ◼ | Requiere breve explicación pero es entendible |
| **C12 Alcance en 96h** | ◼ | Cabe justo |

---

## 🧱 4. Stack oficial

| Herramienta | Versión | Nota |
|---|---|---|
| Node.js | **12.22.12** o **14.21.3** | `.nvmrc`. Angular 8 salió con Node 10-12; 14 funciona con warnings |
| npm | 6.x | El que viene con Node 12/14 |
| Angular | **8.2.14** (última estable de la 8) | Confirmar con `ng version` del sistema real |
| Angular CLI | **8.3.29** | Pinneado |
| TypeScript | **3.5.3** | Exacto (Angular 8 no acepta 3.6+ sin ajustes) |
| RxJS | **6.5.5** | Uso mínimo, no idiomático |
| Angular Material | **8.2.3** | Con theme personalizado |
| Angular CDK | **8.2.3** | — |
| zone.js | 0.9.1 | Pinneado con Angular 8 |
| json-server | 0.16.x | Mock API oficial |
| Express + middleware caos | propio | Inyector de fallos (latencia, 500, malformadas) |
| Jasmine | 3.4.x | Unitarios |
| Karma | 4.x | Runner |
| Playwright | última LTS | Smoke tests (independiente de Angular) |

### Regla de mocks

- **Fase 0:** un endpoint mínimo hardcodeado para el hola mundo.
- **Fase 3 en adelante:** json-server (`localhost:3000`) + middleware Express propio que inyecta caos por header o endpoint.
- El middleware caos es **componente propio del curso**, no librería. Simula: latencia, 500 intermitentes, respuestas malformadas, CORS roto, token expirado, timeouts.

### Nota TS-0

En este tutorial se **desactiva `strict` a propósito** para reproducir el estilo del sistema real. En un apéndice se muestra qué bugs habría atrapado el strict mode — como transición al Track B (Angular 16). El estudiante ve la ganancia sin abandonar el estilo del código real que va a mantener.

---

## 💻 4.b Entornos de desarrollo

**Windows 11 es el entorno por defecto del equipo** (matcheando el estándar corporativo). Pero muchos devs traen MacBook con Apple Silicon, y estos entornos tienen fricciones reales con Angular 8. Lidiar con ellas **es parte del ejercicio pedagógico** — un dev de Maintenance vive resolviendo "en mi máquina no compila".

Se documentan las siguientes vías, en orden de recomendación por plataforma:

### 🪟 Windows 11 (entorno por defecto)

**Vía nativa** con nvm-windows:

- Node 12.22.12 o Node 14.21.3 vía [nvm-windows](https://github.com/coreybutler/nvm-windows).
- Git for Windows con bash.
- Python 3 en `PATH` (para node-gyp).
- Build tools: `npm install --global windows-build-tools` (deprecated pero funcional en Windows 11) **o** instalar manualmente Visual Studio Build Tools 2019 con "Desktop development with C++".
- No hay problemas de arquitectura: todo es x86_64.

Tiempo estimado de setup: 20-30 min. Ejercicio de la Fase 0.

### 🍎 macOS Apple Silicon (M1/M2/M3/M4)

Angular 8 tiene tres dependencias problemáticas en arm64:

1. **`node-sass`**: nunca tuvo binarios prebuilt para arm64. Deprecated desde 2020.
2. **`node-gyp` viejo**: usa Python 2, que macOS moderno ya no trae.
3. **Puppeteer/Chromium bundleado con Karma**: en arm64 hay que apuntar al Chrome del sistema.

Hay **tres opciones**, según qué priorice el dev:

#### Opción M1-A — arm64 nativo en Docker (recomendada)

Corre contenedores Linux arm64 directamente, sin emulación. Se reemplaza `node-sass` por `sass` (dart-sass, JS puro). Angular CLI 8 detecta `sass` automáticamente. **Casi tan rápido como nativo, sin Rosetta.**

```dockerfile
# Dockerfile.dev
FROM node:14.21.3-bullseye

RUN apt-get update && apt-get install -y \
    build-essential python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python

WORKDIR /app
EXPOSE 4200 9876
CMD ["bash"]
```

Cambio en `package.json`:

```json
{
  "devDependencies": {
    "sass": "^1.32.0"
  }
}
```

`docker-compose.yml`:

```yaml
services:
  angular:
    build: .
    volumes:
      - .:/app
      - node_modules:/app/node_modules    # ← clave: volumen dedicado
    ports: ["4200:4200", "9876:9876"]
    stdin_open: true
    tty: true
  mock:
    image: node:14
    working_dir: /mock
    volumes: [./mock:/mock]
    command: npx json-server --host 0.0.0.0 --watch db.json
    ports: ["3000:3000"]
volumes:
  node_modules:
```

Flujo:
```bash
docker compose up -d
docker compose exec angular bash
# ya dentro:
npm ci --legacy-peer-deps
npx ng serve --host 0.0.0.0
```

Editar en VS Code en el host, Chrome en `localhost:4200`.

#### Opción M1-B — amd64 con Rosetta (paridad exacta con PROD)

Si el sistema real corre en Linux amd64 en producción y quieres reproducir exacto (útil sobre todo para el chat de smoke tests y bugs "solo pasan en PROD"):

1. Instalar Rosetta: `softwareupdate --install-rosetta --agree-to-license`
2. Docker Desktop → Settings → General → activar **"Use Rosetta for x86_64/amd64 emulation on Apple Silicon"** (más rápido que QEMU tradicional).
3. En el Dockerfile: `FROM --platform=linux/amd64 node:12.22.12-bullseye`.

Velocidad: 2-3× más lento que arm64 nativo, pero idéntico a PROD.

**Nota:** Rosetta 2 sigue disponible en macOS Sequoia y estará en macOS 27; se retira parcialmente en macOS 28 (fall 2027). Por eso Opción M1-A es la apuesta a futuro.

#### Runtime del contenedor: Colima (recomendado) o Docker Desktop

**Colima** ([`brew install colima`](https://github.com/abiosoft/colima)): runtime de contenedores basado en Lima. Mismos comandos `docker` y `docker compose`, **~2 GB de RAM**. Usa VZ framework de Apple + Rosetta 2 para amd64 (más rápido que QEMU). **Recomendado por defecto.**

```bash
brew install colima docker docker-compose
# Para opción M1-A (arm64 nativo):
colima start --cpu 4 --memory 4 --arch aarch64

# Para opción M1-B (amd64 emulado con paridad PROD):
colima start --cpu 4 --memory 4 --arch x86_64 --vm-type vz --vz-rosetta
```

Luego cualquier `docker` o `docker compose` funciona igual.

**Docker Desktop:** alternativa válida. GUI, actualizaciones automáticas, cómodo si ya lo tienes. **Costo: 6-8 GB de RAM** solo por estar corriendo. Ambos runtimes usan Rosetta igual, así que la velocidad es similar. Si prefieres Docker Desktop, todo el proyecto funciona sin cambios — basta activar "Use Rosetta for x86_64/amd64 emulation on Apple Silicon" en Settings.

**Cambiar entre uno y otro:** En Fase 0 se documenta cómo encender Colima y apagar Docker Desktop (o viceversa) sin que el proyecto se rompa. Es un ejercicio útil: el código es agnóstico del runtime.

### 🐧 Linux amd64

Sin sorpresas: Node 12/14 con nvm, todo funciona nativo. Ejercicio de setup en Fase 0 ≤ 15 min.

### 🪟 Windows en macOS (cuando toca reproducir un bug específico de Windows)

Si aparece un incidente que **solo pasa en Windows 11** (path separators, line endings, permisos NTFS, servicio de Windows), hay dos caminos en Apple Silicon:

- **[UTM](https://mac.getutm.app/)** (gratis, QEMU): Windows 11 ARM Insider Preview corre razonablemente en M1/M2. Setup 1-2 h. Bueno para reproducciones puntuales.
- **Parallels Desktop / VMware Fusion**: pagos (Parallels) o gratis para uso personal (Fusion), mejor integración pero pesados.

**No es requisito del tutorial** — se documenta como recurso para el track forense cuando un incidente lo justifique.

### Tabla comparativa rápida

| Entorno | Setup | Velocidad | RAM | Paridad con PROD | Recomendación |
|---|---|---|---|---|---|
| Windows 11 nativo | Media | ⚡⚡⚡ | Baja | Alta (si PROD es Windows) o Media (si PROD es Linux) | **Default del tutorial** |
| Linux nativo | Rápida | ⚡⚡⚡ | Baja | Alta | Si tienes Linux |
| M1 + Colima arm64 (Opción A) | Rápida | ⚡⚡⚡ | Baja | Media | **Recomendada en M1 (arm64)** |
| M1 + Colima amd64+vz-rosetta (Opción B) | Rápida | ⚡⚡⚡ | Baja | Alta | **Recomendada en M1 (paridad PROD)** |
| M1 + Docker Desktop arm64 | Media | ⚡⚡⚡ | Media | Media | Alternativa si prefieres GUI |
| M1 + Docker Desktop amd64 Rosetta | Media | ⚡⚡⚡ | Media | Alta | Alternativa si prefieres GUI |
| Windows en M1 (UTM/Parallels) | Alta | ⚡ | Alta | Alta (para bugs Windows) | Solo cuando toque |

---

## 🪜 5. Mapa de fases

| Fase | Nombre | Horas | Qué entra | Qué NO entra |
|---|---|---|---|---|
| 🛠️ **0** | Setup + hola mundo | 6h | NVM, Angular CLI 8, componente único, form, POST a mock local | routing, servicios, Material |
| 🏗️ **1** | Estructura base | 8h | módulos, layout, router, vistas placeholder, services/store preparados | auth, API real, CRUD |
| 🔐 **2** | Autenticación mínima | 8h | login mock, localStorage, guard, interceptor, logout | backend real, refresh token, roles |
| 🧪 **3** | Mock API mínima | 6h | json-server, `db.json`, Express caos, servicios reales | backend propio, paginación server |
| 🏥 **4** | Pacientes y órdenes | 10h | tabla Material, filtros, CRUD, formularios reactivos | validación cruzada, permisos |
| 🧫 **5** | Muestras y cadena de custodia | 8h | máquina de estados, transiciones, timeline | trazabilidad completa (fase 9) |
| 🧬 **6** | Resultados y rangos versionados | 10h | rangos v1/v2, cálculo fuera-de-rango, validación por profesional | firma digital, workflow multi-nivel |
| 📦 **7** | Entrega y PDF | 8h | generación de informe, vigencia, notificación | firma digital real |
| 📊 **8** | Dashboard | 6h | gráficos simples con librería nativa/CDK, KPIs básicos | BI real, agregaciones server |
| 📜 **9** | Trazabilidad y audit log | 6h | quién hizo qué, dónde vive el registro, timeline consultable | encriptación, retención legal |
| ✅ **10** | Testing mínimo | 6h | Jasmine + TestBed, un test por tipo | e2e, coverage alto, CI |
| 🚚 **11** | Cierre y migración opcional | 4h | apéndice hacia Angular 9 e Ivy; guiño a 16 | migración real, refactor |

**Total: 86h de construcción + 10h de track forense embebido + cuaderno de incidentes al final = 96h.**

Nota: el track forense y el cuaderno de incidentes se distribuyen a lo largo de las fases (ver secciones 6 y 7), no ocupan bloques separados en el calendario.

### Fases extra 🔥 (post-onboarding, asignables por el líder)

- 🔥 Migración TS-0 → TS-1 (activar `strictNullChecks`, ver qué explota).
- 🔥 Refactor de un componente gordo a servicio + componente presentacional.
- 🔥 RxJS idiomático: reescribir un servicio para usar `switchMap` y `async` pipe.
- 🔥 Testing e2e con Playwright.
- 🔥 Feature flag para exponer una regla nueva sin desplegar dos veces.

---

## 🕵️ 6. Track forense (integrado en todas las fases)

No es una fase separada. Se **inyecta** en las fases donde es natural:

| Fase | Pieza forense que se inyecta |
|---|---|
| 0 | Consola del navegador, Network tab como fuente de verdad |
| 1 | Estructura de logs de la SPA — dónde termina cada `console.log` |
| 2 | Debug de interceptor HTTP — request-id, breakpoints condicionales |
| 3 | Simular fallo del backend con Express caos + qué hace la SPA cuando ve un 500 |
| 4 | Reproducir un bug de un usuario a partir del ticket sin acceso a producción |
| 5 | Debug de máquina de estados: transición ilegal en logs |
| 6 | Source maps en producción — cómo activarlos y por qué a veces mienten |
| 7 | Diff de `environment.ts` — checklist "funciona en UAT y no en PROD" |
| 8 | Performance panel de DevTools — cuándo un dashboard "se pone lento" |
| 9 | El audit log como herramienta forense: reconstruir un incidente |
| 10 | Test de regresión que reproduce el bug **antes** del fix |
| 11 | Feature flags para hotfix seguro |

Cierre del track: un **checklist de hotfix** de 1 página que el estudiante se lleva.

---

## 📓 7. Cuaderno de incidentes

**15-20 incidentes** repartidos a lo largo del mes. Cada uno: repo roto + ticket de usuario en lenguaje de negocio → estudiante llena plantilla de post-mortem.

### Distribución sugerida

- **Semana 1 (fases 0-3):** 3-4 incidentes 🟢 fáciles — errores de configuración, endpoints mal, CORS.
- **Semana 2 (fases 4-6):** 5-6 incidentes 🟡 medios — máquinas de estado rotas, validación floja, rangos mal aplicados.
- **Semana 3 (fases 7-9):** 4-5 incidentes 🟠 duros — audit log incompleto, PDF con datos stale, race condition en validación.
- **Semana 4 (fases 10-11):** 3-4 incidentes 🔴 muy duros — bugs intermitentes, memory leak de suscripción, orden vencida que se validó igual.

### Categorías

Máquina de estados · Concurrencia · Tiempo · Normativo · Trazabilidad · Integración · Performance · UI.

### Plantilla de post-mortem (1 página)

1. **Síntoma** (en palabras del usuario).
2. **Reproducción** (pasos exactos).
3. **Causa raíz** (línea o commit culpable).
4. **Fix** (qué cambio hizo el arreglo).
5. **Prevención** (test de regresión, feature flag, o alerta).

---

## 🎨 8. Apéndices

| Apéndice | Contenido | Horas est. |
|---|---|---|
| **A1 Angular Material** | Theming, componentes clave (form-field, table, dialog, snackbar), form controls | 3h |
| **A2 Bootstrap 4 + Sass** | Solo si el sistema real mezcla; personalización de paleta | 2h |
| **A3 Node y npm** | Lockfiles, dependencies vs devDependencies, `npm ci` vs `npm i` | 2h |
| **A4 Webpack oculto** | Qué hace Angular CLI 8 por debajo, dónde vive el `ng eject` que ya no existe | 2h |
| **A5 RxJS de supervivencia** | Los 5-6 operadores que sí aparecen en código real: `map`, `filter`, `tap`, `catchError`, `switchMap`, `take` | 3h |
| **A6 Migración Angular 8 → 9** (opcional) | Ivy, cambios de compilación, mensajes de error, `ng update` | 3h |
| **A7 Migración Angular 9 → 16** (opcional) | Pinceladas: strict, standalone, `inject()`, control flow | 2h |
| **A8 Dependencias problemáticas en arm64 / M1** | El clásico "en mi Mac no compila": `node-sass` → `sass`, `node-gyp` + Python, Puppeteer/Chromium, Sharp, bcrypt. Diagnóstico y soluciones | 2h |
| **A9 Docker + Colima para dev legacy** | Setup Colima con perfiles arm64 y amd64+vz-rosetta, docker-compose para el proyecto, debug dentro del contenedor con VS Code Devcontainers | 2h |

Los apéndices son consulta rápida, no lectura obligatoria secuencial.

---

## 🧪 9. Convenciones del curso

### Plantilla de cada capítulo (9 secciones)

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué NO entra todavía
4. 🧠 Concepto mínimo (teoría justa)
5. 💻 Código mínimo con comentarios didácticos
6. ⚠️ Errores comunes
7. 🧪 Ejercicios (20-30, dificultad 🟢🟡🟠🔴)
8. 📚 Referencias (oficiales primero)
9. 🚀 Cierre

### Convenciones de código y notación

- **Deuda técnica intencional** se marca con 💸. En Track A la deuda **NO se paga** — el sistema real está en mantenimiento y refactorizar es fuera de alcance.
- **Fases extra opcionales** con 🔥.
- **`function () {}` en vez de arrow functions** en métodos de clase — mantiene el sabor de la época y evita sorpresas con `this`.
- **`any` tolerado**. Se comenta pero no se corrige.
- **RxJS mínimo**. `.subscribe()` a pelo es aceptable en este tutorial.
- **NgModules siempre**. Nada de standalone.

### Autodiagnóstico inicial

20 preguntas para nivelar al grupo, adaptando las del curso Vue 2 pero con foco en Angular/TS/HTTP. Se genera al escribir el `plan-del-curso.md` en el proyecto.

---

## 📌 10. Pendientes de confirmar antes de arrancar

- ¿Versión exacta del sistema real? (`ng version` → confirmar 8.2.x)
- ¿Bootstrap conviviendo con Material o solo Material?
- ¿NgRx o servicios con `BehaviorSubject`? (para reproducir el estilo)
- ¿Testing existente en el sistema real o cero?
- ¿Sistema real usa `strict: false` como asumimos?
- ¿Ambiente productivo real corre en Windows Server o Linux? (afecta si Opción M1-B tiene valor real de paridad)
- ¿Cuántos devs del grupo traen MacBook M-series? (afecta cuánto énfasis dar al apéndice A8/A9)

---

# 🛠️ Guía operativa: cómo crear y organizar el proyecto

## 📐 Estructura de chats dentro del proyecto

Un solo proyecto de Claude para todo el tutorial. Adentro, **~18-20 chats**
organizados así:

| Tipo de chat | Cantidad | Propósito | Entregable |
|---|---|---|---|
| Chat maestro — Temario | 1 | Refina el temario completo | `plan-del-curso.md` |
| Chat de Fase N | 12 (Fases 0-11) | Desarrolla una fase | `fase-NN-slug.md` |
| Chat de apéndice | 5-7 | Un apéndice por tema | `apendice-slug.md` |
| Chat del track forense | 1 | Piezas forenses por fase + master | `forense-*.md` |
| Chat del cuaderno de incidentes | 1 | Los 15-20 incidentes | `incidente-NN-*.md` + catálogo |
| Chat de smoke + regresión | 1 | Playwright + metodología | `smoke-tests.md`, `regresion-*.md` |
| Chat "sala de dudas" | 1 | Transversal | ninguno fijo |

**Regla de oro:** cada chat produce **un archivo `.md` entregable**. Si un chat
no produce archivo, o sobra o se salió de alcance.

---

## 🎬 Pasos para crear el proyecto

### Paso 1 — Crear el proyecto en Claude

- Botón **"+ Nuevo proyecto"** en claude.ai.
- **Nombre**: `Tutorial Angular 8 — Laboratorio clínico`
- **Descripción**: `Onboarding de 96h para equipo de Maintenance del sistema Angular 8 legacy. Estilo Java Swing con TS, RxJS mínimo, TS-0.`

### Paso 2 — Cargar archivos base al Project Knowledge

- ✅ Este documento (`tutorial-angular8.md`).
- ✅ `00-setup-hola-mundo.md` del curso Vue 2 (referencia de tono, formato y densidad de un capítulo bien hecho).
- ✅ `0-plan-del-curso.md` del curso Vue 2 (referencia de estructura de plan).
- ✅ Opcional: `catalogo-futuros-proyectos.md` (para consulta ocasional).

### Paso 3 — Pegar las instrucciones del proyecto (system prompt)

Ver sección siguiente.

### Paso 4 — Abrir el chat maestro de temario

Usar el prompt de "kick off del chat de temario" más abajo.

### Paso 5 — Ir abriendo un chat por fase / apéndice

Usar los templates de kick off correspondientes.

---

## 📝 Prompt de instrucciones del proyecto

Copiar-pegar en el campo **"Instrucciones del proyecto"** al crearlo:

```
Eres colaborador en la construcción de un tutorial de Angular 8 legacy
para un equipo de Maintenance que hereda un sistema aeronáutico bajo NDA
(no discutir el dominio real; usar Laboratorio clínico como proxy).

Contexto:
- Duración total: 96h (24 días × media jornada).
- Perfil del estudiante: dev backend/full-stack senior en onboarding.
- Objetivo: NO formar buenos desarrolladores Angular. Formar ojo para
  detectar bugs, debuggear código productivo, comparar UAT vs PROD,
  y resolver hotfixes.
- Estilo del código real: "Java Swing con TypeScript" — componentes
  gordos, lógica en modelos, RxJS mínimo, TS-0 (`any` común,
  `strict: false` intencional).
- Stack fijo: Node 12/14, Angular 8.2.14, Angular CLI 8.3.29,
  TypeScript 3.5.3, RxJS 6.5.5, Angular Material 8.2.3, json-server,
  Express con inyector de caos propio.
- NgModules siempre. Nada de standalone. Nada de Ivy explícito.
- Windows 11 es el entorno por defecto del equipo. macOS Apple Silicon
  se soporta con Docker (arm64 nativo con dart-sass, o amd64 con
  Rosetta/vz-rosetta). Colima como alternativa liviana a Docker Desktop.
  Los issues de compatibilidad arm64 son parte del ejercicio pedagógico,
  no incidencias a esconder.

Convenciones:
- Cada capítulo sigue la plantilla oficial de 9 secciones (definida en
  el documento base "tutorial-angular8.md" del Project Knowledge).
- Deuda técnica intencional se marca con 💸 y en Track A NO se paga.
- Fases extra opcionales se marcan con 🔥.
- Formato Markdown, tono directo tipo curso Vue 2 anterior.
- Emojis en encabezados con moderación (imitando el estilo del Vue 2).
- Preferir prosa a bullets; tablas cuando comparen versiones/opciones.
- Referencias oficiales primero (angular.io/v8), blogs después.
- `function () {}` en métodos de clase, no arrow, para reproducir el estilo.

Cada chat produce UN archivo .md entregable. No divagar entre temas:
si aparece algo fuera de alcance del chat actual, anotarlo y sugerir
un chat aparte.

Cuando falte información del sistema real (versión exacta de una
dependencia, presencia de NgRx o BehaviorSubject, testing preexistente),
preguntar antes de asumir.

No romper el NDA: cero referencia a dominio aeronáutico, aeropuertos,
vuelos, aerolíneas, o infraestructura de aviación. Todo en clave de
laboratorio clínico.
```

---

## 🚀 Prompt de kick off — Chat maestro de temario

Primer chat del proyecto. Su salida es `plan-del-curso.md` con la lista
definitiva de fases, apéndices y carga horaria.

```
Este es el chat maestro del temario del tutorial Angular 8 + Laboratorio
clínico.

Con base en el documento "tutorial-angular8.md" del Project
Knowledge, genera un plan-del-curso.md con:

1. Portada breve: filosofía, perfil del estudiante, cómo estudiar el curso.
2. Descripción del proyecto Laboratorio clínico: dominio, módulos, modelo
   de datos JSON de referencia.
3. Stack unificado en tabla con versiones pinneadas (copiar del documento
   base, verificar coherencia).
4. Regla de mocks: json-server + Express caos.
5. Mapa de fases: tabla con Fase | Nombre | Qué entra | Qué NO entra |
   Horas. Total debe sumar 96h contando track forense y cuaderno de
   incidentes embebidos.
6. Apéndices sugeridos (Material, Sass opcional, Node/npm, Webpack oculto,
   RxJS supervivencia, migración 8→9 opcional, migración 9→16 opcional,
   dependencias problemáticas arm64/M1, Docker+Colima para dev legacy).
7. Track forense: tabla de qué pieza va en qué fase.
8. Cuaderno de incidentes: cómo se distribuyen los 15-20 incidentes por
   semana y por dificultad.
9. Fases extra 🔥 sugeridas.
10. Convenciones y plantilla de 9 secciones.
11. Autodiagnóstico inicial (20 preguntas nivel 🟢🟡🟠).

Restricciones:
- Total = 96h. Las horas por fase + forense + incidentes deben sumar 96h.
- 12 fases construcción máximo (0-11). No inflar.
- Track forense embebido en fases, no fase separada.
- Estilo Java Swing / RxJS mínimo / TS-0.
- NgModules siempre.

Antes de generar, hazme las preguntas críticas que necesitas resueltas:
- Confirmación de versión Angular exacta (¿8.2.14 o algo menor?).
- ¿Bootstrap conviviendo con Material?
- ¿NgRx o `BehaviorSubject`? (para reproducir el estilo)
- ¿Testing preexistente?
- Cualquier otra que consideres crítica.
```

---

## 🧩 Templates de kick off por chat

Rellenar los `{{campos}}` antes de pegar en cada chat nuevo.

### Template A — Chat de Fase N (y Fase 0 en particular)

```
Chat de la Fase {{N}} — {{Nombre de la fase}} del tutorial Angular 8 +
Laboratorio clínico.

NOTA ESPECIAL PARA FASE 0: Este chat cubre también el setup del entorno
de desarrollo, incluyendo:
- Windows 11 nativo (vía nvm-windows): pasos exactos.
- macOS M1 con Colima (recomendado) o Docker Desktop: instalación,
  primeros comandos, qué significa --arch aarch64 vs --arch x86_64.
- Cómo cambiar entre Colima y Docker Desktop sin que el proyecto se rompa
  (operativa práctica: `colima stop`, `colima start`, etc.).
- El cambio node-sass → sass en package.json (y por qué).

Referencias del proyecto:
- Documento base: tutorial-angular8.md (sección 4.b Entornos de desarrollo).
- Documento base: tutorial-angular8.md (mapa de fases fila {{N}}).
- Plan del curso: plan-del-curso.md (fase {{N}}).
- Fases previas ya cerradas: {{lista de nombres o "ninguna"}}.
- Próxima fase que dependerá de esta: {{nombre o "ninguna"}}.

Alcance de esta fase:
- Propósito: {{una línea}}.
- Qué queda listo al terminar: {{lista breve}}.
- Qué NO entra todavía (se deja para fase {{M}}): {{lista breve}}.
- Horas estimadas: {{X}}h.
- Conceptos clave: {{lista}}.
- Deuda técnica intencional 💸 (si aplica): {{describir y anotar que
  NO se paga en el tutorial}}.

Estilo del código de esta fase:
- Java Swing con TS: lógica en componente, servicios con estado mutable.
- RxJS mínimo: `.subscribe()` a pelo aceptable.
- TS-0: `any` tolerado, `strict: false`.
- NgModules, no standalone.
- `function () {}` en métodos, no arrow.

Genera el archivo fase-{{NN}}-{{slug}}.md siguiendo la plantilla oficial
de 9 secciones:
1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué NO entra todavía
4. 🧠 Concepto mínimo
5. 💻 Código mínimo con comentarios
6. ⚠️ Errores comunes
7. 🧪 Ejercicios (20-30, dificultad 🟢🟡🟠🔴)
8. 📚 Referencias (angular.io/v8 primero)
9. 🚀 Cierre

Extras a integrar:
- Pieza forense de esta fase: {{describir según sección 6 del doc base}}.
- Incidente(s) del cuaderno relacionados: {{cuáles de los 15-20}}.
- Menciones al puente 8→9: {{sí/no y qué anotar}}.

Antes de escribir, hazme cualquier pregunta que necesites para no asumir.
Especialmente sobre versiones concretas de dependencias, alcance del
ejemplo, y decisiones de diseño heredadas de fases anteriores.
```

### Template B — Chat de apéndice

```
Chat del apéndice "{{Nombre del apéndice}}" del tutorial Angular 8 +
Laboratorio clínico.

Referencias del proyecto:
- Documento base: tutorial-angular8.md (sección de apéndices).
- Plan del curso: plan-del-curso.md.
- Fases que dependen de este apéndice: {{lista}}.

Alcance:
- Propósito: {{una línea, p.ej. "cubrir lo mínimo de Angular Material 8
  para leer y modificar formularios densos del sistema real"}}.
- Es apéndice de CONSULTA RÁPIDA, no lectura obligatoria secuencial.
- No explica el framework/librería entera; solo lo que aparece en el
  código real que van a mantener.
- Horas de referencia: {{X}}h.

Contenido esperado:
- {{Lista de secciones}}.

Genera el archivo apendice-{{slug}}.md con:
- Índice al inicio.
- Secciones cortas con ejemplos mínimos.
- Tabla "cuándo usar qué" al final.
- Referencias oficiales.
- 5-10 ejercicios cortos.

Antes de escribir, pregúntame:
- Versión exacta a cubrir.
- Qué convenciones del sistema real ya son conocidas (no repetirlas).
- Qué queda explícitamente fuera del apéndice.
```

### Template C — Chat del track forense

```
Chat del track forense del tutorial Angular 8 + Laboratorio clínico.

Este chat NO produce una fase única. Produce N piezas cortas que se
insertan en cada fase de construcción.

Referencias:
- Documento base: tutorial-angular8.md (sección "Track forense").
- Plan del curso: plan-del-curso.md (mapa de qué pieza va dónde).

Genera:
1. forense-master.md con índice, filosofía, y los módulos:
   - Lectura de logs (consola vs servidor, dónde vive cada console.log).
   - Debugging productivo (DevTools, source maps, breakpoints
     condicionales, Network tab).
   - Comparación de ambientes UAT vs PROD (diff de environment.ts).
   - Feature flags para hotfix seguro.
   - Checklist "funciona en UAT y no en PROD".
   - Checklist "antes de hacer un hotfix".
2. forense-fase-{{N}}.md por cada fase, con la pieza que se inyecta
   ahí (2-3 páginas máximo cada uno).
3. forense-checklists.md con checklists sueltos reutilizables.

Antes de escribir, hazme preguntas sobre alcance por fase.
```

### Template D — Chat del cuaderno de incidentes

```
Chat del cuaderno de incidentes del tutorial Angular 8 + Laboratorio
clínico.

Genera un catálogo de 15-20 incidentes, cada uno con:
- Título en lenguaje de usuario (p.ej. "Los resultados críticos no
  disparan alerta en fin de semana").
- Ticket de reporte simulado (2-3 frases del usuario).
- Fase del tutorial en la que se puede resolver.
- Categoría: máquina de estados / concurrencia / tiempo / normativo /
  trazabilidad / integración / performance / UI.
- Dificultad: 🟢🟡🟠🔴.
- Descripción técnica de qué está mal (para el instructor).
- Solución de referencia (una línea).
- Plantilla de post-mortem que el estudiante llena.

Distribución:
- Semana 1 (fases 0-3): 3-4 🟢.
- Semana 2 (fases 4-6): 5-6 🟡.
- Semana 3 (fases 7-9): 4-5 🟠.
- Semana 4 (fases 10-11): 3-4 🔴.

Genera:
- cuaderno-incidentes.md con el catálogo completo.
- incidente-NN-{{slug}}.md por cada incidente con el detalle técnico.

Antes de generar, hazme preguntas sobre incidentes clásicos que quieras
ver representados (sin violar NDA).
```

### Template E — Chat de smoke + regresión

```
Chat de smoke tests y regresión del tutorial Angular 8 + Laboratorio
clínico.

Genera:
1. smoke-tests.md con 8-10 casos Playwright que deben pasar tras cada
   hotfix. Cubrir: login, dashboard carga, CRUD principal de pacientes/
   órdenes/muestras/resultados, no hay error 500 en páginas principales.
2. regresion-como-escribir.md con metodología "test primero, fix después"
   para bugs reproducibles.
3. regresion-no-reproducible.md con metodología cuando el bug no se
   reproduce (logging temporal, feature flag para exponer estado).
4. Los archivos de test propiamente dichos, listos para copiar al repo.

Antes de generar, pregúntame:
- ¿Los tests corren contra el mock server o contra ambiente configurable?
- ¿Runner de CI simulado o pendiente documentado?
```
