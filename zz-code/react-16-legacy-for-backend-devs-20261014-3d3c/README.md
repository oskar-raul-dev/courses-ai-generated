# 🧪 react-16-legacy-for-backend-devs-20261014-3d3c · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tanda:** T1 (cerrada; la verificación a mano queda con el autor) · **Creado:** 2026-10-14
> **Propósito:** construir el repo del alumno `esclusa-app` fase por fase (F00–F02), reproducir los incidentes 01–06 en sus ramas, y probar lo que los documentos afirman. Las reglas, en `zz-code/README.md` § "El README de cada directorio".

## 1. 🎯 Qué se prueba y para qué

| Prueba | Documento | Qué comprueba |
|---|---|---|
| F00: `npm ci`, build, render, dev server | `00-setup-hola-mundo-cra.md` | El andamiaje a mano arranca con React 16.14.0 y react-scripts 4.0.3 en `node:14.21.3` |
| F01: rutas y navegación sin recarga | `01-estructura-base-router-5.md` | Cinco rutas, 404, `AppLayout` persistente, clic en tarjeta sin recargar el navbar |
| F02: auth contra el mock real | `02-autenticacion-minima.md` | Login, error legible, `Authorization` tras login, `X-Request-Id`, logout, guarda de rutas |
| Incidentes 01–06 | `cuaderno-incidentes.md` | Cada rama reproduce su síntoma (prueba roja) y la corrección lo quita (prueba verde) |
| Comparación de bloques | los tres `.md` | Los bloques de código del documento son los archivos probados |

No alimenta ninguna cifra del curso.

## 2. 🛠️ Prerrequisitos

- macOS arm64, Docker 29.8.0. Nada instalado en el host.
- Imágenes: `node:14.21.3` (base de todas las pruebas), `node:20` (incidente 01), `ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.4.2` (T0).
- Estado previo: repo `esclusa-app/` con tags `fase-00-setup-hola-mundo-cra`, `fase-01-estructura-base-router-5`, `fase-02-autenticacion-minima`; ramas `incidente/01` … `incidente/06` en el estado roto.
- Inventario inicial de Docker en `salidas/inventario-inicial-*.txt`.

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
```

Todo contenedor lleva `--label curso=react16`. Ninguno publica puertos al host, salvo el dev server de F00, que se liga a un puerto aleatorio de `127.0.0.1`.

## 4. ▶️ Cómo se corre

Desde `esclusa-app/`, con `esclusa-app` en la rama que corresponda:

```bash
# Dependencias (una vez por rama)
docker run --rm --label curso=react16 -v "$PWD":/app -w /app node:14.21.3 sh -c 'npm ci'

# Build de cualquier fase
docker run --rm --label curso=react16 -v "$PWD":/app -w /app -e CI=true node:14.21.3 sh -c 'npm run build'

# Pruebas de un incidente: la prueba va a src/__incidentes__ (excluido de git)
sh ../trabajo/incidentes/correr.sh inc03.test.jsx "$PWD"     # desde esclusa-app/
```

Las pruebas de regresión están en `trabajo/incidentes/` (`inc03.test.jsx`, `inc04.test.jsx`, `inc05.test.js`, `inc06.test.jsx`). Las de F01 y F02 están en `trabajo/` y se copian a `src/` para correrlas.

## 5. 📏 Cómo se mide

No hay mediciones en esta tanda. Son pruebas de contenido: una prueba pasa o no, y un build compila o no. Las pruebas de render usan jsdom y React Testing Library 11 (las versiones de la plantilla de CRA 4).

## 6. 🧮 Los intermedios que amasan la salida

- `correr.sh` filtra la salida de Jest a las líneas `Tests:`, `✓`, `✕`, `Expected` y `Received`.
- `comparar-bloques.py` normaliza espacios al final de línea y quita la línea `// src/…` o `// mock/…` que el documento pone como encabezado.
- `npm install` reescribe `package.json` al instalar (ordena y formatea); por eso el comparador de F00 compara el JSON, no el texto.

## 7. ✅ Qué se espera ver

