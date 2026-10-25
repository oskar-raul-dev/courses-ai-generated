# Hallazgos candidatos · C2 (21/10/2026)

Se pasan a `prompts/verificacion-de-laboratorio/hallazgos.md` por tramo. Numeración desde H289.

## F08 · El primer despliegue

### H289 · `STEP_TAGS` llega en su estado final y la F08 pide una imagen que nadie construye 🔴

- **Dónde:** `src/lab/Taskfile.yml` (`STEP_TAGS`), F02 §4.3, F08 §4, `a03` § La matriz de generación.
- **Qué pasa:** el lector copia el `Taskfile.yml` en la F00 §4.7 con
  `STEP_TAGS: pricing:g10 inventory:g13 catalog:g10 replenish:g13 storefront:g5`, los tags del final
  del curso. Sus imágenes de G0 salen tagueadas `:g10`…`:g5`, y el manifiesto de la F08 pide
  `lab/pricing:g0`. Las dos salidas documentadas fallan:

  ```text
  $ kind load docker-image lab/pricing:g0 --name minimo
  ERROR: image: "lab/pricing:g0" not present locally
  $ task images:load -- minimo
  task: [images:load] kind load docker-image lab/pricing:g10 --name minimo
  ```

  El pod se queda en `ImagePullBackOff` para siempre: el incidente 05 deja de ser una lección de
  cinco minutos y se vuelve el estado permanente de la fase. Es sistémico de la F08 a la F12, que es
  donde los manifiestos piden el tag del paso (`src/lab/deploy/manifests/` los tiene en `:g3` y
  `storefront:g2`, el último paso antes de que Helm tome el relevo en la F13).
- **Log:** `logs/f08-apply-incidente05.log`, `logs/f08-images-load.log`.
- **Corrección:** `STEP_TAGS` es del lector y sube con cada paso de generación. La F02 §4.3 lo dice
  donde se construye por primera vez (con la salida en `:g0`, que es la que el lector ve), `a03` lo
  deja como regla de la matriz de generación, y la F08 §4 agrega el aviso con el error literal.
- **Comprobado:** con `STEP_TAGS` en `g0`, `task build:all` + `task images:load -- minimo` cargan los
  cinco `:g0` y la F08 corre entera.

### H290 · `kubectl run --attach` repite la salida y avisa que no pudo adjuntarse 🟡

- **Dónde:** F08 §5.4 y §5.7, y todas las fases que usan el pod `cliente` de un solo uso.
- **Qué pasa:** con kubectl 1.36.1 contra el nodo 1.36.4, 3 de 3 corridas imprimen la respuesta, el
  aviso `couldn't attach to pod/cliente, falling back to streaming logs: unable to upgrade
  connection: container cliente not found in pod cliente_default`, y la respuesta otra vez. En una
  cuarta corrida anterior la salida **no apareció** ninguna vez. El `curl` corre una sola vez y su
  código de salida es el correcto.
- **Log:** `logs/f08-kubectl-run-attach.log`, `logs/f08-dns-explain.log`.
- **Corrección:** entrada nueva en `a02` § Común a las tres. Las salidas publicadas se dejan: el
  comando hace lo que dice.

### H291 · La apuesta de la F08 §7: 0,60–0,69 s contra los 0,49–0,57 s publicados 🟡

- **Dónde:** F08 §7 y §9 ("un nuevo listo en 0,49–0,57 segundos").
- **Qué pasa:** cinco borrados seguidos del pod de `pricing`, del `delete` hasta otro pod con
  `Ready=True`: 0,67, 0,67, 0,60, 0,60 y 0,69 s. La apuesta (menos de 5 s, cinco de cinco) se gana
  igual y con el mismo margen; la cifra cae fuera de la variación publicada.
- **Log:** `logs/f08-apuesta.log`.
- **Corregido (21/10/2026):** la §7 lleva las dos corridas con su fecha y el arnés declarado (el de
  2026-10-21 incluye el `kubectl get` del sondeo), y la §9 pasa a 0,49–0,69 s. La conclusión no
  cambia: las dos ganan la apuesta por el mismo margen.

## F09 · Los cuatro servicios dentro

### H292 · `task deploy -- minimo` no existe todavía en la F09: el Taskfile copiado trae la versión del chart 🔴

- **Dónde:** `src/lab/Taskfile.yml` (tarea `deploy`), F09 §5.5, §8, §13 y su checklist, ejercicios 1
  y 13; `a01` § El Taskfile.
- **Qué pasa:** la F09 pide `task deploy -- minimo` cinco veces, y el `Taskfile.yml` que el lector
  copió en la F00 §4.7 trae la tarea **en su estado final**: `helm upgrade --install … charts/platform`.
  En la F09 no hay `charts/`, así que la precondición corta, y su mensaje además miente:

  ```text
  $ task deploy -- minimo
  task: Perfil desconocido: minimo. Usa minimo, lab o medicion.
  task: Failed to run task "deploy": task: precondition not met
  ```

  `a01` ya decía que «hasta la Fase 12 era `task migrate` y `kubectl apply -R -f deploy/manifests/`»,
  pero eso describe una tarea que el lector no tiene. Sin ella, además, nadie crea el `ConfigMap`
  `catalog-nginx`, y el pod de `catalog` se queda en `1/2`: justo el error que la F09 §13 diagnostica.
- **Log:** `logs/f09-task-deploy.log`, `logs/f09-deploy.log`.
- **Corrección:** la tarea `deploy` reconoce en qué parte del curso está el repositorio. Si
  `charts/platform/Chart.yaml` no existe, aplica `deploy/manifests/`: el namespace, el `ConfigMap`
  `catalog-nginx` desde `services/catalog/nginx.conf`, `kubectl apply -R` y un `wait` por los
  `Deployment` (lo que `--wait` le da al chart). Cuando el chart aparece en la F13, manda Helm y los
  manifiestos quedan de referencia. También se protegió la variable `OBS_FILE`, que corría
  `scripts/obs/switch.py` antes de que la F17 lo escribiera.
- **Comprobado:** con la tarea corregida, la F09 despliega los cinco servicios y la suite G1 pasa dos
  veces en el cluster.
- **De paso:** la F09 §8 dice que `task deploy -- minimo` recrea el sistema «en 0,6 segundos». Con el
  `wait` nuevo son **1,6 s**, porque ahora espera a que los cinco estén disponibles. Y el borrado del
  namespace tardó **42,7 s** contra los 36,2 publicados (los dos los domina la espera de 30 s de
  `replenish`).

### H293 · `task inc:break` falla: `deploy/incidents/` no está en la copia inicial 🔴

- **Dónde:** `00-el-ambiente.md` §4.7; `src/lab/scripts/incidents/inc.py`; los incidentes 07, 09, 11
  y 14.
- **Qué pasa:** C0 dejó `task inc:break|fix` como **la** forma canónica de llegar a un incidente, y
  cuatro incidentes aplican un manifiesto de `deploy/incidents/`. La F00 §4.7 enumera lo que trae la
  copia inicial —Taskfile, kind, scripts, `compose.yaml` y patrimonio— y esa carpeta no está, así que
  el primer incidente de la Parte II muere con un *traceback* de Python:

  ```text
  $ task inc:break -- 07
  subprocess.CalledProcessError: Command '[… 'apply', '-n', 'default', '-f',
    '…/deploy/incidents/07-inventory-sin-namespace.yaml']' returned non-zero exit status 1.
  ```
- **Log:** `logs/f09-inc07.log`.
- **Corrección:** la F00 §4.7 nombra `deploy/incidents/` en la copia inicial. Con la carpeta, el
  incidente 07 se rompe y se repara como dice el cuaderno.
- **Abierto para el autor:** `inc.py` deja salir el *traceback* en vez de decir qué archivo falta.
  Un `try` alrededor de `kubectl` que imprima «falta `deploy/incidents/07-…yaml`, que viene en la
  copia inicial (F00 §4.7)» sería más amable, pero toca código del curso sin que nada falle.

### H294 · Lo que reprodujo sin tocar nada (resultado positivo) 🟢

- G1 generado con los prompts de `a03` para los cinco servicios: la suite pasó **al primer intento**
  en los cinco, dos veces seguidas, en compose y en el cluster (51 peticiones, 5/5). Es lo mismo que
  dice la F09 §5.6, y por la misma razón: los prompts de G1 ya traen las tres trampas de las fases
  anteriores (driver con cgo, carpeta sin dueño, el `exec` del arranque).
- Clavados contra lo publicado: los 20 objetos de `kubectl get all -n apps`; el aviso de acceso
  nativo de Java con el mismo jar (`sqlite-jdbc-3.53.2.1`); `catalog` en `2/2` con una línea de log
  en cada contenedor; el `COUNT` que guarda la diferencia (`-3`) y la existencia en 31; el mensaje
  de error del `PATCH` de la cantidad, **palabra por palabra**; el nombre corto que no resuelve desde
  `default` y el `catalog.apps` que sí; y la apuesta del `emptyDir` (`2/2 Running 1 (10s ago)` con el
  producto vivo, y `[]` después de borrar el pod).
- Los tiempos de borrado: `replenish` 30,9 s (31,1 publicados), `catalog` 0,7 (1,0) y `pricing` 0,8
  (0,6). Dentro de la variación: se dejan.

### Pendiente de escribir al llegar a la fase

- ~~**F13**, donde aparece el chart: decir en una línea que `task deploy` cambia de modo solo porque
  `charts/platform` ya existe (H292).~~ **Escrito** al correr la F13, en la §5.4, junto con lo que
  `deploy/manifests/` pasa a ser desde entonces (la referencia de `task chart:compare`).

## F10 · La entrada al sistema

### H295 · El patrimonio no arranca en el cluster: la F10 necesita el `Secret` de la F11 🔴

- **Dónde:** F10 §6.1; `src/lab/deploy/legacy/contingencia.yaml` y `portal.yaml`; `a16` § Lo que el
  taller le agregó; F11 §6.2.
- **Qué pasa:** `deploy/legacy/` está, como todo `src/lab/`, en su estado final: los dos manifiestos
  leen el usuario y la contraseña SOAP de un `Secret` `portal-contingencia` que la **Fase 11**
  introduce. En la F10 ese `Secret` no existe, la tarea lo avisa y sigue, y los dos pods se quedan
  colgados:

  ```text
  ⚠️ falta .secrets/portal-contingencia.env: el portal no va a arrancar (Fase 11, incidente 10)
  NAME                            READY  STATUS
  contingencia-79f65c76c9-4gk6f   1/2    CreateContainerConfigError
  portal-79d5bb67d4-tdvcx         0/1    CreateContainerConfigError
  ```

  Con Contingencia caída, la §6.1 entera —la fachada, la migración de los 64 precios y el reparto de
  tráfico, que es el corazón de la fase— no se puede hacer. La F11 §6.2 dice que «el portal llegó al
  cluster en la Fase 10 con su `.env` adentro», que era cierto de los manifiestos de entonces.
- **Log:** `logs/f10-legacy-cluster.log`.
- **Corrección:** aviso ⚠️ en la F10 §6.1, antes del comando, con las dos líneas que crean
  `.secrets/portal-contingencia.env` a partir de las credenciales que el portal trae horneadas desde
  2019 (`portal` / `Vecina2019*`, `a16`). La F11 sigue enseñando el objeto y rotando la contraseña;
  lo que la F10 hace es solo darle de comer a la tarea que ya existe.
- **Comprobado:** con el archivo, `legacy` queda en cuatro pods vivos (`contingencia` en 2/2) y la
  §6.1 corre entera.

### H296 · La fachada contesta 502 si se la llama apenas el `rollout` termina 🟡

- **Dónde:** F10 §6.1 (la migración de precios).
- **Qué pasa:** `kubectl rollout status deploy/contingencia` da por listo el pod en cuanto los dos
  contenedores arrancan, pero GlassFish tarda unos 40 s más en desplegar la aplicación (el mismo
  número que mide B-00). El `Job` de migración, lanzado enseguida, imprimió **`precios migrados: 0`**
  con 64 respuestas 502 del nginx de la fachada (`connect() failed (111: Connection refused)`).
  Cuarenta y cinco segundos después, `precios migrados: 64`.
- **Log:** `logs/f10-strangler.log`.
- **Es la lección de la F15**, la misma que la F09 §5.6 cuenta con `inventory`. La F10 no la nombra y
  el síntoma es peor (el Job dice «0» y termina en éxito, con `backoffLimit: 0`). Sugerencia para el
  autor: una línea en la §6.1 diciendo que la fachada no contesta hasta que GlassFish despliega, y
  que el `Job` se relanza. **No corregido**: toca decidir si se dice en la fase o se le pone una
  espera al `Job`, y lo segundo adelanta la readiness de G4.
- **Corregido (21/10/2026):** la §6.1, paso 2, dice que hay que esperar a que GlassFish despliegue,
  qué se ve si no (64 respuestas 502 y `precios migrados: 0` **con código de éxito**) y que el `Job`
  se relanza. No se le puso espera al `Job`: eso es readiness, y la readiness es G4.

### H297 · `api.localhost` resolvió primero a `::1`, no a `127.0.0.1` 🟢

- **Dónde:** F10 §5.5.
- **Qué pasa:** la fase publica `python3 -c "…getaddrinfo('api.localhost',8080)[0][4]"` →
  `('127.0.0.1', 8080)`. Aquí devolvió `('::1', 8080, 0, 0)`; `dscacheutil` sí da las dos, igual que
  lo publicado. Todo funcionó porque kind publica el 8080 también en `::1`.
- **Log:** `logs/f10-cors.log`.
- **Corregido (21/10/2026):** la §5.5 dice que el orden de las dos direcciones no está garantizado,
  con la segunda salida y su fecha, y nombra el `Connection refused` que vería un lector cuyo cliente
  prefiera IPv6 contra un puerto publicado solo en `127.0.0.1`. La salida publicada se queda.

### H298 · Lo que reprodujo clavado en la F10 🟢

