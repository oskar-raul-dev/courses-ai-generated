# Bitácora de ejecución · sesión 2c56f1ab-75fc-4f7e-a091-e4bef521ae0b

Comandos que ejecutaron código, con el inicio de su salida.

### ⏱️ 2026-09-09T03:26:40Z · Check A9 content to avoid contradiction

~~~~~~bash
cd .. && grep -n "^#\|^##\|Dockerfile\|docker\|compose" A9-entornos-y-contenedores.md | head -30
~~~~~~

~~~~~~text
1:# 🐳 Apéndice A9 — Entornos y contenedores
24:## 🧭 Índice de salto rápido
30:5. [Colima frente a Docker Desktop](#5-colima-frente-a-docker-desktop)
38:## 1. Cuándo necesitas un contenedor (y cuándo no)
62:## 2. Las siete vías de setup, comparadas
99:mismos comandos, el mismo `docker-compose.yml`. Lo que cambia es que trae GUI y
114:## 3. Colima arm64 — la opción por defecto en Apple Silicon
120:`Dockerfile.dev`:
122:```dockerfile
134:`docker-compose.yml`:
159:brew install colima docker docker-compose
161:docker compose up -d
162:docker compose exec react bash
163:# ya dentro del contenedor:
173:> hacen falta hoy. Están en el `Dockerfile.dev` como red por si alguna
180:## 4. Colima amd64 con vz-rosetta — paridad exacta con producción
189:Y en el `Dockerfile.dev` fijas la plataforma:
191:```dockerfile
210:## 5. Colima frente a Docker Desktop
213:runtime y los comandos `docker` y `docker compose` son idénticos. La elección es
232:## 6. Windows dentro de macOS
254:## 7. La regla del `node_modules`, la que más caro sale
260:El `docker-compose.yml` de §3 declara `node_modules` como **volumen nombrado**,
277:## 🧩 Cuándo usar qué
294:## 🧪 Ejercicios (8)
299:2. **🟢** Con el contenedor corriendo, ejecuta `docker compose exec react node -v`
302:3. **🟡** Levanta el servicio `mock` del `docker-compose.yml` y confirma que
307:   enciende el otro, levanta el mismo `docker compose up`. Documenta los pasos y
309:5. **🟠 Diagnóstico.** Cambia el `docker-compose.yml` para montar el
341:## 📚 Ref
~~~~~~

