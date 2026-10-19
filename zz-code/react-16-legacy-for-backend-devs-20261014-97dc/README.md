# 🧪 react-16-legacy-for-backend-devs-20261014-97dc · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tanda:** T0 (la raíz) · **Creado:** 2026-10-14
> **Propósito:** comprobar en contenedor los cuatro documentos de la raíz que T0 reescribe: el
> `package.json` y el `go.mod` de referencia, los tags de la convención y el diagrama de estados del
> alcance. Las reglas, en `zz-code/README.md` § "El README de cada directorio".

## 1. 🎯 Qué se prueba y para qué

| Prueba | Documento | Qué comprueba |
|---|---|---|
| `package.json` con npm 6 | `00-decisiones-y-versiones.md` §3 | Resuelve en `node:14.21.3` sin errores de resolución |
| `go.mod` | `00-decisiones-y-versiones.md` §7.2 | Descarga y verifica en `golang:1.19.13` |
| Tags de la convención | `00-convencion-de-git-y-tags.md` | Los 22 `fase-*` con los nombres de la propuesta §8.1, el diff del track BE vacío, los tags de ejercicio, incidente e hito |
| Diagrama de estados | `00-alcance-del-proyecto.md` §5 | El bloque `stateDiagram-v2` renderiza con `mermaid-cli` fijado |

No alimenta ninguna cifra del curso. Es la prueba de §5.1 de la tanda T0 del plan de edición.

## 2. 🛠️ Prerrequisitos

- macOS arm64, Docker 29.8.0. Nada instalado en el host.
- Imágenes: `node:14.21.3` y `golang:1.19.13` (ya presentes desde P7),
  `ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.4.2` (descargada en esta tanda; manifiesto verificado).
- Estado previo: repo vacío de prueba creado por `trabajo/tags/prueba-tags.sh`; sin tags del curso
  en ningún repo del alumno (esa es la regla de T0: el repo del curso no recibe tags).
- Inventario inicial en `salidas/inventario-inicial-*.txt` (tomado el 14/10 a las 01:43, ver §8).

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

Todo contenedor lleva `--label curso=react16`, y ninguno publica puertos al host. El repo de prueba
de los tags vive en `trabajo/tags/repo/` y lo recrea el script cada vez.

## 4. ▶️ Cómo se corre

Desde la raíz de este directorio, en este orden:

```bash
# 1. package.json de referencia: resolución con npm 6 (genera trabajo/paquete/package-lock.json)
docker run --rm --label curso=react16 -v "$PWD/trabajo/paquete":/app -w /app node:14.21.3 \
  sh -c 'node -v && npm -v && npm install --package-lock-only --ignore-scripts' \
  > salidas/t0-package-json-npm6.log 2>&1

# 2. go.mod de referencia: descarga y verificación
docker run --rm --label curso=react16 -v "$PWD/trabajo/gomod":/src -w /src golang:1.19.13 \
  sh -c 'go version && go mod download && go mod verify' > salidas/t0-go-mod-download-verify.log 2>&1

# 3. tags de la convención en un repo vacío (sin argumentos extra; el repo se crea en trabajo/tags/repo)
bash trabajo/tags/prueba-tags.sh "$PWD/trabajo/tags/repo" 2>&1 | tee salidas/t0-tags-repo-vacio.log

# 4. diagrama de estados: se extrae del .md con un script (no a mano) y se renderiza
python3 - <<'EOF'
import re
src = open("../../cursos-legacy/react-16-legacy-for-backend-devs/00-alcance-del-proyecto.md", encoding="utf-8").read()
open("trabajo/mermaid/alcance-rueda.mmd", "w", encoding="utf-8").write(re.findall(r"```mermaid\n(.*?)```", src, re.S)[0])
EOF
docker run --rm --label curso=react16 -v "$PWD/trabajo/mermaid":/data \
  ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.4.2 -i /data/alcance-rueda.mmd -o /data/alcance-rueda.svg \
  > salidas/t0-mermaid-alcance.log 2>&1
```

El paso 4 asume que el curso está en `../../cursos-legacy/…`, es decir, que este directorio está en
`zz-code/` dentro de la raíz del repo.

