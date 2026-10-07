# Bitácora de ejecución · sesión 8654ffa2-c3be-4e38-8c48-f270a0c7e8e8

Comandos que ejecutaron código, con el inicio de su salida.

### ⏱️ 2026-09-09T04:05:25Z · Verify paths and scripts before writing

~~~~~~bash
echo "=== store path curso 01 ===" && grep -rhoE 'src/store[a-zA-Z0-9/._-]*' 01-vue2-legacy/*.md | sort | uniq -c | sort -rn | head -8
echo "=== services path ===" && grep -rhoE 'src/services[a-zA-Z0-9/._-]*' 01-vue2-legacy/*.md | sort | uniq -c | sort -rn | head -5
echo "=== scripts npm curso 02 (seed) ===" && grep -rn '"seed"\|npm run seed\|scripts/seed' 02-complement-mongodb-backend/*.md | head -5
echo "=== 14-operacion: imagen docker ===" && grep -n -i 'docker build\|:latest\|image:' 02-complement-mongodb-backend/14-operacion.md | head -8
echo "=== a01-docker nombre ===" && head -3 02-complement-mongodb-backend/a01-docker.md
~~~~~~

~~~~~~text
=== store path curso 01 ===
   4 src/store/
   3 src/store/index.js
   2 src/store
=== services path ===
   4 src/services/activityService.js
   2 src/services/activityEmitter.js
   1 src/services/
=== scripts npm curso 02 (seed) ===
02-complement-mongodb-backend/02-consultar-tu-sql-traducido.md:364:`npm run seed`). Para los que piden volumen, usa el generador del ejercicio
02-complement-mongodb-backend/01-mongo-en-30-min.md:252:### `scripts/seed.js`
02-complement-mongodb-backend/01-mongo-en-30-min.md:424:node scripts/seed.js
02-complement-mongodb-backend/01-mongo-en-30-min.md:514:11. Modifica el seed para que reciba la ruta del `db.json` como argumento de línea de comandos (`node scripts/seed.js ./data/db.json`), con mensaje de uso si falta.
02-complement-mongodb-backend/01-mongo-en-30-min.md:532:26. Empaqueta el seed como comando npm (`npm run seed`) y agrega `npm run seed:verify` que encadene seed + verify. Deja el README con las 4 líneas exactas para que otra persona levante todo desde cero.
=== 14-operacion: imagen docker ===
243:    image: mongo:${MONGO_VERSION:-4.4}
270:    image: mongo:${MONGO_VERSION:-4.4}
=== a01-docker nombre ===
# 🐳 Apéndice 1 — Docker mínimo

## 🎯 Para qué sirve este apéndice
~~~~~~

### ⏱️ 2026-09-09T04:05:30Z · Check phase 14 and docker usage

~~~~~~bash
grep -n '^#\{2,3\} ' 02-complement-mongodb-backend/14-operacion.md && echo "=== Dockerfile/build en curso 02 ===" && grep -rn 'Dockerfile\|docker build\|docker compose up\|MONGO_VERSION' 02-complement-mongodb-backend/*.md | head -12
~~~~~~

~~~~~~text
3:## 🎯 Propósito
20:## ✅ Qué queda listo al terminar
38:## 🚫 Qué NO entra todavía
56:## 🧠 El oplog en 60 segundos (tu redo log, con otro collar)
97:### 🩻 Esto SÍ funciona igual
107:## 💾 Backups de operación (la Fase 0, ascendida)
109:### El backup en caliente y consistente
126:### La política, no el comando
141:### Point-in-time, ensayado (el laboratorio estrella: ejercicio 22)
151:## ⚡ Índices en producción: la buena noticia de 4.4
183:## 🔍 El profiler: tu Slow Query Log, reencontrado
220:### La guardia: mongostat, mongotop, currentOp, killOp
235:## 🐳 El compose final: el sistema, empaquetado
295:## 🧩 Chuleta de la fase
321:## ⚠️ Errores comunes
342:## 🧪 Ejercicios (34)
392:## 📚 Referencias
437:## 🚀 Cierre
=== Dockerfile/build en curso 02 ===
02-complement-mongodb-backend/01-mongo-en-30-min.md:161:docker compose up -d
02-complement-mongodb-backend/01-mongo-en-30-min.md:463:docker compose up -d
02-complement-mongodb-backend/00-preliminares.md:83:    image: mongo:${MONGO_VERSION:-4.4}
02-complement-mongodb-backend/00-preliminares.md:97:MONGO_VERSION=4.4
02-complement-mongodb-backend/00-preliminares.md:107:docker compose up -d          # levantar
02-complement-mongodb-backend/00-preliminares.md:419:docker compose up -d
02-complement-mongodb-backend/00-preliminares.md:438:docker compose up -d / down / ps / logs -f mongo
02-complement-mongodb-backend/14-operacion.md:243:    image: mongo:${MONGO_VERSION:-4.4}
02-complement-mongodb-backend/14-operacion.md:270:    image: mongo:${MON
~~~~~~