- El `Service` `LoadBalancer` en `<pending>`; cloud-provider-kind dándole IP (`172.27.0.4`, de la red
  de kind, no la `192.168.0.7` publicada) y el `curl` muriendo igual por timeout; el contenedor
  auxiliar en un puerto que elige Docker; y la `GatewayClass` `cloud-provider-kind` que deja y hay
  que borrar a mano. Todo se limpió: ni contenedores ni `GatewayClass` de más.
- El nombre del proxy (`envoy-gateway-lab-2c82546a-…`), el 404 de la puerta sin rutas, las cinco
  `HTTPRoute` con sus hostnames, `Accepted=True`/`ResolvedRefs=True`, y el `PUT` por la puerta.
- CORS: con `Origin: http://storefront.localhost:8080` llega `access-control-allow-origin`; con otro
  origen, 200 sin la cabecera.
- La fachada con `X-Contestado-Por: contingencia` y el precio **22200**, `precios migrados: 64`, y la
  apuesta del reparto: 159/41, 159/41 y 160/40 (publicado 160/40 las tres), 50/50 → 102/98 (101/99) y
  100/0 → 200. Los 200 precios iguales en todas las corridas.

### Pendiente de esta fase

- **F10 §8, la rotura del proxy en un worker**, pide el perfil `lab` (un cluster con workers). Se
  agrupa con las demás fases que lo necesitan en vez de crear el cluster dos veces.

## F11 · Configuración y secretos

### H299 · Lo que reprodujo clavado en la F11 🟢 (sin hallazgos de corrección)

Es la primera fase de C2 que corre **entera sin tocar el curso**. Lo verificado:

- **G2 generado con el prompt de `a03`**: plantilla de nginx, dos `ENV` en el Dockerfile y el `fetch`
  de `/config.json` en la página. La suite `storefront.g2.hurl` pasó al primer intento, dos veces, en
  compose y en el cluster, con la cabecera `Cache-Control: no-store` que la suite exige.
- **La misma imagen en dos ambientes** (`lab/storefront:g2` en `storefront` y en `storefront-qa`), con
  sus dos `/config.json` idénticos a los publicados, y las dos páginas en Chrome sin interfaz
  (`--headless=new --dump-dom`) **carácter por carácter** como en la fase: `Droguerías La Vecina` con
  `SKU-0001` y `SKU-0003`, y `Droguerías La Vecina · QA` con `PRODUCTO DE PRUEBA QA` / `SKU-9001`.
  `index.html` sale con `cache-control: no-cache`.
- **La apuesta de la §7**, con el pod testigo y las tres formas de entregar el `ConfigMap`:

  ```text
  t=0s   carpeta 20000 · env 20000 · subpath 20000 · pricing 20000
  t=61s  carpeta 20000 · env 20000 · subpath 20000 · pricing 20000
  t=92s  carpeta 18000 · env 20000 · subpath 20000 · pricing 20000
  t=397s carpeta 18000 · env 20000 · subpath 20000 · pricing 20000
  ```

  El archivo cambió entre los 61 y los 92 s (publicado: entre 60 y 90), la variable y el `subPath`
  nunca, y `pricing` siguió cobrando con el tope viejo los seis minutos y medio.
- **El reinicio con su sorpresa**, los dos detalles incluidos: la petición enviada mientras el pod
  viejo terminaba devolvió `upstream connect error or disconnect/reset before headers`, y el pod
  nuevo leyó el tope de 18.000 **sin ningún precio**
  (`{"error":"not_found","message":"sin precio para SKU-0003 en DRO-007"}`), porque el SQLite se fue
  con el `emptyDir`. Con el precio cargado, `{"price":18000,…,"capped":true}`.
- **El `Secret` con sus dos puntas**: el base64 publicado (`Um90YWRhLTIwMjYtMTA=`), el portal usando
  `Rotada-2026-10` con el `.env` de la imagen todavía en `Vecina2019*`, el `catalog:sync` en
  `No autorizado`, y, tras reiniciar Contingencia, `8 productos sincronizados desde Contingencia`.
  Hasta el tropiezo intermedio que la fase confiesa salió igual: el primer `catalog:sync` después del
  *rollout* murió cargando el WSDL, porque GlassFish todavía no había desplegado.
- **La rotura de la §8**: `CreateContainerConfigError`, el evento literal
  `Error: secret "portal-contingencia" not found`, Contingencia siguiendo `Running` con sus variables
  ya resueltas, y el portal listo **7 s** después de crear el `Secret` (publicado: 8).
- **Incidentes 09 y 10**, con `task inc:break|fix`: el 09 con el `ConfigMap` en 18.000 y `pricing`
  cobrando 20.000 dos minutos después, reparado al reiniciar; el 10 igual que la §8.

## F12 · Estado y almacenamiento

### H300 · B-12 remedido: los segundos bajan a la mitad, las proporciones aguantan 🟡

- **Dónde:** `BENCHMARKS.md` § B-12 y F12 §7.
- **Qué pasa:** con el arnés del curso (`task measure -- B-12 --runs 5`), en la máquina de C2:

  | 21/10/2026 | la tarea | `go test` | pasan | fallan |
  |---|---|---|---|---|
  | SQLite | 2,11 s (1,98–2,28) | 0,06 s (0,02–0,15) | 7 | ninguna |
  | Postgres con Testcontainers | 4,82 s (4,23–5,96) | 2,90 s (2,68–3,33) | 6 | `TestLargePrice` |
  | Postgres / SQLite | **2,3x** | **50x** | | |

  Los absolutos quedan fuera del rango publicado (eran 5,45 y 12,70 s; 0,10 y 6,24 s). **La
  proporción de la tarea da 2,3x, idéntica**, y la del binario 50x contra 59x: el veredicto no se
  mueve.
- **Log:** `logs/f12-b12-medido.log`, `logs/f12-b12-corridas.log`.
- **Corregido con las dos fechas** en `BENCHMARKS.md` (tabla nueva fechada, condiciones y
  "Reproducir" al día) y en la F12 §7. El veredicto pasa de "unos siete segundos" a "entre tres y
  siete, según la máquina", y la línea de la §11 también.
- **Y lo que importaba de B-12 reprodujo literal:** `TestLargePrice` falla contra Postgres con el
  mismo mensaje, hasta el OID: `unable to encode 3000000000 into binary format for int4 (OID 23):
  3000000000 is greater than maximum value for int4`.

### H301 · Lo que reprodujo clavado en la F12 🟢 (sin hallazgos de corrección)

Segunda fase seguida que corre entera sin tocar el curso.

- **G3 generado con los prompts de `a03`** en los cuatro backends: los dos motores detrás de la misma
  interfaz, las consultas escritas una vez (`$1,$2` / `?` numerados, `ON CONFLICT`, `RETURNING`) y un
  comando de migración por servicio. La suite G1 pasa dos veces en el cluster con Postgres, y sigue
  pasando en compose con SQLite.
- **El orden que importa (§5.4)**, con el mensaje publicado palabra por palabra:
  `{"error":"internal","message":"ERROR: relation \"prices\" does not exist (SQLSTATE 42P01)"}`, y el
  `Job` arreglándolo sin tocar el servicio (`migraciones aplicadas en postgres: 1`).
- **Las cuatro bases** creadas por `init.sh`, cada una con su dueño; `task platform:postgres` en
  15,6 s (11,5 publicados); la `StorageClass` `standard` con `WaitForFirstConsumer` y `Delete`, y el
  PV como carpeta dentro del nodo.
