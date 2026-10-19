# 🧪 angular-16-legacy-for-backend-devs-20261007-a754 · cómo correr estas pruebas

> **Curso:** angular-16-legacy-for-backend-devs · **Tanda:** T2-T5 · **Creado:** 2026-10-07
> **Propósito:** Edición Plomada: extractor de bloques del markdown, tsc de business-day.ts, línea base de tiempo y pruebas de los incidentes 21 y 22, php -l del track BE
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

Este directorio guarda las pruebas del plan de edición del curso
(`prompts/_desechable-plan-de-edicion.md`, regla 4: todo bloque que la edición toca se extrae del
markdown y se compila o se corre en contenedor). T3, T4 y T5 lo reutilizan y suman su sección aquí.

| Prueba | Tanda | Fase | Qué alimenta |
|---|---|---|---|
| `editar-t2.py` | T2 | F06, F07, F10, forense-06, forense-10, A13 | los reemplazos de texto de T2, exactos y de una sola aparición |
| `extraer.py` | T2–T4 | F02–F11 | reconstruye `src/app/core/{models,domain,time,pdf}` desde los bloques del markdown |
| `tsc` de los bloques tocados | T2 | F07 (`business-day.ts`), F10 (`business-day.ts` añadido, `certificate-document.ts`) | criterio de cierre de T2 |
| `tsc` de todo `core/` | T2 (informativo) | F02–F11 | encontró el desfase de F11 → tanda T2b |
| `editar-t2b.py` | T2b | F10, F11, F12 | los reemplazos de T2b (D26, D27) |
| `correr-t2b.sh` | T2b | F02–F12 | `tsc` estricto de `core/` con los specs puros de F12, y esos specs en Jasmine |
| `correr-t3.sh` | T3 | F03, F07, F10, cuaderno (15 y 21), preparaciones | el incidente 21 roto y arreglado, y su vecino el 15, desde el markdown |
| `pruebas/zonas-t3.js` | T3 | historia §8, plan §6 | offsets de las cuatro zonas, hora por hora, 2016–2026, y las conversiones literales del 21 |
| `pruebas/ruc_ec.py` | T3 (→ T4) | preparaciones (21) | el RUC ficticio bien formado de la hostería |
| `correr-t4.sh` | T4 | F03, F06, cuaderno (22) | el formulario de clientes de `fase-06` y con el fix del 22: tsc con Material y Jasmine sobre un bundle de esbuild |
| `pruebas/t4-extra.spec.ts` | T4 | F06 | NIT/RUC por los síncronos de cada árbol, y el asíncrono de F06 con un doble `of(...)` |
| `pruebas/linea-base.ts` | T2 → T3 | F07, F10 | `linea-base-t2.json`: lo que el código responde hoy en el continente; T3 prueba contra esto que el fix del 21 no mueve nada |

## 2. 🛠️ Prerrequisitos

- Docker en el host y la imagen `node:18.18.2-alpine`, la misma de F13 del curso.
- Python 3 en el host, solo con la biblioteca estándar (para `extraer.py` y `editar-t2.py`).
- Las dependencias de `package.json`, con las versiones exactas de `00-setup-hola-mundo.md` y F10:
  TypeScript 5.1.6, `@angular/*` 16.2.12, RxJS 7.8.1, jsPDF 2.5.1; desde T2b, `@types/jasmine` 4.6.4 y
  `jasmine-core` 4.6.1 de F12, y el ejecutor `jasmine` 4.6.0 para correrlos sin Karma; desde T3, `jspdf-autotable` 3.8.4 (F10 dice
  "3.8.x": se tomó la última de esa línea); desde T4, `@angular/material` y `@angular/cdk` 16.2.14,
  `@angular/router`, `@angular/animations` y `@angular/compiler` 16.2.12, y `esbuild` 0.19.12. Se instalan **dentro del
  contenedor** en `node_modules/` de este directorio; en el host no se instala nada.
- El curso en `../../cursos-legacy/angular-16-legacy-for-backend-devs` (o en `CURSO=`).

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
{ date; docker ps -a --format '{{.ID}} {{.Names}} {{.Image}} {{.Status}}'; echo ---vol; docker volume ls -q; } \
  > salidas/inventario-inicial.log