Lo que imprime el paso 3: `ok` por cada tag y el resumen `== fallos: 0`.

## 5. 📏 Cómo se mide

No hay mediciones en esta tanda. Las pruebas son de contenido: ¿resuelve, verifica, renderiza, existe
el tag? Cada una devuelve código de salida 0 o un error en su log.

## 6. 🧮 Los intermedios que amasan la salida

- `npm install --package-lock-only` reescribe `trabajo/paquete/package.json`: npm pasa los arrays de
  `browserslist` a varias líneas. El contenido es el mismo; por eso el `package.json` del curso
  (escrito en una línea por array) se compara con el probado en JSON, no como texto:
  `python3 trabajo/paquete/comparar-con-doc.py <raíz-del-curso> "$PWD/trabajo"`, registrado en
  `salidas/t0-comparacion-doc-vs-probado.log`.
- `mermaid-cli` escribe el `.svg` solo para tener una salida que mirar; la prueba es que el paso
  termine con código 0.

## 7. ✅ Qué se espera ver

| Prueba | Resultado de referencia (14/10/2026) | Registro |
|---|---|---|
| npm 6 | `node v14.21.3`, `npm 6.14.18`; `added 2201 packages`; sin error de resolución. Avisos de peer ausentes (bootstrap → jquery y popper; tsutils → typescript) y 283 vulnerabilidades del árbol de CRA 4 | `salidas/t0-package-json-npm6.log` |
| `go mod` | `go1.19.13`; `all modules verified` | `salidas/t0-go-mod-download-verify.log` |
| Tags | 22 `fase-*`; 6 renombres de §8.1 presentes; diff del track BE vacío; rama `incidente/be-09` creada; `== fallos: 0` | `salidas/t0-tags-repo-vacio.log` |
| Mermaid | renderiza; `Generating single mermaid chart` sin error | `salidas/t0-mermaid-alcance.log` |

## 8. 📂 Salidas

- `salidas/t0-*.log`: registros de las cuatro pruebas de arriba.
- `salidas/inventario-inicial-*.txt`: **ojo, aviso.** Hubo un error en esta sesión. Al tomar el
  inventario, el comando de salida apuntó al directorio de P7 (`…-20261014-f462`) y sobrescribió sus
  tres `inventario-inicial-*.txt`. Los originales de P7 no se recuperan (`zz-code/` no está en git).
  Los archivos de P7 llevan ahora un aviso al inicio. Los de este directorio son el snapshot del
  01:43 del 14/10, y no son el inventario de P7.
- `salidas/inventario-final-*.txt`: estado de Docker al cerrar T0. Ver §9.
- Nada de esto se copió al curso. Los documentos del curso solo llevan los comandos, no las salidas.

## 9. 🧹 Limpieza

- Contenedores: las pruebas usan `docker run --rm`, así que no queda ninguno. Verificado:
  `docker ps -aq --filter label=curso=react16` devuelve vacío al cerrar T0.
- Volúmenes: ninguno creado (`docker volume ls -q --filter label=curso=react16` vacío).
- Imagen nueva: `ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.4.2`. Se queda en la máquina; para
  quitarla, `docker rmi ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.4.2`.
- **Recursos ajenos al curso, no tocados.** Entre el inventario inicial y el final aparecieron
  `ev-lab` (postgres, kafka ×3, orders, inventory, payments, mail-sink) y `clinical-lab-amd64-app-1`,
  con sus volúmenes. Ninguno lleva la etiqueta del curso y ningún comando de esta sesión los nombra.
  Son de otra actividad de la máquina, como H12 de P7. No se actuó sobre ellos.

## 10. 🚫 Qué se dejó fuera

- `trabajo/paquete/node_modules`: no existe; `npm install --package-lock-only` no lo descarga. Se regenera
  con `npm ci` en `node:14.21.3` si hace falta.
- `trabajo/gomod/go.sum` lo escribe `go mod download`; se queda como registro.
- `trabajo/tags/repo/`: el repo de prueba. Lo recrea `prueba-tags.sh`.
- `trabajo/mermaid/alcance-rueda.svg`: se regenera con el paso 4 de §4.
