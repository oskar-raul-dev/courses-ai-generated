# SUPERFICIE.md — be06: la reescritura a medias

> Fase be06. Mide la reescritura con tres números, decide qué camino es el oficial por recurso, pone las pruebas que
> valen y mide el ciclo. Medido el 15/10/2026 sobre `zz-code/…-be/server/`, con el canon decidido el 15/10: **desde be03
> el camino nuevo sirve las rutas del frontend y el viejo sigue vivo en `/legacy/…`**.

---

## 1. Número 1 — endpoints por camino

`grep -E "\$router->(get|post|put|patch|delete)" routes/web.php` → **29 rutas**: 27 del camino nuevo y 2 del viejo.

| Recurso | Camino viejo (servido) | Camino nuevo (servido) | ¿Quién lo usa? | Oficial |
|---|---|---|---|---|
| `/templates` | `GET /legacy/templates` (`LegacyTemplateController`, parcela laravel: sin orden, sólo vigentes, filas crudas) | 4 rutas | Frontend → nuevo; panel heredado → viejo | **Nuevo** |
| `/findings` | `POST /legacy/findings` (clausura en `routes/web.php`, parcela laravel: sin validar) | `GET`, `POST` (valida, 422), `PATCH` + la anidada | Frontend → nuevo (sólo lee y resuelve); panel heredado → viejo (crea) | **Nuevo** |
| `/clients` | — | 5 rutas | Frontend | Nuevo |
| `/assets` | — | 4 rutas | Frontend | Nuevo |
| `/inspections` | — | 4 rutas + `GET /inspections/{id}/findings` | Frontend | Nuevo |
| `/certificates` | — | 4 rutas (leen la vista de be05) | Frontend | Nuevo |
| `/auth/login`, `/health` | — | 2 | Frontend / supervisión | Nuevo |

**Movidas: 27. No movidas (servidas sólo por el viejo): 0. Con dos caminos vivos: 2 recursos (`/templates`, `/findings`).**
La firma del camino oficial por recurso la dio el autor el 15/10/2026: **el nuevo, para los seis recursos**, y el viejo
se queda vivo hasta que be07 decida.

---

## 2. Número 2 — endpoints a medias dentro de sí mismos

```
grep -rl "__construct" app/Http/Controllers/     → (ninguno)
grep -rln "app(\|DB::" app/Http/Controllers/    → HealthController.php, LegacyTemplateController.php,
                                                   Concerns/MapsDatabaseErrors.php
```

- `LegacyTemplateController` usa `app('cache')` (service locator): es el camino viejo, no está a medias, está entero en su parcela.
- `HealthController` usa `app()->version()`: no obtiene una dependencia de negocio.
- `MapsDatabaseErrors` usa `app('db')->transaction(...)`: es el savepoint de toda escritura del camino nuevo, a propósito.

**Resultado: 0 endpoints a medias.** Ningún controlador nuevo llama a código del camino viejo, y al revés.

**Lo que sí cruza las parcelas** (medido en el incidente be-01): la caché `templates.all` del camino viejo no se invalida cuando
el camino nuevo publica una versión. Es acoplamiento por **dato**, no por código, y `grep` no lo encuentra.

---

## 3. Número 3 — escrituras por recurso

| Recurso | Sitios que escriben | Detalle |
|---|---|---|
| `inspections` | 2 de aplicación + 2 de siembra | `InspectionController::store`, `::patch`; `DbJsonSeeder`, `volume.php` |
| `findings` | 3 | `FindingController::store` (nuevo, valida), `FindingController::patch`, `POST /legacy/findings` (viejo, sin validar) |
| `templates` | 2 | `TemplateController::store`, `::update` (cierre de versión) |

**Para la salida C de be05 (disciplina de aplicación) son dos puertas en `inspections`**, y las dos son del camino nuevo.
En `findings` hay una puerta sin validar: es el incidente be-11.

---

## 4. Pruebas que valen

PHPUnit 8.5.56, Mockery 1.x, dentro del contenedor `api`, contra `postgres:16.9`. Cada prueba va en una transacción que se
deshace; las escrituras del backend usan un savepoint, así un error de integridad no envenena la transacción externa.

