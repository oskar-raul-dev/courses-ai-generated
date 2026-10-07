# rescatado de la sesión 8654ffa2, 2026-09-09T04:05:25Z · Verify paths and scripts before writing
echo "=== store path curso 01 ===" && grep -rhoE 'src/store[a-zA-Z0-9/._-]*' 01-vue2-legacy/*.md | sort | uniq -c | sort -rn | head -8
echo "=== services path ===" && grep -rhoE 'src/services[a-zA-Z0-9/._-]*' 01-vue2-legacy/*.md | sort | uniq -c | sort -rn | head -5
echo "=== scripts npm curso 02 (seed) ===" && grep -rn '"seed"\|npm run seed\|scripts/seed' 02-complement-mongodb-backend/*.md | head -5
echo "=== 14-operacion: imagen docker ===" && grep -n -i 'docker build\|:latest\|image:' 02-complement-mongodb-backend/14-operacion.md | head -8
echo "=== a01-docker nombre ===" && head -3 02-complement-mongodb-backend/a01-docker.md
