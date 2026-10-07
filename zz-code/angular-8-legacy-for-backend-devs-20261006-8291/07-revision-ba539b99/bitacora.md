# Bitácora de ejecución · sesión ba539b99-1109-4792-8e3e-93ac9d2547da

Comandos que ejecutaron código, con el inicio de su salida.

### ⏱️ 2026-09-11T03:41:36Z · Confirm heading texts for broken anchors

~~~~~~bash
grep -n "Advertencias" a01-material.md a02-bootstrap-sass.md a03-node-npm.md a04-webpack-oculto.md | grep "^.*:##"; echo ---; grep -nE "^## 6\.|^## 5\." a07-i18n.md a13-docker-colima.md; echo ---; grep -n "Ejercicios (" bea-01*.md bea-11*.md | grep "##"
~~~~~~

~~~~~~text
a01-material.md:570:## ⚠️ Advertencias
a04-webpack-oculto.md:420:## ⚠️ Advertencias
a02-bootstrap-sass.md:397:## ⚠️ Advertencias
a03-node-npm.md:573:## ⚠️ Advertencias
---
a13-docker-colima.md:151:## 5. Volúmenes: dónde vive `node_modules`
a13-docker-colima.md:177:## 6. Un devcontainer para este proyecto
a07-i18n.md:230:## 5. Pluralización: tres estrategias y en qué idioma se rompe cada una
a07-i18n.md:275:## 6. Locales y formatos: `LOCALE_ID`, fechas, números y zona horaria
---
bea-01-java-8-y-spring-para-quien-no-escribe-java.md:442:## 🧪 Ejercicios (10)
bea-11-mapa-de-deuda-del-track-be.md:155:## 🧪 Ejercicios (6)
~~~~~~

### ⏱️ 2026-09-11T03:41:43Z · Byte-level inspect anchor mismatches

~~~~~~bash
sed -n '22p' a07-i18n.md | cat -A | head -2; echo ---; sed -n '275p' a07-i18n.md | cat -A; echo ---; sed -n '38p' a13-docker-colima.md | cat -A; echo ---; sed -n '151p' a13-docker-colima.md | cat -A
~~~~~~

~~~~~~text
Exit code 1
cat: illegal option -- A
usage: cat [-belnstuv] [file ...]
---
cat: illegal option -- A
usage: cat [-belnstuv] [file ...]
---
cat: illegal option -- A
usage: cat [-belnstuv] [file ...]
---
cat: illegal option -- A
usage: cat [-belnstuv] [file ...]
~~~~~~

### ⏱️ 2026-09-11T15:15:31Z · Check for docker-compose in phase 13

~~~~~~bash
grep -n "docker compose\|docker-compose" 13-build-despliegue.md | head -8; echo "--- si vacío: la fase usa docker run"
~~~~~~

~~~~~~text
--- si vacío: la fase usa docker run
~~~~~~

### ⏱️ 2026-09-11T15:15:57Z · Fix incident 19 remediation command

~~~~~~bash
python3 - <<'PY'
f='cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""```bash
# Relevantar el contenedor con las variables correctas. Nada que compilar,
# nada que desplegar: es la misma imagen.
docker compose -f docker-compose.prod.yml up -d --force-recreate lab-frontend-prod
docker logs lab-frontend-prod | head -1
# [entrypoint] config generada para ambiente: prod -> http://prod.interno:3000
```"""
new="""```bash
# Relevantar el contenedor con las variables correctas. Nada que compilar,
# nada que desplegar: es exactamente la misma imagen.
docker rm -f lab-frontend-prod
docker run -d --name lab-frontend-prod -p 8080:80 \\
  -e API_URL=http://prod.interno:3000 \\
  -e ENVIRONMENT_NAME=prod \\
  -e APP_TIME_ZONE=America/Bogota \\
  -e FEATURE_DELIVERY_PDF=true \\
  lab-frontend:inc19

docker logs lab-frontend-prod | head -1
# [entrypoint] config generada para ambiente: prod -> http://prod.interno:3000
```"""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY
grep -n "docker compose\|docker-compose" cuaderno-incidentes.md | head
~~~~~~

~~~~~~text
ok
4526:`docker-compose.yml` de un servidor, o en un panel, o en la memoria de quien
~~~~~~