| Prueba | Resultado de referencia (14/10/2026) | Registro |
|---|---|---|
| F00 `npm ci` + build | `CI_Y_BUILD_OK`, `npm 6.14.18` | `salidas/f00-npm-ci.log` |
| F00 render | 1 de 1 | `salidas/f00-test-render-final.log` |
| F00 dev server | HTTP 200 en el puerto aleatorio; `#06c` en el CSS (el token `#0066cc`) | `salidas/f00-start-logs.txt` |
| F01 rutas | 5 de 5 | `salidas/f01-rutas-tests.log` |
| F02 auth | 5 de 5 contra json-server | `salidas/f02-tests.log` |
| Comparación F00/F01/F02 | `todo idéntico: True` | `salidas/f01-comparacion-doc-vs-probado.log`, `salidas/f02-comparacion-doc-vs-probado.log` |
| Incidente 01 | con Node 20: `ERR_OSSL_EVP_UNSUPPORTED`; con 14.21.3: `Compiled successfully` | en la conversación de la sesión |
| Incidente 03 | con el bug: `Expected "/wheels" Received "/"`; con la corrección: pasa | en la conversación de la sesión |
| Incidente 04 | con el bug: `Expected "Semana del Canal" Received "Esclusa de Oro"`; con la corrección: pasa | en la conversación de la sesión |
| Incidente 05 | con el bug: `Received undefined` en el header; con la corrección: pasa | en la conversación de la sesión |
| Incidente 06 | con el bug: el nombre sigue en la barra; con la corrección: pasa | en la conversación de la sesión |
| Incidente 02 | **parcial**: `node-sass` 4.14.1 compila en `node:14` arm64 con Python 2 | — |

## 8. 📂 Salidas

- `salidas/`: registros de cada comprobación de F00, F01 y F02, y de las instalaciones (`f00-*`, `f01-*`, `f02-*`, `rehacer-*`).
- `salidas/inventario-inicial-*.txt`: el inventario de Docker al empezar esta tanda. **Aviso:** el 14/10 a las 01:43 se sobrescribió por error el inventario inicial de P7 (`zz-code/…-f462/salidas/inventario-inicial-*.txt`) con este snapshot. Los originales de P7 no se recuperan; cada archivo de P7 lleva ahora un aviso.
- `salidas/tags-previos-al-rehacer.txt`: las etiquetas que existían antes de rehacer el historial de F01 y F02.
- `esclusa-app/`: el repo del alumno. El historial previo (con `App.js` de más en F01 y F02) está en la rama `historial-previo`.

## 9. 🧹 Limpieza

- Contenedores: las pruebas usan `docker run --rm`. Verificar al cerrar: `docker ps -aq --filter label=curso=react16` debe dar vacío.
- Volúmenes: ninguno creado por esta tanda.
- Imágenes nuevas: `node:20` y `mermaid-cli:11.4.2`; se quedan en la máquina (`docker rmi` las quita).
- **Recursos ajenos, no tocados.** `ev-lab` (postgres, kafka ×3, orders, inventory, payments, mail-sink) y `clinical-lab-amd64-app-1` aparecieron durante la sesión anterior y siguen ahí. Ningún comando de esta sesión los nombra.
- `esclusa-app/node_modules` y `build/` están ignorados por git y se regeneran con `npm ci` y `npm run build`.

## 10. 🚫 Qué se dejó fuera

- `esclusa-app/node_modules/` y `esclusa-app/build/`: regenerables con `npm ci` y `npm run build` en `node:14.21.3`.
- `esclusa-app/src/__incidentes__/`: las pruebas copiadas para cada incidente. Está excluido de git en `.git/info/exclude`; no entra en ningún commit.
- Apéndices A1, A2 y A5: los bloques de SCSS compilan con dart-sass (`a1/`, `a2/`); la pareja de clase y hooks de A5 renderiza igual (`esclusa-app/src/__incidentes__/a5.test.jsx`).
- Pendiente a mano (el autor): ver `verificacion-a-mano-T1.md`.
