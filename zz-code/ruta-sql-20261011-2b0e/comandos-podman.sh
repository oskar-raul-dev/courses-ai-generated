#!/usr/bin/env bash
# SQL Server 2025 under Rosetta in Podman (P8). Creates a throwaway machine and removes it at the end:
#   ./comandos-podman.sh crear | probar | borrar
# PROVIDER=applehv to get Rosetta (Podman 6 on macOS defaults to libkrun, which has no Rosetta).
set -uo pipefail
cd "$(dirname "$0")"
M=ruta-sql-p8
export CONTAINERS_MACHINE_PROVIDER="${PROVIDER:-libkrun}"
# ROSETTA=1 adds podman-rosetta.conf through CONTAINERS_CONF_OVERRIDE (the user's containers.conf is not touched).
[ "${ROSETTA:-0}" = 1 ] && export CONTAINERS_CONF_OVERRIDE="$PWD/podman-rosetta.conf"
IMG=mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04
case "$1" in
  crear)  podman machine init "$M" --cpus 4 --memory 6144 --disk-size 40 --now
          podman machine inspect "$M" | grep -i -m3 '"VMType"\|Rosetta\|"State"'
          podman --connection "$M" info --format 'arch={{.Host.Arch}} kernel={{.Host.Kernel}} mem={{.Host.MemTotal}}' ;;
  probar) podman --connection "$M" pull -q --platform linux/amd64 "$IMG"
          inicio=$(date +%s)
          podman --connection "$M" run -d --name ruta-sql-p8-mssql --label curso=ruta-sql --platform linux/amd64 \
            -e ACCEPT_EULA=Y -e MSSQL_PID=Developer -e 'MSSQL_SA_PASSWORD=Lab-2026-pass' -p 127.0.0.1::1433 "$IMG"
          for _ in $(seq 1 300); do
            podman --connection "$M" exec ruta-sql-p8-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa \
              -P 'Lab-2026-pass' -Q 'select 1' -b -o /dev/null 2>/dev/null && break
            [ "$(podman --connection "$M" inspect -f '{{.State.Status}}' ruta-sql-p8-mssql)" = "exited" ] && break
            sleep 1
          done
          echo "listo a los $(( $(date +%s) - inicio ))s"
          sleep 60
          podman --connection "$M" stats --no-stream --format '{{.Name}} {{.MemUsage}}' ruta-sql-p8-mssql
          podman --connection "$M" logs ruta-sql-p8-mssql > salidas/logs/sqlserver-podman.log 2>&1
          grep -m2 "Microsoft SQL Server 2025\|ready for client" salidas/logs/sqlserver-podman.log
          podman --connection "$M" exec -i ruta-sql-p8-mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa \
            -P 'Lab-2026-pass' -W -s '|' < funciones/sqlserver-2025.sql ;;
  borrar) podman machine stop "$M"; podman machine rm -f "$M"; podman machine list ;;
esac
