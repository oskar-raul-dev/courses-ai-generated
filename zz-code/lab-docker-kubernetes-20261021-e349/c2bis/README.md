# C2-bis · Pendientes de C2 en el cluster `lab` (24/10/2026)

Pruebas de la tanda C2-bis del plan de cierre de `lab-docker-kubernetes`: lo que C2 dejó pendiente y se podía
correr sin ampliar la VM. Hallazgos H372–H375 en `prompts/verificacion-de-laboratorio/hallazgos.md` del curso.

## Qué hay

- `pdb-inventory.yaml`: el PDB del ejercicio 22 de la F16 (`minAvailable: 1`).
- `logs/00-inventario-apertura.txt` y `logs/99-inventario-cierre.txt`: Docker antes y después.
- `logs/f10-8-proxy-en-worker.log`: la rotura de la F10 §8 (H372).
- `logs/f16-ej22-pdb.log`: el drain con una y dos réplicas (H373).
- `logs/f24-4-2-dos-bases.log` y `logs/f24-4-compose.log`: la F24 §4 (H374).

## Cómo se corrió

Sobre el cluster `lab` de C2 (tres nodos, valores `minimo`, G13 desplegado) y el repositorio de la pasada
`../mi-lab/src/lab/` como directorio de trabajo para compose:

1. `docker start lab-registry lab-control-plane lab-worker lab-worker2`, y esperar los pods.
2. F10 §8: `kubectl -n gateway patch envoyproxy nodeport --type merge` con `externalTrafficPolicy` en `Local` y
   de vuelta en `Cluster`, con tres `curl` a `api.localhost:8080/pricing/health/live` en cada estado.
3. F16 ej. 22: `kubectl apply -f pdb-inventory.yaml`; `kubectl drain <nodo> --pod-selector=app.kubernetes.io/name=inventory
   --ignore-daemonsets --delete-emptydir-data`, con una réplica y con dos (`kubectl scale`); después `uncordon`, una
   réplica y el PDB borrado.
4. F24 §4: `docker compose -f compose/compose.yaml --profile legacy up -d contingencia-db contingencia`, los `SELECT`
   del texto con `psql`, la carpeta de traslados en 555 y de vuelta en 755, y `task legacy:down` (sin `-v`).

## Estado al cerrar

Cluster `lab` y `lab-registry` arriba para O1, con los nodos en `restart=no`. `inventory` quedó escalado con
`kubectl scale` (una réplica), así que el próximo `task deploy` va con `FORCE=true`.
