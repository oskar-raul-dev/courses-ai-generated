# 🧪 react-16-legacy-for-backend-devs-20261014-a728 · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tanda:** T2 (F03, incidentes 07–08, A9) · **Creado:** 2026-10-14

## Qué hay

- `esclusa-app/`: el repo del alumno, clonado desde `fase-02-autenticacion-minima` (rama `f03`). Tags `fase-00` a `fase-03`. Rama `incidente/07` (sin timeout).
- `trabajo/`: pruebas y plantillas de la fase: `F03.pagos.test.js` (pagos #1 y #2, y el 5xx), `incidentes/inc07.test.js`, `F03-plantilla.md` y `render_f03.py` (el documento se genera con los bloques de los archivos probados), `db.inicial.json` (la semilla de la base, para restaurarla antes de cada corrida).
- `salidas/`: registros de las comprobaciones.
- `verificacion-a-mano-T2.md`: lo que mira el autor en el navegador.

## Resultados de referencia (14/10/2026)

- Giro ingenuo, tres corridas con `PAUSA_MS=2` y base restaurada: 1.008 / 1.010 / 1.020 premios; 504 / 505 / 510 claves con dos premios; stock excedido 8 / 10 / 20.
- Caos alto con 60 claves (semilla 7): 99 de 200 respuestas 200, 8 de 401, 12 de 503 y 1 sin respuesta.
- Google Play: compra en efectivo `pending` y luego `confirmed` tras la demora; notificación duplicada llega dos veces.

## Cómo se corre

```bash
# dependencias (una vez) y pruebas de pagos con el mock real
docker run --rm --label curso=react16 -v "$PWD":/app -w /app node:14.21.3 sh -c 'npm ci'
# el mock y las pruebas en contenedores separados (las pruebas esperan 200 peticiones colgadas)
MOCK=$(docker run -d --rm --label curso=react16 -v "$PWD":/app -w /app -e CHAOS_LEVEL=high -e CHAOS_SEED=11 node:14.21.3 node mock/server.js)
docker run --rm --label curso=react16 --network container:$MOCK -v "$PWD":/app -w /app -e CI=true node:14.21.3 sh -c 'npx react-scripts test --watchAll=false --forceExit src/__incidentes__/inc07'
docker kill $MOCK
```

## Limpieza

- Contenedores: `docker run --rm` y `docker kill` del mock. Verificar con `docker ps -aq --filter label=curso=react16`.
- Imágenes nuevas: ninguna en T2 (`node:14.21.3` ya estaba).
- Recursos ajenos al curso, sin tocar: `ev-lab` y `clinical-lab` de sesiones anteriores.

## Qué se dejó fuera

- `node_modules/` y `build/` del repo del alumno (regenerables con `npm ci`).
- `src/__incidentes__/` (excluido de git en `.git/info/exclude`).
- Pendiente a mano: `verificacion-a-mano-T2.md`.