| Prueba | Afirma | Decisión que protege |
|---|---|---|
| `InvariantTest` (2) | La versión 99 falla en la base; las huérfanas históricas siguen ahí | be05 |
| `ContractTest` (3) | Array sin sobre con `validUntil` nulo; la 501 es v1 con 3 respuestas; `404` con `{}` | be00 |
| `PaginationTest` (2) | Sin `_page` llega todo; `_page=2&_limit=2` | be03 |
| `ErrorContractTest` (3) | Integridad = 409; no hay cascada al borrar clientes | be03 (decisión del `DELETE`) |
| `RegressionTest` (1) | Una huérfana sigue saliendo con sus respuestas | be-09 |
| `TemplateCloseTest` (1) | **Cerrar la v2 no toca la v1 ni la de calderas** | Bug de la clave compuesta (§6) |

**12 pruebas, 27 aserciones, en verde.** El volumen queda igual antes y después de la suite.

---

## 5. La pieza que decide: `500` o `422`

Medido con el mismo cuerpo malo (`inspection_id` 9999):

```
POST /legacy/findings → 500      (camino viejo: deja que la clave foránea lo rechace)
POST /findings        → 422      (camino nuevo: valida antes de escribir)
```

El frontend de Angular **no crea hallazgos**: ningún cliente del contrato depende de la diferencia. Decide el contrato: el
`422`. El parche del incidente be-11 (validar en la clausura vieja) se probó: con él, las dos rutas dan `422`.

---

## 6. Un bug que estas pruebas encontraron

El modelo `Template` de be03 declara `$primaryKey = null` (clave compuesta). Con eso, `$template->save()` sobre una fila
existente **actualiza todas las plantillas**: el `UPDATE` sale sin `WHERE`. Medido: cerrar la v2 (`PUT /templates/elevator-annual-v2`)
le ponía `validUntil` también a la v1 y a la de calderas. Arreglado con `setKeysForSaveQuery()` (clave compuesta con los
valores originales) en el modelo y en la lección be03 §5.2. `TemplateCloseTest` falla sin el arreglo (`'2026-05-31'` en la
v1) y pasa con él.

---

## 7. El ciclo

| Medida | Valor |
|---|---|
| Pruebas | 12 |
| Tiempo de la suite (`Time:` de PHPUnit), con el volumen de be05 | **217–308 ms** |
| Estrategia de limpieza | Transacción envuelta y `ROLLBACK`; savepoint en cada escritura |

---

## 8. Por qué el camino de vuelta de Lumen a Laravel no es un upgrade

Lumen no es Laravel con menos piezas: es Laravel con el arranque escrito a mano y piezas apagadas. En `bootstrap/app.php`:

- `withFacades()` sigue comentado. Encenderlo cambia el significado de `Cache::`, `DB::` y `Log::` en todo el código (be01,
  be-01, be-02).
- `withEloquent()` se encendió en be03 con conexión explícita (`config/database.php`) y `configure('database')`.
- Cada archivo de `config/` se **registra**; uno sin registrar devuelve `null` en silencio.
- Rutas con `$router->…`, middleware con `routeMiddleware`, sin `Http/Kernel.php` ni proveedores de servicios: para migrar
  hubo que registrar a mano el proveedor de migraciones, el alias de su repositorio y los comandos de consola.

Pasar a Laravel cambia a la vez el arranque, el registro de configuración y el significado de los facades. Cada uno de los
tres es un bug que be01 mostró en vivo.

---

## 9. Coste de terminar la migración, y de no terminarla

| Concepto | Valor | Origen |
|---|---|---|
| Rutas del camino viejo vivas | 2 (`GET /legacy/templates`, `POST /legacy/findings`) | Medido |
| Código del camino viejo | `LegacyTemplateController` (27 líneas) y la clausura de `/legacy/findings` (3 líneas) | Medido |
| Coste de terminar | Mover al panel heredado a `/templates` y `/findings`, y borrar las 2 rutas. Sin cifra: no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026) | Sin cifra |
| Coste de no terminar | Dos incidentes medidos que existen sólo por los dos caminos: be-03 (orden) y be-11 (500/422). Más el acoplamiento por la caché (be-01) | Medido en `CUADERNO-BE.md` |
| Migración a Laravel | no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026) (depende de la fecha de decomisión, be07) | — |