- **El seed como Job**: `sembrado: 8 productos en catalog, 160 precios en pricing (20 droguerías)`.
- **La §4 con SQLite y dos réplicas**: entraron 30 unidades y el sistema contesta **15**, siempre; el
  ajuste de −12 alterna 201 y 409 según quién conteste, y las dos réplicas devuelven el **mismo**
  `MOV-000004`, que es la prueba de que son dos almacenes distintos. (Lo publicado dice "10 o 20, y
  nunca 30"; el síntoma es el mismo y el reparto entre réplicas, otro.)
- **La §7 con Postgres**: 30 en las veinte consultas, y el ajuste de −12 en `201, 201, 409, 409`,
  exactamente como está publicado. Los datos sobreviven a borrar `postgres-0`
  (`real 1,04 s` contra 1,029 publicado) y a borrar el pod de `inventory`, con la misma existencia de
  **6**.
- **La carrera que Postgres no arregla**: veinte reposiciones de 1 a la vez, todas 201, y la
  existencia subió 2 y 10 con dos réplicas, 4 y 11 con una (publicado: 9 y 4 · 5 y 6). Mismo
  fenómeno, otros números: es una carrera.
- **El aviso de traslados como CronJob**: `schedule=* * * * *`, `concurrencyPolicy=Forbid`,
  `activeDeadlineSeconds=120`, una corrida por minuto en 3 s, y el archivo dejado en el PVC
  procesado dentro del minuto siguiente: `traslados_20261021_1658.txt: 1 traslados recibidos`, con su
  fila en la base de la Braqui.
- **Incidente 11**: `data-postgres-reportes-0` en `Pending` con la clase `oci-bv`, que en kind no
  existe, y el pod `0/1 Pending` con `pod has unbound immediate PersistentVolumeClaims`.
- **Un tropiezo propio, no del curso:** mi primer `Dockerfile` de `catalog` instaló `postgresql-dev`
  **sin** `$PHPIZE_DEPS`, y apk no pudo resolver `musl-dev` contra el `musl` de la imagen fijada. El
  Dockerfile del curso sí lo incluye y compila sin problema contra el mismo digest; comprobado
  aparte.

---

## F13 · Helm: el paquete

### H302 · Los objetos del curso llevan labels que las fases nunca muestran, y la F13 borra por selector 🔴

- **Dónde:** F09 §5.3 (`neighbors`), F10 §5.3 (la `HTTPRoute`), F11 §5.1 y §6.1 (los dos `ConfigMap`),
  F12 §5.4 (el `Job` de migraciones), y F13 §5.7, §8, §13 y el ejercicio 6, que buscan y borran con
  esas labels.
- **Qué pasa:** el `src/lab/` del curso trae en cada objeto las labels recomendadas; los fragmentos
  publicados de esas cinco fases, no. El lector que escribe lo que lee se queda con `HTTPRoute` sin
  labels, `ConfigMap` sin labels y `Job` de migraciones sin `component: migration`. En la F13 §5.7 eso
  se cobra: `kubectl -n apps delete deploy,svc,httproute -l app.kubernetes.io/part-of=lab` **no se
  lleva las cinco rutas**, y el primer `task deploy` con el chart falla con
  `Error: unable to continue with install: HTTPRoute "catalog" in namespace "apps" exists and cannot be
  imported into the current release: invalid ownership metadata…`. Lo mismo con
  `delete job -l app.kubernetes.io/component=migration`, que no encuentra nada (`No resources found`).
- **Log:** `logs/f13-mudanza.log` (la primera corrida, con el fallo).
- **Corregido** en los cinco fragmentos: `neighbors` con `part-of: lab`; la `HTTPRoute` de `pricing`
  con `name` y `part-of` y una línea diciendo que las cinco las llevan; `storefront-config` con las
  suyas; la tabla de topes de la F11 §6.1, que solo se montaba, ahora aparece como objeto con sus
  labels; y el `Job` de la F12 §5.4 con `component: migration` en el objeto y en el pod.
- **Comprobado después:** con las labels puestas, los manifiestos del lector quedan **campo por campo
  iguales** a los del curso salvo cuatro diferencias de autor (la `readOnly` del nginx de `catalog`,
  su `imagePullPolicy`, el `path` de la ruta del `storefront` y el comando de migración de `catalog`)
  y el `ResourceQuota`/`LimitRange` que agrega la F15.

### H303 · La F12 no dice qué cambia en el `Deployment` al pasar a Postgres 🟡

- **Dónde:** F12 §5.4.
- **Qué pasa:** la fase explica el `Secret`, el `Job` y el orden, y nunca muestra el cambio en el
  `Deployment`: la variable `DATABASE_URL` desde el `secretKeyRef` entra, y el `emptyDir` con su
  `DATA_DIR` —el SQLite de G1 dentro del pod, que la fase misma llama "la deuda"— sale. El `src/lab/`
  del curso los quitó; el lector que no lo adivina se queda con un volumen que nadie usa montado en
  los cuatro backends, y lo arrastra al chart de la F13.
- **Corregido** con un párrafo y el fragmento del `env` en la F12 §5.4, diciendo también que `pricing`
  conserva el volumen de la tabla de topes, que no es un almacén.

### H304 · `task deploy` en modo chart aplica un namespace que no existe hasta la F17 🔴

- **Dónde:** `src/lab/Taskfile.yml`, tarea `deploy`.
- **Qué pasa:** la rama de Helm corre
  `kubectl apply -f deploy/manifests/namespace.yaml -f platform/observability/namespace.yaml`, y
  `platform/observability/` llega en la F17. En la F13 el primer `task deploy -- minimo` del lector
  muere en el `apply`, antes de Helm. Es la misma familia de H289, H292, H293 y H295: el `src/lab/`
  publicado está en su estado final.
- **Corregido** como H292: una variable `OBS_NS` que mira si el archivo existe, y la lista con un solo
  `-f` mientras no exista. Mismo comportamiento desde la F17.

### H305 · La mudanza de la F13 §5.7 se lleva el ambiente de QA de la F11, y nadie lo repone 🟡

- **Dónde:** F13 §5.7.
- **Qué pasa:** `storefront-qa` y `catalog-qa` (F11 §5.2) también son `part-of: lab` —también en el
  `src/lab/` del curso—, así que el `delete` por selector los borra, y el chart no los instala. Sus
  `HTTPRoute` sobreviven, porque esas no llevan la label, y quedan apuntando a un `Service` que ya no
  existe: `http://storefront-qa.localhost:8080/` contesta **500** (medido: `200` con QA arriba, `500`
  sin él).
- **Log:** `logs/f13-mudanza.log`.
- **Corregido** con una línea más en el bloque (`kubectl apply -f deploy/qa/qa.yaml`) y un ⚠️ que
  nombra el síntoma.

### H306 · La apuesta de la §7 sale envuelta en un rollback fallido, porque el Taskfile ya trae la bandera de la F14 🟡

- **Dónde:** F13 §7.
- **Qué pasa:** la salida publicada es un `Error: UPGRADE FAILED: conflict occurred …` limpio, de un
  `task deploy` **sin** `--rollback-on-failure`. El Taskfile publicado ya la trae (es la regla que
  adopta la F14), así que el lector ve dos `level=WARN` más —el upgrade y **el rollback**, que choca
  con el mismo dueño— y un `Error:` anidado (`an error occurred while rolling back the release.
  original upgrade error: conflict …`), con dos revisiones en `helm history`. El conflicto, la lección
  y `task inc:fix -- 05` son los mismos.
- **Log:** `logs/f13-hash-y-conflicto.log`.
- **Corregido** con un ⚠️ en la §7 que describe la salida con la bandera, y que avisa que en
  `managedFields` hay **tres** dueños y no cuatro: el `kubectl-client-side-apply` de lo publicado es
  el rastro de la adopción de la §9, que el camino de borrar y reinstalar no deja.

### H307 · Lo que reprodujo clavado en la F13 🟢

El chart se escribió desde la fase, sin mirar el del curso, y la prueba de fuego dio **el mismo
perfil de diferencias, clase por clase y número por número**:

```text
24 objetos en el chart, 23 en el YAML plano; 117 diferencias, por campo:
   23  + metadata.labels.app.kubernetes.io/instance
   23  + metadata.labels.app.kubernetes.io/managed-by
   23  - metadata.namespace
    9  + spec.template.metadata.labels.app.kubernetes.io/instance
    9  + spec.template.metadata.labels.app.kubernetes.io/managed-by
    7  + metadata.labels.app.kubernetes.io/component
    5  + metadata.annotations.helm.sh/hook
    5  + metadata.annotations.helm.sh/hook-delete-policy
    5  - spec.ttlSecondsAfterFinished
    4  + metadata.annotations.helm.sh/hook-weight
    1  + ConfigMap/catalog-nginx (el objeto entero)
    1  + spec.template.metadata.annotations.checksum/config
    1  + spec.template.metadata.annotations.checksum/nginx
    1  + spec.template.metadata.annotations.checksum/regulated-caps
```

- **El 96 % de la §4**, contado en el repositorio de la pasada: `total 444 líneas sin comentarios; 430
  iguales a las de pricing salvo el nombre (96 %)` (publicado: 444 y 429). Y el perfil escalado a
  mano, revertido por el `apply` siguiente (medido sobre los `Deployment` de QA, que siguen siendo
  YAML plano).
- **`helm template` sin tags** falla en `storefront`, con el mensaje de `required` palabra por
  palabra: `falta storefront.image.tag: el tag del paso (task deploy lo toma de STEP_TAGS)`.
- **El aviso del enlace simbólico** del `nginx.conf`, en cada comando de Helm:
  `level=INFO msg="found symbolic link in path. Contents of linked file included and used"`.
- **El primer `task deploy` sobre los objetos aplicados** falla exactamente como lo publicado, y en el
  mismo objeto: `ConfigMap "catalog-nginx" … invalid ownership metadata; label validation error:
  missing key "app.kubernetes.io/managed-by"…`.
- **La mudanza**: `STATUS: deployed`, `REVISION: 1` en **19,45 s** (19,835 publicados) y **16,3 s de
  corte** medido con una sonda propia cada 100 ms contra `/pricing/health/ready` y `/config.json`
  (15,7 s publicados; la sonda es mía, y toma 729 muestras donde la del autor tomó 850).
- **El seed como `post-install`**, con su línea idéntica: `sembrado: 8 productos en catalog, 160
  precios en pricing (20 droguerías)`; y los cuatro hooks en orden alfabético (catalog, inventory,
  pricing, replenish).
- **El release**: `sh.helm.release.v1.lab.v1`, y `helm get values lab` con solo los cinco tags.
- **Los tres perfiles**: `minimo` 4 `ConfigMap`, 5 `Deployment`, 5 `HTTPRoute`, 5 `Job`, 5 `Service`;
  `lab` con cuatro `replicas: 2`; `medicion` sin página y sin seed.
- **El hash de la §5.5**: la circular a 18.000 reemplazó el pod sola (el viejo en `Error`, por el
  `SIGTERM` que cobra la F16), y `PUT 21900` devolvió `{"price":18000,…,"capped":true}`.
- **La rotura de la §8**, hasta los segundos: `1:33.65 total` (1:33.59 publicado), el error hablando
  del `Job` y no de la imagen, `inventory-migrate` en `ImagePullBackOff`, los dos `Events`
  (`Back-off pulling image "lab/inventory:g4"`), **ningún `Deployment` tocado** y
  `inventory/health/ready: 200`. `task deploy -- minimo` lo saca.
- **Las suites con el release**: G1 5/5 y G2 1/1 en el cluster.

---

## F14 · Helm en operación

### H308 · La memoria de la segunda cadena, medida con el patrimonio encima 🟢 (la cifra publicada se deja)

- **Dónde:** `a01` § 📏 La segunda cadena, y la apuesta de la F14 §7.
- **Qué pasa:** la medición publicada declara "sin patrimonio ni observabilidad", y esta máquina tenía
  el patrimonio de la F10 (`legacy`, 7 pods) y el ambiente de QA de la F11 corriendo. Tres corridas
  (desinstalar, 60 s, leer; instalar, 60 s, leer), en el nodo de `minimo`:

  | 21/10/2026, con patrimonio y QA | MiB |
  |---|---|
  | lo que sube la máquina virtual con la segunda cadena | 144 (105–168) |
  | máquina virtual usada con las dos cadenas | 3.168–3.208, de 3.916 |
  | `task deploy TENANT=tenant-b` hasta listo (s) | 25 (24–26) |

  Las dos primeras filas quedan fuera del rango publicado (212 MiB (191–227) y 2.831–2.901), **pero
  las condiciones no son las declaradas**: con la máquina más llena el kernel recupera caché en vez de
  pedir más, y eso baja lo que "sube". La tercera fila cae dentro (25 (23–25)).
- **Log:** `logs/f14-memoria-cadena.log`.
- **No se corrige nada:** la cifra publicada vale para sus condiciones. Lo que importaba —la apuesta de
  la §7, "menos de 400 MiB"— se gana con margen de sobra, y el aviso de `a01` sobre los 4 GiB justos
  queda confirmado: con dos cadenas, el patrimonio y QA, el nodo queda con ~700 MiB disponibles.

### H309 · Dos comandos del curso corren scripts que no están en el repositorio 🟡

- **Dónde:** F14 §5.3 (`python3 until.py 20000 60`) y F13 §4 ("El script compara…").
- **Qué pasa:** las dos salidas vienen de scripts propios del autor que no viven en `src/lab/` ni se
  describen como tales; `until.py` no aparece en ninguna otra parte del curso. El lector que copia el
  comando recibe `No such file or directory`.
- **Corregido** diciéndolo en los dos sitios: en la F14, qué hace la sonda y que un `curl` repetido
  sirve igual; en la F13, que el script es propio y no está en el repositorio (el método ya estaba
  descrito, y reprodujo el 96 %).

### H310 · Lo que reprodujo clavado en la F14 🟢 (sin hallazgos de corrección)

Fase completa sin un solo fallo del documento, y con las salidas más literales de la pasada.

- **La §4**, el cero de menos: `REVISION` nueva, `deployed`, y
  `{"sku":"SKU-0003","store":"DRO-007","price":1800,"currency":"COP","regulatedCap":1800,"capped":true}`.
- **El diff (§5.1)** mostrando el `checksum/regulated-caps` que cambia y `- SKU-0003,20000 /
  + SKU-0003,1800`; y la demostración de `--three-way-merge`: **nada** sin la bandera, y
  `- image: lab/pricing:g1 / + image: lab/pricing:g3` con ella.
- **El valor inválido (§5.2)**: el `level=WARN` palabra por palabra (`.spec.replicas: expected numeric
  (int or float), got string`), el `Error: UPGRADE FAILED: release lab failed, and has been rolled back
  due to rollback-on-failure being set`, `Rollback to 17` en 14,1 s (publicado: "veinte segundos"), y
  **los cuatro `Job` de migraciones corridos antes de volver**, que es la lección.
- **El rollback a mano (§5.3)**: `Rollback was a success! Happy Helming!` en **1,09 s** (1,234
  publicados), la sonda diciendo `tope 20000 a los 0.1 s; respuestas vistas: {'20000': 1}` —línea
  idéntica—, la revisión nueva `Rollback to N`, el precio en
  `{"price":12900,…,"regulatedCap":20000,"capped":false}`, y `values.yaml` todavía con el 1.800.
- **El esquema (§5.4)**, escrito desde cero: los dos mensajes salen como están publicados, con las
  comillas y las barras incluidas: `at '/pricing/replicaCount': got string, want integer` y
  `at '/global/hosts/api': 'api.tenant-b.example' does not match pattern '\\.localhost$'`. Y la tabla
  de capas se confirma entera: `--dry-run=server` imprime `STATUS: pending-upgrade` y `replicas: dos`
  sin quejarse, y `kubectl apply --dry-run=server --server-side` lo rechaza con el mensaje del
  servidor.
- **El perfil `medicion` (§5.5)**: los cuatro objetos del `storefront` `has been removed`, `404` en
  `/config.json`, y `task deploy -- minimo` devolviéndolo (`200`) sin volver a sembrar.
- **La segunda cadena (§5.6)**: `task platform:postgres TENANT=tenant-b` creando el namespace, los
  cuatro `Secret` y las cuatro bases `<svc>_tenant_b`; el release `tenant-b` en `apps-b` en la
  revisión 1; `sembrado: 8 productos en catalog, 320 precios en pricing (40 droguerías)`; los dos
  `/config.json` con su marca y su API; `[]` contra `DRO-040` en La Vecina y el precio 18000 en Río
  Negro. Y al desinstalar, las bases `_tenant_b` se quedan.
- **La rotura (§8)**, exacta: sin `global.hosts`, release `deployed`, rutas `Accepted=True` y la única
  pista `RouteRulesOverlap=True`; al recrear la ruta de La Vecina —que pasa a ser la más joven—,
  `http://storefront.localhost:8080/config.json` contesta
  `{"apiBaseUrl":"http://api.localhost:8080","brandName":"Droguerías Río Negro"}`: los clientes de La
  Vecina viendo la página de la otra cadena. Con los hosts puestos, el diff anuncia los `hostnames`,
  los `allowOrigins` y el `API_BASE_URL`, y las rutas de `apps` vuelven a tener solo dos condiciones.
- **Kustomize (§5.7)**: el mismo `kustomizeVersion: v5.8.1` del `kubectl` de la verificación, el mismo
  error de `security; file … is not in or below …` y, con `--load-restrictor LoadRestrictionsNone`,
  los tres objetos con `replicas: 2`.

### Pendiente de esta fase

- **F14 §5.5, el perfil `lab` en su cluster de tres nodos** (y la suite con `PROFILE=lab`): pide bajar
  `minimo` y subir `lab`, porque los dos publican el 8080 del host. Se agrupa con la F10 §8 y con lo
  que pida workers más adelante, para no crear el cluster dos veces.

---

## F15 · Salud y recursos

### H311 · La cuota de la §5.5: el fragmento dice 20 pods, su propio `describe` dice 15, y el archivo publicado trae 25 🟡

- **Dónde:** F15 §5.5 y `src/lab/deploy/manifests/namespace.yaml`.
- **Qué pasa:** tres números para el mismo campo. El fragmento que el lector copia dice `pods: "20"`,
  el `describe resourcequota` de la misma sección muestra `pods 5 15`, y el `namespace.yaml` del
  repositorio trae `requests.memory: 1536Mi`, `limits.memory: 3Gi`, `pods: "25"`, que son los de la
  F16 (dos réplicas por backend en el perfil `lab`).
- **Corregido:** la columna `hard` del `describe` pasa a 20, que es lo que produce el fragmento, y un
  📝 dice que el archivo del repositorio ya trae los números de la F16 y que cualquiera de los dos
  juegos sirve para `minimo`.
- **Medido con el fragmento de la fase:** `requests.memory 576Mi` **idéntico al publicado** —la suma
  de los recursos que medí por mi cuenta cayó en los mismos números— y `limits.memory 1Gi` contra
  896Mi, que son los 128 MiB que el `LimitRange` le pone a los dos pods del ambiente de QA.

### H312 · Contingencia ya nace `Burstable`: el `deploy/legacy/` publicado trae los recursos de la F15 🟡

- **Dónde:** F15 §5.4.
- **Qué pasa:** la sección cuenta que Contingencia y Postgres eran `BestEffort` y "pasan ahora a
  `Burstable`". Postgres sí: su `StatefulSet` lo escribió el lector en la F12 y nace sin recursos. Pero
  `deploy/legacy/` se copia del curso en la F00 **con los números ya puestos**, así que en el cluster
  del lector Contingencia, su base, el portal y la Braqui son `Burstable` desde la F10, y la tabla de
  `BestEffort` de la sección no se puede reproducir. Es la misma familia de H289, H292, H293, H295 y
  H304.
- **Log:** `logs/f15-qos-antes.log` (los cuatro del patrimonio ya `Burstable`), `logs/f15-qos-y-cuota.log`.
- **Corregido** con un paréntesis en la §5.4 que lo dice y deja claro qué le toca escribir al lector.

### H313 · Lo que reprodujo clavado en la F15 🟢

G4 generado desde los prompts de `a03` en los cuatro backends, y las sondas, los recursos y las cuotas
escritos desde la fase. Lo que salió igual:

- **La suite de G4**, los cuatro archivos a la primera (`pricing`, `inventory`, `replenish`, `catalog`,
  3 peticiones cada uno), y la de G1 en verde con el release.
- **El problema de la §4**, con mi propia sonda (una petición cada 100 ms por la puerta y un `rollout
  restart` a los 3 s): sin sondas, **1,6 a 3,3 segundos de corte** en cada despliegue y entre el 0,6 %
  y el 4,1 % de peticiones perdidas (publicado: 1,3–1,5 s y 2,8–3,3 %). Con la readiness de G4,
  **0, 1 y 1** peticiones perdidas en tres corridas (publicado: 0, 1, 0).
- **La readiness decidiendo el tráfico del `Service` (§5.2)**, provocada con el incidente 15: el
  endpoint en `ready=false`, la conexión por el `Service` **rechazada** desde otro pod (`curl` sale con
  7), `/pricing/health/live` contestando **200** por la puerta todo el tiempo y `/pricing/prices`
  contestando **500** con el error de la base en el cuerpo. Y al volver la base, los cuatro a `1/1` en
  menos de 25 s.
- **La memoria por contenedor**, medida en el nodo con `crictl stats`, en reposo y con veinte usuarios
  un minuto: `pricing` 3→13 MiB (publicado 6→13), `inventory` 194→227 (216→250), `catalog` 31→39 y su
  nginx 7→7 (31→56 · 7→10), `replenish` 35→39 (31→63), `storefront` 8→8 (7→7). Los `requests`/`limits`
  del chart salieron los mismos del curso (32/64, 384/512, 64/128 · 16/32, 64/128, 16/32), y la suma
  da los 576 MiB publicados.
- **El límite de CPU (§5.4)**, con veinte usuarios contra `pricing`: **1.378 peticiones/s y p95 de
  46,7 ms sin límite** —dentro de lo publicado (1.126–1.392 y 46–60 ms)— contra **32,7 peticiones/s y
  p95 de 1,69 s con `limits.cpu: 50m`** (publicado 39–61 y 1,39 s): 42 veces menos, con el nodo
  ocioso.
- **La apuesta de la cuota (§7)**: `kubectl -n apps-b scale deployment/inventory --replicas=3` dejó el
  `Deployment` en `2/3` y el evento salió con los mismos números del curso, campo por campo:
  `exceeded quota: apps-b, requested: limits.memory=512Mi,requests.memory=384Mi, used:
  limits.memory=1536Mi,requests.memory=960Mi, limited: limits.memory=1536Mi,requests.memory=1Gi`. Y La
  Vecina, mientras tanto: 354 peticiones, **ninguna sin 200**.
- **Los cuatro incidentes**, los cuatro con su síntoma publicado:
  - **12**: `CrashLoopBackOff` con `OOMKilled` y `Exit Code: 137`, y el pod viejo atendiendo.
  - **13**: `replenish` en `Running 0/1`, **sin reinicios**, y 500 por la puerta.
  - **14**: con su propia carga (`deploy/incidents/14-carga-catalog.js`, 400 usuarios), los reinicios
    de **nginx** creciendo (1, 3, 4) con `php-fpm=0`, y `http_req_failed: 99,27 %` (99,53 publicado).
  - **15** (que es la rotura de la §8): `postgres-0` en `Pending` con
    `0/1 nodes are available: 1 Insufficient memory`, y los cuatro backends en `0/1` —`catalog` en
    `1/2`, como en la salida publicada—. `task inc:fix -- 15` devolvió todo en 25 s.
- **El tiempo hasta listo (§6)**: `catalog`, `pricing` y `storefront` 1–2 s (con un 6 s suelto de
  `pricing`), `replenish` 2–5 s, `inventory` **6–8 s** (publicado 3–5). Y la primera petición después
  de estar listo, cinco seguidas: `pricing` 0,0059 → 0,003; `inventory` 0,0055 → 0,004; `catalog`
  0,018 → 0,014 (publicado: 0,021/0,073/0,026 la primera, y el mismo orden entre los tres).

### Pendiente de esta fase

- **Las otras dos apuestas de la §7** no se volvieron a correr: la del `-Xmx4096m` con carga sostenida
  de cinco minutos (su conclusión publicada es que el `-Xmx` **no** mata, y lo que mata —el `-Xms` con
  `AlwaysPreTouch`— es exactamente el incidente 12, que sí corrió), y la del AOT cache de la JVM, que
  es del bloque 🔥 de la §6.1 y va con los apéndices opcionales.

## F16 · Escalado y rollout

### H314 · Mi chart de la F15 dejaba a `php-fpm` sin `resources`, y el `LimitRange` lo tapó 🔴 (error de la pasada, no del curso)

- **Dónde:** `charts/platform/charts/catalog/templates/deployment.yaml` del repositorio de la pasada, escrito en
  la F13 y retocado en la F15.
- **Qué pasaba:** el contenedor `nginx` traía dos bloques `resources:` (el de `.Values.resources` y el de
  `.Values.nginx.resources`; en YAML gana el último) y `php-fpm` ninguno. Al no declarar nada, el `LimitRange`
  del namespace le puso sus valores por defecto: 64 MiB de `requests` (los mismos del chart publicado, por eso
  el 576 MiB de la F15 salió idéntico) y **256 MiB de `limits` en lugar de 128**.
- **Lo que explica:** el H311 atribuyó la diferencia entre `limits.memory 1Gi` y 896Mi a «los 128 MiB que
  el `LimitRange` le pone a los dos pods de QA». Eran los 128 MiB de más (256 − 128) de `php-fpm`. Esa
  explicación del H311 era falsa y queda corregida aquí; el curso no cambia por esto, porque el chart
  publicado está bien.
- **Corregido en la pasada:** `php-fpm` con `.Values.resources`, `nginx` con `.Values.nginx.resources` y los dos
  con el `preStop` (que es lo que el chart publicado hace). Lo encontré al copiar el cambio de la F16 a los
  cinco `Deployment` y ver el bloque duplicado.
- **Lección de método:** una cuota que da *igual que la publicada* no prueba que el objeto sea igual; el
  `describe` del pod habría dicho `php-fpm {}`.

### H315 · La F16 no entrega `bench/b16/rate.js`, que ella misma necesita 🟡

- **Dónde:** F16 §5.2, §5.4 y §8; `scripts/measure/measure.py` (B-16).
- **Qué pasa:** el rollout con carga, el HPA y B-16 corren k6 contra `bench/b16/rate.js`. El archivo no
  está en la copia inicial (`bench/` trae solo directorios de resultados) y ninguna fase lo muestra: el
  lector que sigue la fase no tiene con qué cargar.
- **Corregido:** F16 §8.1 trae el script completo (15 líneas) y dice que sirve a las tres pruebas.

### H316 · La F16 muestra el YAML pero no dice dónde vive ni cómo se enciende 🟡

- **Qué pasa:** §5.2–§5.4 enseñan los fragmentos (`preStop`, `strategy`, el `patch` de metrics-server),
  pero no dicen que son tres plantillas de `lab-common` (`deploymentSpec`, `shutdown`, `hpa`) ni los
  bloques de valores (`rollout`, `shutdown`, `autoscaling`) que cada subchart necesita, ni el
  `terminationGracePeriodSeconds`. Un lector que escribe el chart tiene que inferirlo.
- **Corregido:** un párrafo en §5.4 que lo nombra. Los helpers los escribí desde el chart publicado;
  el texto sigue sin traer su código completo (decisión de alcance: el chart publicado es la referencia).

### H317 · `platform/metrics-server/components.yaml` no está en la copia inicial, y la primera imagen tardó más de diez minutos 🟡

- **Qué pasa:** `task platform:metrics` aplica un archivo que la fase dice «guardado en
  `platform/metrics-server/`», pero que el lector no tiene. Lo bajé de la release v0.9.0 y fijé la imagen por
  digest: salió **idéntico al publicado** salvo cuatro líneas de comentario.
- **Observado:** los dos pods nuevos se quedaron en `ContainerCreating` (`Pulling`) más de diez minutos; la
  imagen a mano (`docker exec lab-worker crictl pull`) tardó segundos. El `rollout status` de la tarea
  venció a los 180 s sin que `task` avisara de nada más. Sin causa clara; se anota para el lector.
- **Corregido:** nada; queda como aviso. Si el curso quiere evitarlo, `task platform:metrics` podría hacer
  `kind load docker-image` de la imagen, como las del sistema.

### H318 · Con la cuota de la F15, el perfil `lab` no despliega: es lo que la F16 §6 anuncia 🟢 (reproducido)

- Primer `task deploy -- lab` con `requests.memory: 1280Mi / limits 2Gi`: `Error creating: pods "seed-…" is
  forbidden: exceeded quota: apps, requested: limits.memory=256Mi, used: limits.memory=1888Mi, limited: 2Gi`,
  Helm espera diez minutos al hook y desinstala (`--rollback-on-failure`). Con 1536Mi / 3Gi, instala.
  El curso dice 1696Mi usados en el momento de su rollout; el mío, 1888Mi, con todo desplegado (ya con el
  `php-fpm` corregido de la H314: son momentos distintos, no una discrepancia).
  El texto de la §6 es correcto.

### H319 · `inc:break -- 17` no rompe nada sobre un metrics-server ya parchado, y no enciende el HPA 🔴

- **Dónde:** `scripts/incidents/inc.py`, incidente 17 (también en el `src/lab/` publicado).
- **Qué pasaba:** el `break` solo hacía `kubectl apply` del manifiesto sin el flag. Sobre el `Deployment`
  que `task platform:metrics` ya había parchado, el pod viejo seguía listo y servía métricas mientras el nuevo
  se quedaba en `0/1`: `kubectl top` contestaba y no había HPA, o sea, nada de lo que el cuaderno promete ver.
- **Corregido** (en el `inc.py` publicado y en el de la pasada): borra el `Deployment` primero, aplica el
  manifiesto, y hace `helm upgrade --reuse-values --set pricing.autoscaling.enabled=true`. Con eso, a los 100 s:
  `cpu: <unknown>/70%`, `error: Metrics API not available`, `0/1 Running` y el `x509: cannot validate
  certificate for 172.27.0.4 because it doesn't contain any IP SANs`. El cuaderno lo dice ahora en «Cómo llegar».
- **Efecto lateral del `fix`:** `inc:fix -- 17` deja metrics-server bien y el HPA encendido (el cuaderno
  describe justo eso: «el HPA muestra `cpu: 2%/70%`»); un `task deploy FORCE=true -- lab` lo retira.

### H320 · Lo que reprodujo en la F16 🟢, y lo que no

- **G5 a la primera** en los cinco servicios (suite G5 en el cluster: 9 peticiones, y el log
  `aviso a replenish: RO-0001 para SKU-0002 en DRO-021 (quedan 4)`). Las suites G1, G2 y G4 siguen en verde.
  Observaciones de la generación: en Spring Boot 4 `JsonNode` es `tools.jackson.databind`, no
  `com.fasterxml…` (el prompt solo avisa del `RestClient.Builder`); y **la suite G5 no corre en compose**,
  porque el `catalog` de compose solo conoce `SKU-0101`: pide el seed, y el seed es del cluster. Ya lo dice la
  fase (`TARGET=cluster`), pero a03 dice «su suite es `inventory.g5.hurl`» sin decir dónde.
- **La carrera de la F12, cerrada:** 5 de 5 veces `{201: 20}; después: 20`.
- **La página:** `Venta SALE-000003: $12.900.` (el id cambia con el estado de la base, el monto es el publicado).
- **El rollout con carga** (200 req/s, `restart` a los 8 s, 4.000 peticiones, 3 corridas por caso): sin `preStop`,
  `:g4` 21 · 20 · 26 y `:g5` 16 · 33 · 18 fallidas (publicado: 30 · 18 · 39 y 25 · 29 · 24); con `preStop` de
  5 s, **0 en las seis corridas**. La tabla de la fase se deja. Un error mío: el primer intento del `preStop`
  usó `--type=merge` y reemplazó la lista de contenedores; esas dos filas se repitieron.
- **El HPA con 1.500 req/s y 128 MiB:** pidió réplicas a los **31 s** y estaban listas a los 37 (publicado
  32–37 y 37–48), cuatro réplicas; perdió el 9 % de las peticiones mientras llegaban. `catalog` a 400 req/s
  pidió a los 15 s (publicado 31) y `replenish` a los 31 s; `catalog` quedó en p95 531 ms contra los
  1,65 s publicados (una sola corrida; la variación de `catalog` en B-16 es de 20 a 218 ms): no se cambia el
  texto.
- **Lo que NO reprodujo:** el `OOMKilled` con 64 MiB (dos corridas: sondas fallidas y, en una, reinicio por
  liveness con `Exit Code: 0`; el efecto, el HPA ciego y 40–54 % de fallos, sí). §4 y §9 lo dicen ahora.
  Tampoco «con tres réplicas, `catalog` empeora» (B-16, dos corridas completas: 19–35 ms con tres): corregido
  en §8 y en `BENCHMARKS.md`. La proporción de memoria `inventory`/`pricing` varió entre 5 y 21; el 7,4
  publicado está dentro y se deja. B-16 en `bench/b16/results/` (dos JSON).
- **Los incidentes 16 y 17:** el 16 tal cual (síntoma, `Progressing=False ProgressDeadlineExceeded`, `password
  authentication failed for user "inventory"`), salvo que el plazo venció a los 2 minutos y no a los 16 que la
  solución menciona; el 17, tras la H319, tal cual.

### Pendiente de esta fase

- Las otras mitades del bloque 🔥 de la §6.1 (AOT de la JVM) y la `PodDisruptionBudget` del ejercicio 22 no se
  corrieron en esta tanda; los 24 ejercicios no se recorrieron uno a uno (los de la fase repiten lo medido).

## F17 · Métricas y tableros

### H321 · Los prompts de G6 de `pricing` y `catalog` dan por hecho un envoltorio de log que ningún prompt anterior pide 🟡

- **Dónde:** a03, G6 · pricing («el mismo envoltorio que ya escribe la línea de log») y G6 · catalog
  («`MeasureRequest`, agregado después de `LogRequest`»).
- **Qué pasa:** el G0 de la pasada (generado con los prompts de a03) escribe la línea de log dentro de
  `writeJSON` en `pricing` y no tiene ningún middleware en `catalog`: el de G0 solo pide «los logs, a
  `stderr`». El autor tuvo un `LogRequest` porque su generación lo inventó, no porque el prompt lo pidiera.
- **Efecto:** ninguno grave (escribí el envoltorio de `pricing` y un `MeasureRequest` global en `catalog`),
  pero el prompt se refiere a algo que el lector puede no tener, y el G7 de `catalog` vuelve a nombrar
  `LogRequest`.
- **Corrección propuesta:** en los dos prompts de G6, «el envoltorio de log, si ya existe; si no, uno nuevo
  alrededor del mux / un middleware global».

### H322 · Los interruptores de medición de la F17 (`METRICS_URI=raw`, `METRICS_STORAGE=memory`) no están en los prompts de G6 🟡

- **Dónde:** F17 §6 y §9 (la autopsia: «la imagen de `pricing` trae un interruptor solo para medir esto»), a03 G6.
- **Qué pasa:** la fase mide las dos roturas con variables de entorno de la imagen, pero el prompt de G6 no
  las pide: un lector que genera con el prompt no tiene con qué reproducir la §6 ni la §9 sin reconstruir la
  imagen. Las agregué a mano.
- **Corrección propuesta:** una línea en cada prompt (pricing: `METRICS_URI=raw` etiqueta con la ruta cruda,
  solo para la autopsia; catalog: `METRICS_STORAGE=memory|apcu`, `apcu` por defecto).

### H323 · G6 a la primera en los cuatro, y el `/metrics` por la puerta 🟢

- `task conformance TARGET=cluster PROFILE=lab -- G6`: 4 de 4 (8 peticiones). Las cuatro imágenes
  construyeron a la primera; `@prometheus-io/client` resolvió a `^0.16.1`, la misma versión publicada.
- El `curl` de la §5.2 da las mismas series (`/prices` 200, `/prices/{sku}` 404, `/**` 404, `/health/ready`);
  con dos réplicas los conteos se reparten. `inventory` trae `error`, `exception` y `outcome`, como dice §6.
- **Al pie:** la primera suite falló por cuota (`exceeded quota: apps, requested: requests.memory=64Mi, used:
  1520Mi, limited: 1536Mi`) porque corrió con los pods viejos del rollout todavía terminando; veinte segundos
  después, `used: 1136Mi` y la suite pasó. No es del curso, pero un lector con el perfil `lab` puede verlo.
- El primer `task deploy` chocó con `kubectl-set` (un `set image` de mis pruebas de la F16): `FORCE=true`, como
  dice la F13.

### H324 · La fase no trae los subcharts de Prometheus y Grafana, ni `la-vecina.js`, ni el namespace `observability` 🟡

- **Dónde:** F17 §4, §5.3, §5.4 y §17.
- **Qué pasa:** la fase muestra el corazón del `scrape_config`, el aprovisionamiento y dos consultas, pero no
  los archivos completos: `charts/prometheus/` (6 archivos), `charts/grafana/` (5, con el JSON del tablero de
  314 líneas), `platform/observability/namespace.yaml`, el namespace `observability` en el `allowedRoutes` de la
  puerta (§17 lo nombra) y `bench/trafico/la-vecina.js` (§4 lo nombra). Los traje del `src/lab/` publicado, como
  los helpers de la F16 (H316).
- **Corrección propuesta:** una línea en §5.3 que diga que los subcharts completos están en el `src/lab/` del
  curso y que el lector los copia (es la misma decisión de alcance de la H316); `la-vecina.js` cabe entero en
  §4 (46 líneas, o sus 15 de lógica).

### H325 · Después de pasar a `minimo` (§5.5), `task obs:on|off` vuelve a desplegar con los valores de `lab` 🔴

- **Dónde:** F17 §5.5 («Desde aquí, la fase corre en el cluster `lab` con los valores de `minimo`») y todo lo
  que sigue: §8 («`task obs:off -- all`, y `task obs:on` con cada pieza»), el ejercicio 2, §13.
- **Qué pasa:** `obs:on` y `obs:off` llaman a `deploy` con `PROFILE` por defecto `lab`. Tras `task deploy
  CLUSTER=lab -- minimo`, un `task obs:off -- dashboards` corre `helm upgrade … -f values-lab.yaml` y devuelve el
  sistema a **dos réplicas por servicio**: justo lo que la §5.5 acaba de decir que ahoga la máquina virtual.
  Log: `logs/f17-obs-off-sin-perfil.log`.
- **La forma que funciona:** `task obs:on PROFILE=minimo CLUSTER=lab -- dashboards` (log
  `f17-obs-on-con-perfil.log`): `values-minimo.yaml` y una réplica.
- **Corrección:** en §5.5, después del `task deploy CLUSTER=lab -- minimo`, decir que los interruptores llevan
  el mismo perfil, y usar esa forma en §8 y en el ejercicio 2. (Alternativa en `src/lab/`: que `obs:on|off`
  recuerden el perfil del último `deploy`; es más cambio y pide probarlo.)

### H326 · La sexta entrega de B-00, sin el Kubernetes de Docker Desktop: Grafana ocupa más, y la columna de la VM ya tiene número 🔴

- **Condiciones:** cluster `lab` con `minimo`, VM de 4 GiB sin el Kubernetes de Docker Desktop (borrado en C1),
  3 ciclos `obs:off all` → `obs:on metrics` → `obs:on dashboards`, lectura a los 60 s con `kubectl top` y
  `MemTotal − MemAvailable` del nodo (`b00-obs.sh`, log `f17-b00-sexta.log`). Los 20 minutos con
  `la-vecina.js` a 2/s, tras reiniciar los dos pods (`f17-trafico-20min.log`).
- **Resultados:** Prometheus sola 60 (59–70) contra 44 (43–73) publicado; con Grafana 68 (59–70) contra 58
  (52–90); **Grafana 269 (260–312) contra 252 (248–254)**: fuera de la variación. A los 20 minutos, Prometheus
  72 (publicado 99) y **Grafana 347 (publicado 231)**. La VM: Prometheus no se distingue (−15 a +78 MiB),
  Grafana suma 168 (103–207).
- **Corregido** (decisión por defecto del plan: fuera de la variación, se corrige con la máquina declarada):
  la tabla de la F17 §8 y la de `a01`, con las dos fechas; la columna de la VM, nueva; el párrafo «Falta una
  columna» y el «Pendiente» de `a01`, reemplazados. La apuesta 1 de la §7 pasa de «empate» a «empate, y ganada
  al remedirla» (Grafana 347 > 300). **H155 queda cerrado entero.** Loki y Fluent Bit siguen con su cifra
  del 04/10 hasta la F18.

### H327 · Lo que reprodujo en la F17 🟢

- **Los blancos:** doce `up` con el perfil `lab` (ocho backends, tres cAdvisor, Prometheus), sin escribir una IP.
- **El tablero** a 3 visitas/s, cuatro minutos (`tablero.py`, las consultas del JSON por la API): peticiones
  pricing 3,58 · catalog 3,49 · inventory 0,644 (publicado 3,51 · 3,64 · 0,644); 0 % de 5xx; p95 pricing
  **4,75 ms, idéntico**, catalog 23,7 (24,5), inventory 37,9 (87,0); ventas por minuto 25,4 (28,8); memoria
  inventory 205, replenish 53, catalog 42, pricing 21, storefront 7,3. Se deja.
- **APCu (§6):** `METRICS_STORAGE=memory`, ninguna línea con `uri="/products"`; con APCu, **200 de 200**. Idéntico.
- **La autopsia (§9):** 2.000 SKU, series de `pricing` 137 → 25.211 (**×184**, publicado ×228), totales
  1.982 → 27.195, heap de Prometheus 44 → 93 → **109 a los 5 min** (+150 %, publicado +165 %). La apuesta
  (×100 y +50 %) gana igual; los números quedan dentro de lo que la sección afirma y se dejan.
- **No repetidos:** la apuesta del p95 con G6 (la fase la dejó «sin decidir») y la del contador que vuelve a
  cero (ejercicio 14). Los 24 ejercicios no se recorrieron uno a uno.

### H328 · `la-vecina.js` hace diez visitas por segundo sin `RATE`, y la §4 dice tres 🟢

- La §4 cita el script con «tres visitas por segundo» sin decir `-e RATE=3`; el script, sin `RATE`, hace 10
  (lo que en la §5.5 ahogó la VM). **Corregido** en la §4, junto con la procedencia de los subcharts (H324):
  un párrafo en §5.3.

### H329 · `FORCE=true` no borra lo que `kubectl set env` agregó: el `METRICS_URI=raw` de la autopsia sobrevivió al `deploy` 🟡

- **Qué pasó:** para la autopsia de la F17 §9 puse `METRICS_URI=raw` con `kubectl set env` y después corrí
  `task deploy FORCE=true`. En la F18, la línea de `pricing` traía `"uri":"/prices/SKU-0004"`: la variable
  seguía ahí. `managedFields`: `kubectl-set` dueño de esa entrada del `env`, que el chart no tiene.
- **Lo que dice el curso:** la F13 lo explica para el selector del incidente 06 («Helm no borra campos que no
  son suyos»), pero `a04` («`kubectl scale` o `kubectl set` … despliega con `FORCE=true` después») lo da por
  deshecho.
- **Corregido:** `a04`, con la diferencia entre un campo en conflicto y uno que el chart no tiene, y cómo
  quitar la variable (`kubectl set env … NOMBRE-`).

## F18 · Logs

### H330 · G7 a la primera en los cuatro, con el verificador en `ok` 🟢

- `task conformance TARGET=cluster PROFILE=lab -- G7`: 4 de 4 suites y `pricing 13 · inventory 24 · catalog 20
  · replenish 24 líneas · ok` (log `f18-g7.log`). Las cuatro imágenes a la primera. En `inventory`, la clave con
  corchetes de la §6 tal cual; en `catalog`, `log_level = warning` va en una sección `[global]` del archivo del
  pool (el prompt no dice dónde, y en `[www]` no vale).
- **El `request_id` (§5.3):** la venta con `X-Request-Id: venta-de-prueba-f18` llegó a `inventory` con un UUID
  de Envoy (reemplazado, como dice la fase) y el mismo id en `catalog` (nginx y Laravel) y `pricing`. Sin aviso a
  `replenish` (la existencia no bajó del umbral), así que cuatro líneas y no seis.
- **El log a archivo (§5.1):** con `LOG_CHANNEL=stack`, 0 líneas en la salida, `laravel.log` de 188.613 bytes y
  1.004 líneas (1.000 más las sondas); publicado 186.899 y 1.000.
- **Fluent Bit:** dos pods, en los dos workers; el control-plane no lo tolera (§5.4).
- **LogQL:** `{namespace="apps"} | json | request_id="…"` encuentra la venta; 6 flujos en Loki, uno por contenedor.

### H331 · Lo que cuestan los logs (§8) y la autopsia (§9): reprodujeron 🟢

- **Diez minutos a 2 visitas/s** (`logs-costo.sh`, `f18-costo.log`): **5.879 líneas y 1.317.760 bytes, 6 flujos**
  (publicado 5.853, 1.294.360, 6). Memoria: Fluent Bit 6 y 13 MiB (5,6 y 5,6), Loki 98 (91,4), Grafana 227 (210),
  Prometheus 151 (106; guardaba todavía las 27.000 series de la autopsia de la F17, no compara). Dentro de la
  apuesta (< 20 MiB por Fluent Bit, < 150 Loki).
- **Dos minutos de reposo:** 256 líneas y 55.407 bytes (publicado 253 y 54 KB), **180 sondas (70 %) y 40
  scrapes (16 %)**, idéntico, contando también las líneas de nginx (que traen `path` y no `uri`).
- **La autopsia:** con `request_id=$request_id` en las etiquetas y 5 minutos a 5/s, **4.850 flujos** (publicado
  5.001), Loki 99 → 149 MiB (90 → 145), 547 y 133 errores de Fluent Bit (589 y 727), el `maximum active stream
  limit exceeded` y el `cannot be retried` literales. Perdidas en siete minutos: catalog 1.422 de 1.858 (23 %),
  pricing 1.401 de 1.787 (22 %), inventory 400 de 466 (14 %); `replenish` no tuvo peticiones. «Cerca de una de
  cada cuatro», en dos de tres. Se deja.
- **No repetido:** la vuelta con cinco minutos del mismo tráfico (6 flujos, 0–3 %); los 20 ejercicios no se
  recorrieron uno a uno. Los `task obs:on -- logs` de la §5.4 y del ejercicio 2, corregidos con el perfil (H325).

## F19 · TLS y certificados

### H332 · La F19 por terminal, con la CA del llavero: `security verify-cert` valida y `curl` entra sin `--cacert` 🟢

- **Cómo:** la pasada usa la CA del `src/lab/` del curso (copiada a `mi-lab/.secrets/tls/`), que es la que el autor
  instaló en el llavero `login` el 05/10 (H270): así se prueba sin instalar otra raíz. `task tls:ca` no la pisó.
- **Resultados:** `security verify-cert -c gateway.crt -p ssl -s api.localhost` → `certificate verification
  successful` sin ancla explícita; `/usr/bin/curl` (SecureTransport) **sin `--cacert`** → 200, porque lee el
  llavero. El `(60) unable to get local issuer certificate` de la §5.2 sale igual desde un contenedor sin la CA.
- **Para el curso:** la §5.2 muestra el (60) sin `--cacert` antes de instalar la CA; en una máquina que ya la tiene
  en el llavero, el mismo comando da 200. No es un error (la §5.3 viene después), pero un lector que repite la fase
  lo va a ver. Corrección propuesta: una línea en la §5.2 («si ya instalaste la CA en el llavero, el `curl` de macOS
  la usa y entra»). Lo que sigue sin verificar es el navegador (O1) y la desinstalación (O2): son del autor.

### H333 · Lo que reprodujo en la F19 🟢

- **Antes de TLS:** `curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL`, literal.
- **El certificado de la puerta:** los seis nombres del SAN, literales; con `--cacert`, 200.
- **cert-manager y trust-manager** en 32 s (`task platform:certs -- lab`): el `Certificate` tomó el `Secret` en un
  segundo, con otro texto en el evento (`Issuing certificate as Secret was previously issued by
  "Issuer.cert-manager.io/"`, no `Existing issued Secret is not up to date for spec`); `lab-ca` en `apps`, `data` y
  `observability`, los tres.
- **La renovación con tráfico:** serial nuevo servido a las 03:11:36 UTC, **el mismo segundo** de
  `renewal was scheduled at 03:11:36`; **2.364 peticiones, 0 fallidas**; reinicios del proxy 0 0 antes y después
  (publicado 2.226 y 0; `renovacion.py`, log `f19-renovacion.log`).
- **G8 a la primera** (`inventory.g8.hurl`, 3 peticiones), con `pricing escuchando con mTLS en :8443` y la línea
  `g8-conformance-venta`. Sin certificado de cliente: `(55) … tlsv13 alert certificate required` (publicado: 56) y
  el `WARN` `tls: client didn't provide a certificate`, sin línea `request`.
- **El registry:** `InsecureRegistryCIDRs [::1/128 127.0.0.0/8]`; el pull desde un nodo, `x509: certificate signed
  by unknown authority`; `task registry:trust -- lab` en 0,7 s (publicado 1,1).
- **La trampa del kubelet, reproducida:** con el pull hecho por el kubelet desde `lab-registry` en `lab-worker2`,
  `lab/pricing:g8` (mismo digest) dio `pull access denied` en ese nodo; el `ImagePulledRecord` literal
  (`credentialMapping: lab-registry:5000/lab/pricing`); borrar el registro no alcanzó; reiniciar el kubelet, sí.
  **Matiz:** en `lab-worker` no pasó, porque ahí la imagen del registry la trajo `crictl pull` y no el kubelet: el
  registro lo escribe solo el kubelet. La fase podría decirlo.
- **Los incidentes 18–23, con su síntoma literal** (`inc-19.sh`, `f19-incidentes.log`): 18, 200 recién puesto y a
  los 130 s `certificate has expired`, sin `Certificate`, el listener en `Programmed=True Accepted=True
  ResolvedRefs=True`; 19, `unable to get local issuer certificate`; 20, `api` en 200 y `no alternative certificate
  subject name matches target host name 'storefront.localhost'`; 21, `SSL_ERROR_SYSCALL`, `ResolvedRefs=False` y
  `tls: private key does not match public key`; 22, `pricing-tls False` con `Issuing certificate as Secret does not
  exist` y el pod en `ContainerCreating`; 23, `(certificate_required) Received fatal alert: certificate_required`.
  Los seis `fix`, a 200 o a la venta.
- **El costo (§8):** medianas con mTLS 22,5 · 23,6 · 23,4 ms y sin él 22,8 · 23,4 · 22,8, 0 fallidas en 1.803
  ventas (publicado 24,7–26,9 y 25,5–26,0): la misma conclusión. cert-manager y trust-manager: 47 + 29 + 25 + 43 =
  **144 MiB** (publicado 134; la apuesta, < 150).

### H334 · El incidente 24 no rompía después de la §5.7, y su `fix` dejaba el siguiente `deploy` colgado 🔴

- **Dónde:** `inc.py` (incidente 24) y `Taskfile.yml` (`registry:untrust`), también en el `src/lab/` publicado;
  cuaderno, incidente 24.
- **Primera cara:** `inc:break -- 24` quitaba la CA de los nodos, pero la imagen `lab-registry:5000/lab/pricing:g8`
  ya estaba en ellos (la trajo la §5.7, que el lector hace antes): con `IfNotPresent` no hay pull, y `pricing`
  arrancó `Running`. **Corregido:** `registry:untrust` también borra de cada nodo los nombres que vinieron de
  `lab-registry` (`ctr -n k8s.io images rm`, solo esos nombres: `docker.io/lab/pricing:g8` queda). Con eso,
  `ErrImagePull` y el `x509: certificate signed by unknown authority` del cuaderno.
- **Segunda cara:** el `fix` (`registry:trust` y borrar el pod) deja `pricing` corriendo con la imagen del registry,
  traída por el kubelet. El `task deploy FORCE=true` siguiente cae en la trampa de la §5.7: el pod nuevo, con
  `lab/pricing:g8`, en `ImagePullBackOff` en ese nodo; `Progress deadline exceeded`, y el rollback falla igual
  (release en `failed`; log `f19-deploy-tras-24.log`).
- **Corregido:** una tarea nueva, `task registry:forget -- lab`, que en cada nodo con la nota del kubelet la borra y
  reinicia ese kubelet; el `fix` del 24 la corre al final, y después `task deploy FORCE=true`. Probado el ciclo
  entero: `ErrImagePull`, después el pull del registry (65 ms; publicado 141), el kubelet reiniciado en el nodo que
  la tenía y el release en `deployed` con `lab/pricing:g8`. El cuaderno (cómo llegar y corrección) y la §5.7 lo dicen.

## F20 · Seguridad del pod y de la red

### H335 · Con la raíz de solo lectura, el `catalog` generado no arranca: `bootstrap/cache` se escribía en el primer arranque 🔴

- **Qué pasó:** con el endurecimiento completo y los `emptyDir` en `/tmp`, `catalog` respondía 500 a las sondas:
  `The /app/bootstrap/cache directory must be present and writable` y, detrás, `Target class [view] does not exist`
  (log en `f20-deploy-*`). El rollout vencía su plazo y `--rollback-on-failure` volvía atrás.
- **Causa:** el prompt de G0 pide `composer create-project --no-scripts`, y el `Dockerfile` de la pasada (F04) instala
  con `--no-scripts`: nadie corre `package:discover`, y Laravel escribe el manifiesto de paquetes en la primera
  petición. La imagen del curso no lo sufre porque su `Dockerfile` termina con `composer dump-autoload`, que corre ese
  script. La F04 no muestra el `Dockerfile` de `catalog`, así que el lector no tiene de dónde sacarlo.
- **Corregido:** en la pasada, `php artisan package:discover` en el build; en el curso, la F20 §6 lo dice (síntoma,
  causa y la forma de la imagen del curso). Alternativa que no tomé: un `emptyDir` en `bootstrap/cache`, que tapa la
  causa.

### H336 · El ejercicio de la F20 manda a `reach.js` «en la verificación del curso», que está en `prompts/` 🟡

- `prompts/` no se publica. **Corregido:** el párrafo de los ejercicios describe el script (quince líneas de Node con
  `fetch` y `net.connect`) y cómo correrlo. El de la pasada está en `reach.js` y `reach.sh`.

### H337 · Lo que reprodujo en la F20 🟢

- **Sin políticas**, desde `apps-b`: 200 · 200 · 200 · conecta, literal.
- **`runAsNonRoot` sin números:** los mismos tres en `CreateContainerConfigError` (`inventory`, `www-data`, `node`),
  con el mensaje literal; `pricing` y `storefront` pasan.
- **La raíz de solo lectura:** sin `/tmp`, `inventory` con `Unable to start web server`; sin `conf.d`, el `storefront`
  con `can't create /etc/nginx/conf.d/default.conf: Read-only file system`. Con los `emptyDir`, G5, G7 (verificador en
  `ok`) y G8 en verde, y sin token montado.
- **RBAC:** 403 con la `ServiceAccount` `default`, 200 con el `Role` de un solo `Secret`, y los tres `can-i` (`yes`,
  `no`, `no`).
- **Las políticas:** la tabla del §8 idéntica en sus cuatro filas; la puerta en HTTP y HTTPS, G5 y G8 en verde.
- **Incidente 25:** `container has runAsNonRoot and image will run as root`, literal. **Incidente 26:** 504 en 15,0 s
  por la puerta (publicado 16,2), `lookup pricing: EAI_AGAIN`, por IP conecta. Tras el `fix`, la primera venta dio 503
  durante unos segundos: la readiness de `inventory` había caído (la base tampoco se resolvía) y tardó en volver.
- **Al pie, del método:** con `--rollback-on-failure`, una prueba que no arranca (el endurecimiento sin `/tmp`) se
  deshace sola a los dos minutos (el `progressDeadlineSeconds`), y lo que se ve después es la revisión anterior: los
  síntomas de la §5.2 hay que mirarlos en esa ventana. Un `kubectl patch` previo deja además campos que el rollback no
  quita (H329).

## F21 · Diagnóstico

### H338 · k9s, verificado con una terminal emulada: `--readonly` apaga `s`, y `shift-f` propone el 8080 🟡

- **Cómo:** k9s 0.51.0 contra `kind-lab`, dentro de un pty con `pyte` como terminal (`k9s-pty.py`, `k9s-pty-2.py`;
  pantallas en `f21-k9s.log` y `f21-k9s-2.log`).
- **Resultados:** `:pods`, el filtro con `/`, `d` (describe), `:events` y `l` hacen lo de la tabla. `shift-f` abre el
  diálogo de `port-forward` **también en `--readonly`**, con `Local Port: 8080`, que en el laboratorio es el puerto de la
  puerta. `s` **no hace nada en `--readonly`**; sin él, abre `<<K9s-Shell>> … /app $`. `p` no se distinguió (el pod no
  tenía vida anterior).
- **Corregido:** la F21 §5.8 lo dice (el `s` que `--readonly` apaga, el 8080 a cambiar) y su advertencia pasa de «no
  verificado» a lo verificado y lo que no.

### H339 · La F15 no dice por dónde entran los parámetros de la JVM, y la F18 y la F21 los dan por hechos 🟡

- La F18 §6 y la F21 §5.4 hablan de «el `jvm.options` del chart, que la Fase 15 usó para dimensionarla»; la F15 no lo
  nombra. El chart de la pasada no lo tenía. **Corregido:** una frase en la autopsia de la F15 (el valor
  `inventory.jvm.options` en `JAVA_TOOL_OPTIONS`), y el valor en el chart de la pasada.

### H340 · Una cerca de código rota en la F21 §4 🟢

- El cierre de un bloque `text` y la frase siguiente estaban en la misma línea («``` Los tres "no contestan"»): el
  resto de la sección se renderizaba como código. **Corregido.**

### H341 · Lo que reprodujo en la F21 🟢

- **El caso 3 del §4:** con `catalog` en cero réplicas y las políticas, 504 a los 15,0 s, y la venta registrada
  **154,6 s** después, cuando `catalog` volvió (publicado 145,8). Matiz del método: la primera vez la venta pasó en
  68 ms, porque el pod de `catalog` seguía en su `preStop` y kube-proxy usa los endpoints que terminan cuando no hay
  otros; hay que esperar a que no quede ninguno.
- **`logs --previous`** con `MaxRAMPercent=75`: `CrashLoopBackOff`, `Exit Code: 1` y el texto de la JVM literal, con una
  línea más al principio (`Picked up JAVA_TOOL_OPTIONS: …`), y la réplica vieja atendiendo.
- **`port-forward`:** 404 por la puerta y 200 por el túnel con la ruta en `/precios`, con las políticas puestas.
- **`exec` en distroless:** `exec: "sh": executable file not found in $PATH`. **El efímero** en `pricing`, como 65532 y
  con el aviso de `kubectl` literal; **`jcmd`** desde el efímero del JDK contesta (`-XX:MaxHeapSize=134217728`,
  `-XX:+UseSerialGC`). Los tres casos «no contesta» del §5.9 salen de lo medido en la F19 y la F20.

## F22 · Resiliencia y caos

### H342 · El generador y G9, a la primera; y lo que el prompt del generador no dice 🟡

- El generador (159 líneas, solo biblioteca estándar) y `inventory:g9` (Resilience4j 2.3.0, la de `a01`; ya existe la
  2.4.0) salieron funcionando a la primera; G5 y G8 siguen en verde con `:g9`, y `/metrics` trae 70 series de
  `resilience4j`.
- **Ambigüedad del prompt:** no dice si un `PUT /chaos` reinicia las cuentas. El mío las reiniciaba; el del curso
  cuenta desde que arranca. **Corregido** en `a03` (desde que arrancó; un `PUT` no las toca) y en la F22 §5.1 (para una
  corrida, la diferencia entre dos `show`).
- **Lo que la fase no muestra entero:** el subchart `chaos`, la variable `<VECINO>_URL` en `inventory` y
  `bench/f22/cascada.js`. **Corregido:** la §5.1 dice que se copian del `src/lab/` del curso (como H324).
- **Una trampa del script, no del curso:** `task chaos:set -- campo=valor` **mezcla** con las fallas que había; para
  medir una falla sola hace falta `-- clear` antes. Mi primera corrida de la §5.6 heredó la latencia del paso anterior.
  La fase no lo dice; el ejercicio que encadena perfiles lo va a encontrar. Corrección propuesta (no aplicada): una
  línea en la §5.1.

### H343 · Lo que reprodujo en la F22 🟢

- **La cascada con G8** (§4): existencias p95 5,45 ms → **5,13 s**, ventas p95 31 ms → 10,1 s, 11 % de fallas en los dos
  escenarios (publicado 17,6 ms → 5,54 s y 6,6–7,0 %).
- **Los reintentos** (§5.3, 50 % de errores, 10 ventas/s, 30 s): ingenuo 5,0 % de fallas y **1,84** peticiones por
  venta (6,6 % y 1,85); sin reintentos 45,5 % y 1,00 (49,8 % y 1,00).
- **El circuito** (§5.4, 100 % de errores): abierto, con las llamadas de prueba cada diez segundos (3 · 2+1 · 1+2) y un
  `half_open` entre ellas; mediana 3,9 ms, 300 de 300 fallidas (4,8 ms y 401 de 401).
- **La cascada con G9** (§5.5): existencias p95 **5,6 ms**, ventas todas fallidas y rápidas, 18 peticiones a `catalog`
  en el minuto (publicado 10,9 ms y 89).
- **Lo roto y lo mudo** (§5.6): malformada, 503 en 0,57 s con `"malformed":3` (0,72 s); colgada, 503 en **6,43 s** con
  `"hung":3` (6,36 s).
- **La tabla del §8:** G9 con 50 % de errores, **97,7 %** de fallas y 0,05 peticiones por venta (95,7 % y 0,09);
  *Sogamoso con lluvia*, 97,3 % (87 %; el circuito venía de abrirse doce segundos antes). La conclusión no cambia.
- **Del ambiente:** al apagar el caos, el `Job` de migraciones de `catalog` tardó 12 minutos en marcarse completo, con
  `FailedCreate: Unauthorized` del `job-controller` (un error pasajero del plano de control de kind a las 27 horas de
  vida); el pod había terminado en segundos. No es del curso.

## F23 · gRPC y el balanceo

### H344 · G10 en los cuatro, a la primera; dos matices de la generación 🟢/🟡

- `task proto` generó `pricingv1/`; las cuatro imágenes `:g10` construyeron a la primera, y con gRPC encendido G5, G7
  (verificador en `ok`) y G8 siguen en verde; el log de `pricing` muestra `GetPrice` con el `x-request-id` del cliente.
- **Las versiones:** `go get` sin versión trae OpenTelemetry 1.47.0 y contrib 0.72.0; `a01` fija 1.44.0 y 0.69.0, y la
  pasada las fijó así. El prompt de `pricing` no repite las versiones (sí lo hace el de `catalog`, por `a01`).
- **El `Dockerfile` de `pricing`** copiaba `*.go`: con `pricingv1/` hace falta un `COPY` más. El prompt no lo dice.
- **`catalog`, contra lo que dice la §6:** «ignorar el requisito de plataforma no alcanza». En la pasada **alcanzó**:
  la etapa de build instala con `--ignore-platform-req=ext-opentelemetry` y la extensión se compila una sola vez, en la
  final. La diferencia es la de la H335: el `Dockerfile` del curso arma el autoload con `composer dump-autoload` (que
  corre los scripts y necesita la extensión); el de la pasada, con `install --no-scripts`. Las dos maneras funcionan;
  la frase de la §6 vale para la del curso. Al pie: con `OTEL_PHP_AUTOLOAD_ENABLED=true` en la imagen, el
  `package:discover` del build intenta exportar a `localhost:4318`; se calla con `OTEL_SDK_DISABLED=true` en ese `RUN`.
- **Corregido** en la F23 §6: la frase vale para el autoload de `dump-autoload`; con `install --no-scripts`, alcanza.

### H345 · B-23 necesita `bench/b23/ventas.js`, que no está en la copia inicial ni en la fase; sin él, el arnés falla mal 🟡

- `task measure -- B-23` terminó con `FileNotFoundError: …/summary.json`: k6 no corrió porque el script no existe, y el
  arnés no lo dice. **Corregido:** la F23 §5.1 dice que `bench/b23/ventas.js`, el subchart de Tempo y
  `lab-common.otelEnv` se copian del `src/lab/` del curso. Propuesta no aplicada: que `measure.py` compruebe el script
  antes de correr.

### H346 · B-23 remedido: lo determinista reproduce; lo que depende del azar, no 🟡

- **`service`**: 100 % a una réplica, las tres corridas (publicado igual). **`client`**: 33 % exacto, las tres (igual).
  Medianas de la venta 22,8–29,6 ms (23,1–25,7).
- **`service+age`**: 52 %, 64 % y 53 % para la más cargada (publicado 100, 100, 70): la apuesta que la fase da por
  perdida («entre 40 y 70 %») sale ganada. **La réplica nueva con `client+age`**: 34, 231 y 178 de 1200 en tres
  corridas (publicado, una corrida, 237); `client` solo, 0 de 1201, igual.
- **Lectura:** con 10 s de edad hay tres reconexiones en 30 s, y cada una tira el dado de kube-proxy una vez: las dos
  mediciones son tiradas del mismo proceso. **Corregido:** `BENCHMARKS.md` B-23 con la segunda medición y su lectura;
  F23 §5.4, §5.5 y las dos apuestas de la §7 con los números del 23/10. El veredicto no cambia.

### H347 · Lo que reprodujo en la F23 🟢

- **La traza** de una venta bajo el umbral: 20 spans, los cuatro servicios en una traza, el `POST` a `replenish`
  terminando después de la venta (172,7 ms la venta, el aviso a los 179 ms); el `Context.current().wrap` funciona y la
  línea del aviso trae su `trace_id`. `task obs:trace` imprime el árbol como en la §5.7.
- **Tempo caído** (§6): `catalog` con máximo de **15.017 ms** (el corte de la puerta), la venta en 503 a los **3,4 s**
  (publicado 3,5) con `HTTP connect timed out`, y `cURL error 28: Connection timed out after 10000 milliseconds` en el
  log de FPM; `pricing` y `replenish` sin cambios. Idéntico a lo publicado, y es la lección de D43.
- **El agente de Java** escribe las dos líneas de texto que el verificador de G7 acepta (CDS y `[otel.javaagent …]`).
- **Al pie:** Tempo ocupaba 59 MiB a los 17 minutos (publicado 132 en reposo; no es la misma lectura, no se cambia). El
  `deploy` de las trazas chocó con el `kubectl scale` de B-23: `FORCE=true`, como dice la fase.

## F24 · La saga orquestada

### H348 · Una compensación que vence su plazo pero se hace deja la saga en `COMPENSATING` para siempre 🔴

- **Dónde:** el `LoanSaga` de G11 (el de la pasada y el publicado), con el `cancel` de `replenish` de G1–G11.
- **Qué pasó:** prueba de dos réplicas con `replenish` demorado 1,8 s. Cuatro préstamos fallaron al cobrar y la
  cancelación de la moto tardó más que los 2 s de G9: `inventory` la anotó como fallida, pero `replenish` **sí** la
  hizo. El barrido la reintentó y recibió `409 … la orden RO-0040 está en CANCELLED y ya no se cancela` (el contrato de
  G1: «hasta G12, también si ya estaba en CANCELLED»). La saga lo trató como otra falla: **cuatro préstamos en
  `COMPENSATING` reintentando cada 30 s**, con decenas de `DISPATCH UNDO FAILED`, sin salida (log `f24-apuestas.log`).
- **Por qué el publicado no lo mostró:** la §5.6 provocó fallas de compensación con 503 (el vecino no hizo nada), no
  con demoras; y en el `src/lab/` final, `replenish` ya es de G12 y devuelve la orden cancelada con 200.
- **Corregido:** `undoDispatch`, ante un 409, lee la orden y, si ya está `CANCELLED`, da la compensación por hecha (en
  la pasada y en el `LoanSaga` publicado); el prompt de G11 de `a03` lo pide; la F24 §5.6 lo cuenta (el «no sé» del §8,
  del lado de las compensaciones). Verificado: con la imagen arreglada, el barrido terminó tres de los cuatro en un
  minuto; el cuarto lo seguían tomando las réplicas viejas cuando el motor se detuvo (H350). **Falta compilar el
  `LoanSaga` publicado** con el cambio (el motor estaba detenido).

### H349 · Lo que reprodujo en la F24 🟢

- **G11 a la primera** (`inventory.g11.hurl`, 21 peticiones; publicado 22). El despliegue no tuvo tropiezo.
- **El préstamo que sale bien:** `COMPLETED`, Girón 500 → 499, Chapinero 477 → 478, cobro de 12.900; la traza con la
  saga como hija del `POST /loans` (40 spans, más lenta que la publicada por ser la primera llamada gRPC en frío).
- **`replenish` en 503** (§5.5): `COMPENSATED`, con `LOAN_OUT` y `ADJUSTMENT LOAN_RELEASED` en la base, y Girón de vuelta.
- **La compensación que falla** (§5.6): de ocho préstamos a `DRO-024`, cinco compensados en el acto y uno en
  `COMPENSATING`, retomado por el barrido (el patrón publicado).
- **El orquestador muerto** (§5.7): la primera vez la saga alcanzó a terminar (`COMPLETED`; el kubelet no mata en el
  acto, como dice la segunda apuesta); la segunda, el pod murió con el despacho en vuelo, y el barrido del pod nuevo
  compensó a los **42 s** (publicado 37), con `failure: sin terminar en RESERVED después de 30 s`.
- **Sogamoso con lluvia** (§7, 20 préstamos): 5 `COMPLETED` y 15 `COMPENSATED`; de los despachos fallidos, 8 por 503 y
  7 por timeout; **12 órdenes `PENDING` para 5 préstamos completos: exactamente 7 huérfanas, una por timeout**, y
  ninguna de los 503. La apuesta, ganada con otros números (publicado 10/8/2).
- **La rotura del §8** (3 s de demora): 5 préstamos `COMPENSATED`, Girón intacto, y **5 órdenes `PENDING`** sin préstamo;
  el generador las pasó todas (`delayed: 5, passed: 5`).
- **Dos réplicas muertas** (§7): de diez préstamos, ninguno con dos `LOAN_RELEASED` y ningún `UNDO` repetido; los
  barridos de los dos pods nuevos se repartieron los préstamos.
- **No hecho:** la §4 (el `register_loan` de Contingencia y la carpeta de traslados en compose).

### H350 · El motor se detuvo a mitad de la F24 (no fue la sesión) ⚪

- El 23/10 a las ~13:55, todos los contenedores recibieron `stop` en el mismo segundo, incluido el ajeno
  `gfapp-dev-db-1`; la VM llevaba 37 h arriba (no se reinició) y el proceso de Docker Desktop tampoco. Ningún comando de
  la sesión los detuvo. La sesión no volvió a levantar nada y le preguntó al autor.

### H351 · Un deploy cortado deja el release en `pending-upgrade` y el curso no dice cómo soltarlo 🟡

- El deploy de las 13:57 del 23/10 murió con el motor (H350); al volver, `task deploy` respondió
  `another operation (install/upgrade/rollback) is in progress` (revisión 84 `pending-upgrade`). `helm rollback lab 83`
  falló por el conflicto de `.spec.replicas` con el `kubectl scale` de la F16, pero dejó la 84 `superseded` y el
  `deploy FORCE=true` siguiente pasó (revisión 86).
- Corrección: entrada nueva en `a02` (Común a las tres).

### H352 · `kubectl wait` sale enseguida mientras el API server arranca 🟢

- Tras `docker start` de los nodos, `kubectl wait --for=condition=Ready nodes --all` salió con `EOF` ×3 y
  `Error from server (Forbidden): unknown` en ~35 s, sin esperar el timeout. Un `until kubectl get nodes` antes lo resuelve.
- Corrección: párrafo en `a02` (El cluster no revive después de reiniciar).

### H353 · Repetir el `kill 1` en el mismo pod multiplica los perdidos (back-off de kubelet) 🟡

- F25 §4.1 con Valkey: con un pod que ya había reiniciado, el segundo `kill 1` esperó el back-off (10 s, evento
  `BackOff`) y dejó 12 avisos a 0 suscriptores (18 órdenes). Con un pod nuevo: 29/30 (1 perdido) y 28/30 (2), como el curso.
- Corrección: el ejercicio 3 y la §8 dicen que se empiece de un pod nuevo y por qué.

### H354 · G12 de la pasada: dos réplicas chocaban en el id de la orden y el rechazo tumbaba replenish 🔴

- `rollout restart` con Valkey (§5.5) dio 24 órdenes, 8 avisos a 0 suscriptores y solo 2 repetidos, en vez de 40/10/0:
  el pod nuevo murió dos veces por `replenishment_orders_id_key` (el id salía de `MAX(seq) + 1` leído antes del INSERT,
  generado en G1) y el manejador de `message` hacía `void this.create(…)` (rechazo sin manejar: Node termina el proceso).
  Hasta G11 una sola réplica creaba órdenes, y no se veía.
- Corrección: prompt de G12 · replenish (el número sale de la secuencia de la base; el manejador lleva su `catch`); la
  pasada corregida (id provisional y `RO-<seq>` después del INSERT). Remedido: 39 órdenes, 30 eventos, 9 repetidos, 0
  perdidos (el curso: 40/30/10). El `src/lab` publicado ya derivaba el id de `seq` y capturaba el error.

### H355 · El POST pierde más que Valkey con el mismo reinicio: el Service espera la readiness ⚪

- F25 §4.2 sin bus: 24/30 (6 perdidos) en dos corridas con pod nuevo, contra 2 publicados. El proceso escuchaba a las
  04:17:14,6 y los POST fallaron (`HTTP connect timed out`) hasta las 04:17:19,9: la readiness (cada 5 s) devolvió el
  endpoint al Service. Valkey re-suscribe al arrancar el proceso.
- Corrección: párrafo con la remedición y la causa en §4.2; la tabla de §8 queda con la corrida original.

### H356 · La suite de G12 falla siempre la primera vez: con una sola orden, Hurl no da lista y `last` revienta 🔴

- La «prueba de fuego» de la F25 falló en su primera corrida (15 peticiones en 5,1 s: los 10 reintentos del GET) aunque
  la orden con `sourceEventId` se creó en 5 ms. Con una sola coincidencia, `$[?(@.destinationStore == 'DRO-025')].sourceEventId`
  devuelve el texto suelto, y `last` falla con `invalid filter input type · actual: string · expected: list` (Hurl 8.0.1).
  Con dos o más, pasa: por eso las corridas siguientes pasaron. Reproducido contra DRO-026 (virgen): falla igual.
- Corrección: `contracts/conformance/inventory.g12.hurl` crea antes de la venta una orden a mano de DRO-025 (y comprueba
  que llega sin `sourceEventId`), así el filtro siempre ve dos o más. Probada contra DRO-027 (virgen): pasa, 7 peticiones.
- Quedan en la base del lab DRO-026 y DRO-027 con existencia y órdenes de la prueba (inofensivo).

### H357 · F26 §4.2: con G12, el `kill -9` a inventory deja ventas sin orden en las tres corridas, no en una ⚪

- Tres corridas con pod nuevo (16 clientes, 10 s, `pkill -9` desde el nodo a los 4 s): 2, 1 y 3 ventas sin orden, con
  690/687, 671/669 y 700/697 ventas en la base contra respuestas 201. El curso: 0 · 0 · 1. Con 16 clientes hay varios
  avisos en vuelo en sus hilos virtuales cuando muere la JVM.
- Corrección: frase con la remedición en §4.2; la tabla de §8.1 queda con la corrida original.
- El resto de la F26 reproduce: `kill -9` a replenish 1·1·0·1 repetidas con G12 (la pareja a 30 s exactos, `deliveryCount`
  2), 0 con G13; inventory 0·0·0 con G13 (con una venta de más que 201 en cada corrida, con su orden); las dos defensas
  a mano idénticas a §8.2; G13 a la primera (15 peticiones); apuesta 4 con cero huérfanas, todos terminados 30 s después de
  parar la lluvia (el prompt ya pide la cancelación idempotente).

### H358 · F27 criterio 3: `task obs:on -- dashboards` redespliega con el perfil `lab` 🟡

- `obs:on` despliega por defecto con `PROFILE=lab` (a diferencia de `bus:on` y `chaos:on`, que usan `minimo` en el
  cluster `lab`); en la Parte IV, eso cambia los valores de los otros cuatro y rompe el criterio 7. Lo mismo que se
  corrigió en la F17 (H325).
- Corrección: `task obs:on PROFILE=minimo CLUSTER=lab -- dashboards` en §6.2, con la razón en el comentario.

### H359 · F27: el criterio de salida dice que el consumidor durable "hubo que borrarlo a mano", sin decir cómo 🟢

- Reproducido el 24/10: con `notify.enabled=false`, el chart se lleva todo menos `notify-stock-low`, que acumula
  pendientes (1 tras una venta). `nats consumer rm` desde un pod de nats-box en `apps` lo borra.
- Corrección: el comando en §6.3, con la imagen por digest de a01.
- El resto de la F27 reproduce: build 14,5 s, despliegue 23 s, `notify.g13.hurl` 9 peticiones, `up` 1 y el panel con
  1,89/s, rollout con {200: 15408}, el incidente de la readiness con rollback a los 2 min 22 s y {200: 5141}, ningún pod de
  los otros cinco recreado; `notify` en 211 líneas de Go (el curso dice unas 150).

## Apéndices 🔥

### H360 · a06 reproduce, con los tiempos de inventory a la mitad y la emulación de Java más cara ⚪

- Builds (una corrida, sin caché): pricing 31,3 / 92,2 emulado / 27,6 cruzado (curso 23,2–32,6 / 73,1–83,8 / 27,8–29,0);
  inventory 57,9 / **falló** con el mismo `tar … Function not implemented` / 52,4 (curso 108,3 / falló / 111,0). Multi
  23,8 s con caché (23,1), mismas dos variantes en `--tree`. Arranque: pricing 0,23 vs 0,38 (1,7x), inventory 4,83 vs
  22,35 (**4,6x**; curso 3,6x). kind: la amd64 en containerd sin `managed`, `crictl` no la ve, `ErrImageNeverPull`; la
  arm64 corre. (`logs/a06-*.log`)
- Corrección: dos párrafos "Remedido el 24/10/2026" en a06; las tablas quedan con la primera fecha.
- Nota para el diff: el wrapper de Maven de la pasada pide 3.9.16 y el `src/lab` publicado 3.10.0 (el log del build
  emulado mostró 3.10.0 descargándose: revisar de dónde).

### H361 · a07: el digest de Buildah de a01 ya no existe en quay 🔴

- `docker pull quay.io/buildah/stable@sha256:fcbe1d59…` → `not found`: quay reconstruyó la etiqueta `v1.43.4`
  (hoy `sha256:07e637ad…`) y borró la anterior. El primer comando del apéndice falla tal cual. Las otras 30 imágenes
  fijadas en a01 se resuelven (comprobado con `buildx imagetools inspect`).
- Corrección: el digest nuevo en a01, con la advertencia de que quay reconstruye; nota en a07.

### H362 · a07 reproduce con proporciones menores; dos detalles nuevos ⚪

- Buildah 43,4 s (1,4x Docker, curso 1,6x), Kaniko 66,5/64,6 (2,1x, curso 2,6x), ko build 27,0/25,0 + 31–35 s de
  `go install`, Jib 40,1 (curso 83,9). Capas idénticas (14/15/15/10); binario 24,4 MB y 35,8 en ko; overlay sin vfs da el
  mismo `fork/exec /bin/sh: invalid argument`; ko sin DATA_DIR da el error de SQLite (texto "aplicar", no "crear").
- Detalles: repetir Buildah en la misma carpeta falla en el push (`docker-archive doesn't support modifying existing
  images`): agregado a la nota de a07. La imagen de Jib de la **pasada** no muere sin DATA_DIR: queda con readiness 503 y
  500 en cada lectura (el `Migrations` generado en la pasada no tumba el arranque); el curso describe la del `src/lab`.
  (`logs/a07-*.log`)

### H363 · a08: JVM y AOT cache reproducen; la nativa no se ejecutó (VM de 3,8 GiB) ⚪

- JVM 2,36 s / 196 / 217 MiB; AOT 1,18 s / 195 / 212 MiB (curso 2,28 / 332 / 357 y 1,31 / 306 / 337): la proporción del
  arranque se mantiene (2,0x contra 1,7x) y la memoria absoluta baja porque el heap se dimensiona contra la VM (3,8 GiB
  ahora, 7,75 entonces), lo que la advertencia del apéndice ya decía. Builds 57,9 / 56,5 s; imágenes 688 / 712 MB.
- La pasada no tenía `Dockerfile.aot` (la F15 lo nombra como sección corta): escrito desde el publicado, con el contrato
  en `proto/` (el pom de la pasada) en vez de `src/main/proto/`. La nativa (5,3–6,0 GB) no entra: queda **no ejecutada**,
  anotada en a08. (`logs/a08-*.log`)

### H364 · a09 reproduce a la primera, con el SSR escrito desde el apéndice ⚪

- server.mjs (50 líneas sin las vacías, con `createElement` y sin build), imagen de **254 MB** (igual), dos marcas con una
  imagen, el ConfigMap visto a los 69 y 73 s sin reinicio (curso 68), carga 18/20 ms estática y 17/18–19 ms SSR (curso
  18,2/20,8 y 16,6/18,5), memoria SSR 31 → 41 MiB contra 7 del nginx (curso 32–71 → 92: menos, mismo orden), y con
  `catalog` en cero el 503 por timeout de la SSR, el 200 del HTML estático con su catálogo en 503 y la readiness 1/1.
  Sin correcciones. (`logs/a09-*.log`, `a09/`)

### H365 · a10 reproduce de punta a punta ⚪

- Istio ambient 1.31.1 desde blob.istio.io en 31 s (curso 42), 162 MiB en reposo (148); `apps` al mesh sin reinicios, venta
  201, G5 verde, identidades `sa/default` en los dos extremos y Postgres fuera del mesh; el waypoint sin la política:
  `failed to sign CSR … 15012: i/o timeout` y venta 503; con `allow-waypoint-istiod`, 201. Reintentos: 108/200 sin
  ruta (104), 17·13·17 con la HTTPRoute (23·7·18), el vecino con 368–387 peticiones (397). Métricas del waypoint 645 / 108
  / 47 URX (648 / 104 / 48). Retiro: 15 CRD y 3 GatewayClass que quedan, borradas a mano, venta 201 sin reinicios.
- Detalle: la imagen del waypoint no trae `curl`; el puerto 15020 se lee con `pilot-agent request GET stats/prometheus`
  (el apéndice no daba el comando): agregado en a10. (`logs/a10-*.log`, `a10/`)

### H366 · a11: la Application del apéndice no crea su namespace y se queda en OutOfSync 🟡

- Argo CD 3.5.3 listo en 48 s (igual), 392 MiB en reposo (443). La `Application` tal cual: `OutOfSync`/`Missing`,
  `namespaces "a11-guestbook" not found`, reintentando; agregar la opción a la Application viva no alcanza (la operación
  en curso sigue con la configuración vieja). Con `syncOptions: [CreateNamespace=true]` y recreada: Synced/Healthy en 19 s.
  selfHeal: 0,6 · 1,7 · 2,8 s mirando cada 50 ms con kubectl (curso 0,2 s). Retiro limpio: CRD, ClusterRoles,
  namespaces e imágenes de los nodos.
- Corrección: la opción en el YAML de a11, con el síntoma y la nota de recrear; la remedición del selfHeal entre
  paréntesis. (`logs/a11-*.log`, `a11/`)

### H367 · a12 reproduce ⚪

- Las mismas 28 CRD en los mismos seis grupos (sin restos de a10/a11). El Secret de cert-manager repuesto en 0,2 s (0,4)
  con los mismos eventos (`Generated`, `Requested … a12-prueba-2`, `Issuing`); el proxy de Envoy Gateway a cero no volvió
  en 60 s (envoy-gateway con `Apply` sin `f:replicas`; kube-controller-manager en `status`), y con la réplica a mano la
  puerta contestó a los 11,8 s (11,1). Sin correcciones. (`logs/a12-*.log`, `a12/`)

### H368 · a13: `DROP DATABASE pricing` falla con pricing conectado, y `kind delete cluster` deja a kubectl sin contexto 🟡

- El respaldo reproduce (los mismos nueve archivos, 6 s contra 14). El desastre tal como lo escribe el apéndice no
  ocurre: `There are 3 other sessions using the database`; con `WITH (FORCE)`, sí: +9 s precio 500, venta 503, pricing
  0/1; el Job de restauración (escrito desde el fragmento) devuelve 177 precios y la venta a los 25 s (12), sin reiniciar
  pricing. El cluster `a13` con `extraMounts`: el PVC no sobrevive y la carpeta del host sí, idéntico. Y después de
  `kind delete cluster --name a13`, `kubectl` queda con `current-context is not set` (kind saca el contexto borrado y no
  pone otro): los comandos sin `--context` del curso fallan hasta `kubectl config use-context kind-lab`.
- Corrección: el `DROP … WITH (FORCE)` con su razón, y la advertencia del contexto, en a13. (`logs/a13-*.log`, `a13/`)

### H369 · a14 reproduce; el "cuarto contenedor" sí es del curso ⚪

- Tres nodos para el motor y 30 contenedores de pods adentro (9 / 8 / 13); 27 pods (33 entonces, con más cosas
  encendidas). Headlamp 0.45.0 listo en 7 s (272: la imagen ya estaba en ghcr caché o bajó rápido), 14 MiB (13),
  `headlamp-admin` → `cluster-admin`; por su proxy: sin token 403, token `view` 200 con los pods, 403 en Secrets y 403 al
  borrar con el pod intacto. Retiro limpio (incluida la imagen de los nodos).
- El apéndice dice "contenedores en el motor, en total: 4 (el cuarto no es del curso)"; con el registry de la F19 arriba,
  el cuarto es `lab-registry`, que sí es del curso. Menor: sin corrección. (`logs/a14-*.log`, `a14/`)
- No verificable por CLI: lo que dibujan Docker Desktop y Podman Desktop (la sección se apoya en `docker stats`, que sí
  reproduce: 1,34 GiB el control-plane, 583 y 675 MiB los workers).

### H370 · a15 reproduce, y dos matices: el líder sí puede "volver a casa", y una fallida puede quedar guardada 🟢

- OrderedReady + sin `publishNotReadyAddresses`: a los 90 s solo `nats-ha-0` 0/1 con `Waiting for routing` y `JetStream
  is still recovering meta layer`, idéntico. El manifiesto publicado: tres listos en 17 s (15), dos en el mismo nodo.
  Stream R3 con su líder. Matar al líder: `delete` 0 fallidas de 385 (curso 1 de 400); `kill -9` 48 de 392 en 5,0 s (47 en
  5,4), cero confirmadas perdidas y cero fallidas guardadas. Quórum: fallidas de +10 a +42 s (12–40,8), /healthz 503,
  cero perdidas. Dedup con líder nuevo: `Duplicate: true`, un mensaje. Memoria ~10 MiB por miembro contra 11 de `nats-0`.
- Matices: tras el `kill -9`, el mismo miembro volvió en el mismo segundo y **ganó** la elección a los 5,4 s (la nota decía
  que el liderazgo no vuelve a casa); en la pérdida de quórum, **3 fallidas quedaron guardadas** (la confirmación se
  perdió). Corrección: la nota del liderazgo reescrita y el caso inverso agregado en a15. (`logs/a15-*.log`, `a15/`)

## Cierre de C2

### H371 · El diff del `src/lab/` de la pasada contra el publicado: 227 entradas, ninguna funcional fuera de lo generado ⚪

- `logs/c2-diff-src.txt` (sin `node_modules`, `target`, `dist`, `.secrets`, `.observability.json`). Por grupos:
  - **Lo que el lector copia** (`Taskfile.yml`, `scripts/`, `contracts/`): el `Taskfile.yml` difiere solo en `notify`
    (F27, `SERVICES` y `STEP_TAGS`), `cluster.env` en la línea de `notify`, y `scripts/engine/engine.py` en un comentario
    que C0 agregó al publicado después de la copia. Sin diferencias de comportamiento.
  - **Lo que el lector escribe siguiendo las fases** (`platform/`, `deploy/`, `compose/`, `charts/`, `chaos/`): comentarios
    y formas distintas de lo mismo; lo que no era forma salió como hallazgo en su fase (H289–H350).
  - **Lo generado con los prompts de a03** (`services/*`): otro código, por diseño de la pasada. Lo que importó salió como
    hallazgo: H354 (el id de replenish con dos réplicas), H362 (el arranque de SQLite en la Jib de la pasada), el pom de la
    pasada con el contrato en `proto/` y no en `src/main/proto/` (a07/a08 dicen el del publicado), y el wrapper de Maven
    (3.9.16 en la pasada, 3.10.0 en el publicado).
  - **Resultados de `bench/`**: corridas con otras fechas (lo esperable), y `notify` (F27) solo en la pasada.
- Sin corrección: el diff no puede salir vacío mientras los servicios se generen en la pasada, y eso es lo que la pasada
  prueba.
