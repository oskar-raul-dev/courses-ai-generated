# Hallazgos candidatos de la tanda C1

> Borrador de trabajo. Cada uno pasa a `prompts/verificacion-de-laboratorio/hallazgos.md` con su
> número definitivo (desde H271) **cuando se verifica por ejecución**, no antes.

## Verificados (solo lectura, sin ejecutar el laboratorio)

- **C1-a · `openssl` del `PATH` es 4.0.3, y `a01` fija 3.6.4.** En la máquina están los dos
  (`openssl@3` 3.6.4 y `openssl@4` 4.0.3); el que responde es el 4.0.3. Un lector que hoy haga
  `brew install openssl` recibe la 4.x. Afecta a las recetas de F19 (`openssl s_client`, `verify`)
  y a la tabla de versiones de `a01`. **No se corrige todavía:** la decisión necesita que C2 corra
  F19 con la 4.0.3. Nota: `a01` dice en la tabla de G-pasos que la CA se hace con `cryptography` de
  Python, «sin `openssl` en la máquina», así que el alcance real puede ser menor de lo que parece.

- **C1-b · `measure.py` deja el cluster huérfano si el motor se cae en medio.** Al reiniciarse
  Docker Desktop durante la corrida 1 de B-00, el `helm install` murió con `unexpected EOF`; el
  `kind delete cluster` de limpieza falló por lo mismo y la excepción se propagó, dejando
  `minimo-control-plane` arriba. Se borró a mano. Candidato a `a02` (que ya tiene sección de
  huérfanos de kind) o a un `try/finally` en el arnés. Entorno, no curso, pero el síntoma es del
  laboratorio.

## Por verificar al ejecutar F02 (predicción, no hallazgo todavía)

- **C1-c · `task compose:up` en la F02 nombra `catalog-nginx`, que llega en la F04.**
  `COMPOSE_SERVICES` del Taskfile (que §4.7 manda copiar en su estado final) es
  `pricing inventory catalog catalog-nginx replenish storefront`. El `compose.yaml` del lector en
  F02 no tiene `catalog-nginx` (lo agrega F04 §5, línea 332), así que `up -d` debería fallar con
  `no such service`. Si en cambio el lector copia el `compose.yaml` final, `catalog-nginx` arranca
  con un `nginx.conf` que todavía no existe, y la salida de `ps` de F02 §4.5 (diez contenedores,
  sin `catalog-nginx`) no coincide. **Se confirma corriendo F02.**

- **C1-d · De dónde sale `compose/compose.yaml` no está dicho donde se busca.** §4.7 de F00 y la
  tabla de apéndices de la convención de git listan lo que trae la copia inicial (Taskfile, kind,
  scripts) y lo que deja `a16` («Contingencia, el portal y la Braqui»), sin nombrar el
  `compose.yaml`; quien lo dice es `a16` en su bloque 🏷️ de cierre («`src/lab/legacy/` y el perfil
  `legacy` de compose»). La F02 lo presenta como existente («El archivo es
  `src/lab/compose/compose.yaml`, y hoy tiene tres partes»). Los perfiles `conformance` y `docs`
  vienen de `a03`. Falta una línea que lo diga en §4.7 o en la tabla.