```

Los contenedores llevan `--label curso=angular16` y `--rm`: no queda ninguno al terminar. No se
publica ningún puerto. No se cambia nada de la máquina.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
# Solo una vez, y solo sobre el curso sin editar: aplica los reemplazos de T2.
# Aborta sin escribir si un texto no aparece exactamente una vez (por eso, sobre el curso
# ya editado, falla: es lo esperado).
python3 editar-t2.py

# Extracción, tsc y línea base (instala node_modules la primera vez).
bash correr-t2.sh
```

`correr-t2.sh` hace, en orden:

1. `python3 extraer.py` → `salidas/src-extraido/` y `salidas/extraccion.txt` (de qué fase y línea
   sale cada archivo; los bloques "— lo que se AÑADE" se concatenan al archivo base; las variantes
   "LA VERSIÓN QUE FALLA" quedan fuera y se listan).
2. `npm install` en el contenedor, si no hay `node_modules/`.
3. `npx tsc -p tsconfig.tocados.json` → `salidas/tsc-tocados.txt`. Los dos archivos que T2 tocó, con
   todo lo que importan. Tiene que salir vacío.
4. `npx tsc -p tsconfig.core.json` → `salidas/tsc-core-completo.txt`. Todo lo extraído; informativo.
5. `npx tsc -p tsconfig.run.json && node salidas/js/pruebas/linea-base.js` → `salidas/linea-base.json`.

`tsconfig.json` repite el bloque estricto de `00-setup-hola-mundo.md` (con `skipLibCheck` y
`moduleResolution: node`, como el `tsconfig` que genera el CLI de Angular 16).

### T2b

```bash
python3 editar-t2b.py        # solo sobre el curso sin T2b; aborta si un texto no cuadra
bash correr-t2b.sh
```

