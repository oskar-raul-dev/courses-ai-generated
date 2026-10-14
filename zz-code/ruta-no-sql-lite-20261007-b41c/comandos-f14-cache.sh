# F14 §4.6: la travesía en frío de verdad. Antes de cada corrida, se vacía la caché de archivos de la VM de
# Docker con un contenedor privilegiado de un solo uso, con la imagen de base que ya está (no borra datos). Desde src/ del curso.
drop_caches() { docker run --rm --privileged --label curso=ruta-no-sql-lite pgvector/pgvector@sha256:2ba9ca5f2e7daa0f0e7723cba1ee9167bab54efd3640516a44ac1a928dd67e7a sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'; }
for v in 256 64; do
  if [ $v = 64 ]; then docker compose -f lab/compose.yaml -f 14-grafos-romper-y-medir/compose.pagecache-64m.yaml up -d --wait --force-recreate grafos >/dev/null 2>&1
  else docker compose -f lab/compose.yaml up -d --wait --force-recreate grafos >/dev/null 2>&1; fi
  drop_caches
  node 14-grafos-romper-y-medir/cache.ts
done
docker compose -f lab/compose.yaml up -d --wait --force-recreate grafos >/dev/null 2>&1