`correr-t2b.sh`: `extraer.py --specs` → `salidas/src-t2b/` (con los `.spec.ts`; en un spec, la nota
de la cabecera no cambia nada); copia de F07 la **cabecera** del bloque de `template-api.service.ts`
hasta la marca `// …dentro de TemplateApiService…`, porque `core/api/` no se reconstruye (sus "lo que
se añade" son métodos dentro de la clase) y `derive-all-findings.ts` solo necesita `buildTemplateRowId`;
`tsc -p tsconfig.t2b.json` → `salidas/tsc-t2b.txt` (vacío); `tsc -p tsconfig.t2b-run.json` a
CommonJS y `jasmine --random=true` sobre los cuatro specs sin Angular → `salidas/jasmine-t2b.txt`;
y vuelve a correr `correr-t2.sh` para comparar la línea base. `inspection-form.spec.ts` se compila pero
no corre: Angular 16 se publica como ESM y el Jasmine de Node no lo carga sin *bundler*.

### T3

```bash
python3 editar-t3-inc15.py      # solo sobre el curso sin T3: el 15 contra F10 (D31)
bash correr-t3.sh               # arma salidas/t3/ (si ya existe, la mueve a t3-anterior-<sello>)
docker run --rm --label curso=angular16 -v "$PWD":/w -w /w node:18.18.2-alpine node pruebas/zonas-t3.js
```

El incidente 21 en sí (`incidente-21.md`) y su receta (`prep-21.md`) se escribieron aquí y se
pegaron al cuaderno y a `prompts/preparaciones-de-incidentes.md`; desde entonces **manda el
markdown del curso**, y `correr-t3.sh` lee de ahí, no de estas copias.

`correr-t3.sh`, en orden:

1. **`salidas/t3/base`** = `fase-10`: `extraer.py` (models, domain, time, pdf) + dos bloques copiados
   tal cual con `bloque.py`: `certificate-state.service.ts` (F10 §5.5) y `certificate-pdf.service.ts`
   "LA VERSIÓN QUE PAGA" (F10 §5.8, un fragmento sin `import`: se le antepone
   `pruebas/stubs-t3/cabecera-pdf-service.ts`) + la cabecera de `template-api.service.ts` de F07 +
   los **stubs** de `pruebas/stubs-t3/` (los servicios de API y `InspectionStateService`, con las
   firmas del curso y sin cuerpo: no son del curso y sirven solo para que `tsc` compile los dos
   servicios que el fix toca).
2. **`fix21`** = base + la solución de referencia del 21, aplicada desde el cuaderno con
   `aplicar-solucion.py` (8 bloques: 7 `diff` y 1 "lo que añade el fix"; el spec de regresión se
   escribe como `certificate-status.incidente-21.spec.ts`). **`base15`** = base + el spec del 15.
   **`roto15`** = base15 + el `diff` de la receta `incidente/15`, con `aplicar-preparacion.py`.
3. `gen-db-21.py`: la semilla de F03 §5.2 + las filas de la receta del 21 → `db.incidente-21.json`;
   con el `diff` de datos de la solución → `db.incidente-21-fix.json`. Los dos van además a
   `pruebas/db-21.check.ts` de cada árbol con `satisfies` contra los modelos de ese árbol (así se
   tipan con las uniones literales, cosa que un `import` de JSON no hace).
4. `tsc` estricto (`tsconfig.t3-fix.json`, `tsconfig.t3-base.json` sin el spec del 21, con
   `experimentalDecorators` por los `@Injectable`).
5. Jasmine por árbol: `fix21` con los specs del 21, del 15 y `pruebas/t3-extra.spec.ts` (la pantalla
   con los datos de la receta, el continente con zona explícita, el PDF y el lado pantalla de
   be-08); `base` con los specs del 21 y del 15; `roto15` con el del 15. Se compila a CommonJS
   aunque haya errores de tipos (los specs del 21 llaman con un tercer argumento que `fase-10` no
   tiene): así se ve el **fallo en ejecución**.
6. La línea base de T2 corrida sobre `fix21`, comparada con `linea-base-t2.json`.

### T4

```bash
bash correr-t4.sh               # arma salidas/t4/ (si ya existe, la mueve a t4-anterior-<sello>)
```

1. **`salidas/t4/base`** = `fase-06`: modelos de F03, `api-error.ts` de F03, y de F06 el componente,
   la plantilla y `unique-tax-id.validator.ts`, copiados tal cual con `bloque.py`; más los stubs de
   `pruebas/stubs-t4/` (`ClientApiService` y `ClientStateService` con las firmas de F06).
2. **`fix22`** = base + la solución del 22 desde el cuaderno (`aplicar-solucion.py`: el archivo
   "nuevo" `tax-id.validator.ts`, el `diff` del componente, el `diff` HTML de la plantilla, y el spec
   como `tax-id.validator.incidente-22.spec.ts`).
3. `validadores-del-arbol.py` copia literalmente el arreglo `validators` del control `taxId` de cada
   componente a `pruebas/validators-del-arbol.ts`. Así `t4-extra.spec.ts` prueba, en cada árbol,
   exactamente lo que dice su versión del formulario.
4. `tsc` estricto con `@angular/material` 16.2.14 (A01), `cdk` 16.2.14 y `router` 16.2.12.
5. Jasmine sobre un **bundle de esbuild** 0.19.12 (`--platform=node --format=cjs`) cuya entrada
   importa primero `@angular/compiler`: Angular 16 se publica en ESM con declaraciones parciales
   (`ɵɵngDeclare*`) que sin el compilador JIT no cargan, y Jasmine en Node no lee ESM sin *bundler*.
   El asíncrono corre con el `timer(400)` real del validador (se espera 500 ms).

### T5

```bash
# Bloque PHP de be02 (HealthLegacyController), extraído del markdown tal como queda
docker run --rm --label curso=angular16 -v "$PWD/t5":/work:ro php:7.4-cli php -l /work/be02-HealthLegacyController.php
```

1. `t5/be02-HealthLegacyController.php` es el único bloque PHP que la tanda toca (el comentario de
   procedencia de línea 187). Se extrajo con una expresión regular de bloques ```` ```php ````
   del markdown; el resto de be00, be02, be07, bea-07 y el cuaderno BE son prosa y no tienen código
   que cambiar.
2. Salida esperada: `No syntax errors detected`. Se corrió con `php:7.4-cli` (PHP 7.4.33), la imagen
   de las sondas de `bea-02`.

### T7 · corrida final

Se repitió de cero, en contenedores nuevos y con los scripts de arriba, contra el markdown tal como
quedó al cerrar T6 y T7. Salidas en `t7-corrida/`:

```bash
bash correr-t2.sh      # t7-corrida/t2.txt   → tsc tocados OK; línea base escrita
bash correr-t2b.sh     # t7-corrida/t2b.txt  → tsc t2b OK; Jasmine 17 specs, 0 fallos; línea base igual a la de T2
bash correr-t3.sh      # t7-corrida/t3.txt   → tsc fix21 y base OK; fix21 15/0; base 6 con 3 fallos; roto15 2 con 2 fallos
bash correr-t4.sh      # t7-corrida/t4.txt   → tsc base y fix22 OK; base 14 con 4 fallos; fix22 17/0
```

- Los resultados de T3 y T4 coinciden con los guardados en `resultados-t3.txt` y `resultados-t4.txt`.
- `correr-t2.sh` imprime «tsc core completo: con errores»: es informativo, como indica el propio script
  (todo `core/` extraído, no solo los bloques tocados). Lo que cierra T2 es «tsc tocados: OK».
- Ningún contenedor ni volumen con `curso=angular16` queda tras la corrida.
- T5 se repitió con `php -l` en `php:7.4-cli` (sección T5 de este README).
- Los verificadores del curso (`verificar-corpus.py`, `verificar-forenses.py`) están en `t6-*.txt` y
  `t7-*.txt` en este directorio.

## 5. 📏 Cómo se mide

No hay medición de rendimiento: son pruebas de compilación y de salida exacta. La línea base no
consulta el reloj: cada caso de `deriveCertificateStatus` fija su `now`. Corre en Node 18.18.2,
ICU 73.2 y tz 2023c (los tres van impresos en la salida).

## 6. 🧮 Los intermedios que amasan la salida

Ninguno: `linea-base.json` es la salida cruda de `linea-base.js`. Para leerla resumida:

```bash
python3 -c "
import json;d=json.load(open('linea-base-t2.json'))
for c in d['toBusinessDayCasos']: print(c['instant'],c['toBusinessDay'],set(c['intl'].values()))
for e in d['estados']: print(e)"
```

## 7. ✅ Qué se espera ver

**T2, 2026-10-07:**

- `tsc tocados: OK`. **Antes** de agregar el import en F10 §5.8 fallaba con
  `certificate-document.ts(101,10): error TS2304: Cannot find name 'toBusinessDay'`: el bloque usaba
  `toBusinessDay` sin importarlo, desde antes de la edición. El autor aprobó agregar la línea.
- `tsc core completo` con 6 errores:
  - 5 en `dashboard-metrics.ts` (F11), que importa `BusinessInstant`, `CERTIFICATE_EXPIRING_DAYS`,
    `certificateStatus` y `daysUntilExpiry`, nombres que F10 no exporta (los suyos son `Instant`,
    `EXPIRING_WINDOW_DAYS`, `deriveCertificateStatus` y el campo `daysUntilExpiry` de
    `CertificateView`), más un `any` implícito que viene de ahí. Va a la tanda **T2b** del plan.
  - 1 en `derive-all-findings.ts`, que importa `core/api/template-api.service`. **No es un error del
    curso**: `extraer.py` no extrae `core/api/` (F07 sí exporta `buildTemplateRowId`).
- `linea-base-t2.json` (copia versionada de `salidas/linea-base.json`). Dos corridas dieron lo mismo
  byte a byte. Lo esencial:
  - `toBusinessDay` coincide en los 11 instantes con el día local de `Intl` en `America/Bogota`,
    `America/Lima` y `America/Guayaquil` (fin de día, `Z` a las 04:59:59 y 05:00, cambio de mes, de
    año, 29 de febrero).
  - Un certificado con `validUntil` `2025-02-10T23:59:59-05:00` está `expiring` hasta las 23:59:59 de
    ese día y `expired` desde las `00:00:00-05:00` (o `05:00:00Z`) del 11; `valid` el 10 de enero y
    `expiring` el 11 (30 días).
  - `computeValidity` reproduce los cuatro casos de la prueba de fuego de F10, incluido el 29 de
    febrero → 28 de febrero y el 15 de marzo a las 23:30 → 15 de marzo.

**T2b, 2026-10-07:**

- **Antes** de `editar-t2b.py`: `tsc` con 5 errores en `dashboard-metrics.ts` y 6 en los specs de F12
  (`certificateStatus`, `daysUntilExpiry`, `addMonths`, y `toBe` con `number | null`); con la API
  corregida, Jasmine dio `17 specs, 1 failure`: *deriveCertificateStatus devuelve `valid` en el último
  segundo de vigencia — Expected 'expiring' to be 'valid'*.
- **Después:** `tsc t2b: OK` (27 archivos), `17 specs, 0 failures` con semilla aleatoria, y la línea
  base igual a `linea-base-t2.json`.

**T3, 2026-10-07** (copia versionada en `resultados-t3.txt`):

- `pruebas/zonas-t3.js`: Node 18.18.2, ICU 73.2, tz 2023c. `Pacific/Galapagos` GMT−06:00 todo
  2016–2026; `America/Guayaquil`, `America/Lima` y `America/Bogota`, GMT−05:00. **`America/Galapagos`
  no existe** (`RangeError: Invalid time zone specified`): la historia y el plan lo decían así, y se
  corrigió. `2026-03-12T23:59:59-05:00` → `"12/3/2026, 22:59:59"` en Galápagos y `"12/3/2026,
  23:59:59"` en Guayaquil (`toLocaleString('es-EC')`).
- `tsc fix21: OK` y `tsc base: OK`. **Antes** de la corrección de F10 (D32), los dos fallaban con
  `TS2345` en `render()`: `AutoTableFn` pedía filas `readonly` y `jspdf-autotable` 3.8.4 las da
  mutables.
- `jasmine fix21: 15 specs, 0 failures`. `jasmine base: 6 specs, 3 failures` (los tres del 21 que
  dependen de la zona; el de "sin zona, el continente sigue igual" pasa, como debe). `jasmine
  roto15: 2 specs, 2 failures`.
- La línea base sobre `fix21`: idéntica a `linea-base-t2.json`.

**T4, 2026-10-07** (copia en `resultados-t4.txt`): `tsc base: OK`, `tsc fix22: OK`; `jasmine base:
14 specs, 4 failures` (el RUC de Perú y el de Ecuador no pasan los síncronos, y el de la hostería
nunca llega al asíncrono: cero llamadas al doble); `jasmine fix22: 17 specs, 0 failures` (los 14 de
`t4-extra` y los 3 del cuaderno). Lo que no tiene forma (12 dígitos) no llega al servidor en ninguno
de los dos árboles; un NIT repetido se sigue marcando `taxIdTaken`.

## 8. 📂 Salidas

| Archivo | Lo escribe | Se versiona |
|---|---|---|
| `salidas/inventario-inicial.log` | §3 | no |
| `salidas/extraccion.txt`, `salidas/src-extraido/` | `extraer.py` | no (se regenera) |
| `salidas/tsc-tocados.txt`, `salidas/tsc-core-completo.txt` | `correr-t2.sh` | no |
| `salidas/js/`, `salidas/linea-base.json`, `salidas/linea-base.err` | `correr-t2.sh` | no |
| `salidas/src-t2b/`, `salidas/js-t2b/`, `salidas/tsc-t2b.txt`, `salidas/jasmine-t2b.txt`, `salidas/extraccion-t2b.txt` | `correr-t2b.sh` | no |
| `salidas/t3/` (árboles, js, tsc, jasmine, db) y `salidas/t3-anterior-*` | `correr-t3.sh` | no |
| `resultados-t3.txt` | copia de `zonas-t3.txt` y de las tres salidas de Jasmine, al cerrar T3 | **sí** |
| `salidas/t4/` y `salidas/t4-anterior-*` | `correr-t4.sh` | no |
| `resultados-t4.txt` | copia de las salidas de tsc y Jasmine al cerrar T4 | **sí** |
| `linea-base-t2.json` | copia a mano de `salidas/linea-base.json` al cerrar T2 | **sí**: T3 compara contra ella |

Al curso no se copió nada de aquí: el único cambio de código del curso (el import de F10) se hizo a
mano en el markdown.

## 9. 🧹 Limpieza

Los contenedores se crean con `--rm`; para confirmarlo:

```bash
docker ps -a --filter label=curso=angular16 --format '{{.Names}}'   # vacío
```

La imagen `node:18.18.2-alpine` se queda mientras T3–T5 la usen; al cerrar T7, si no estaba antes
de la edición, `docker rmi node:18.18.2-alpine`. `node_modules/`, `salidas/` → `python3
zz-code/limpiar.py` (con `--borrar` solo si el autor lo autoriza).

## 10. 🚫 Qué se dejó fuera

`node_modules/` (hoy más de 132 MB: se midió al cerrar T2): `npm install` dentro del contenedor, como hace `correr-t2.sh`; `package-lock.json` sí se guarda, para que la reinstalación dé el mismo árbol. No hay
secretos.
