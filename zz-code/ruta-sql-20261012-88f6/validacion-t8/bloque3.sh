#!/usr/bin/env bash
# Validación del cierre del Bloque III: corre F15 a F18 en orden, como un lector, sobre el laboratorio arriba.
# Uso: ./bloque3.sh > bloque3.out 2>&1   (el avance va a bloque3-progreso.txt)
set -uo pipefail
cd "$(dirname "$0")/.."
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
P=validacion-t8/bloque3-progreso.txt; : > $P
pg() { docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda -q -v ON_ERROR_STOP=1 < "$SRC/$1"; }
my() { docker exec -i alameda-lab-mysql-1 mysql -uroot -plab < "$SRC/$1" 2>&1 | grep -v Warning; }
race() { echo "== race $*" | tee -a $P; ./lab-en-contenedor.sh race -f "$@"; }
py() { echo "== py $*" | tee -a $P; ./correr-src.sh "$@"; }
echo "== F15" | tee -a $P
pg 15-aislamiento-comparado/01_setup.sql; my 15-aislamiento-comparado/01_setup_mysql.sql
for i in read-committed repeatable-read serializable; do race 15-aislamiento-comparado/write_skew.race --isolation $i; race 15-aislamiento-comparado/write_skew_mysql.race --isolation $i; done
race 15-aislamiento-comparado/lost_update.race --isolation repeatable-read
race 15-aislamiento-comparado/lost_update_mysql.race --isolation repeatable-read
race 15-aislamiento-comparado/current_read_mysql.race
race 15-aislamiento-comparado/locking_check.race --isolation repeatable-read
race 15-aislamiento-comparado/locking_check_mysql.race
race 15-aislamiento-comparado/read_only.race --isolation serializable
py 15-aislamiento-comparado/matrix.py
py 15-aislamiento-comparado/technicians.py
echo "== F16" | tee -a $P
pg 16-el-folio-sin-huecos/01_setup.sql; my 16-el-folio-sin-huecos/01_setup_mysql.sql
for s in dmax ultimo_numero sequence counter lost_response reconcile; do py 16-el-folio-sin-huecos/races.py $s; done
race 16-el-folio-sin-huecos/counter_mysql.race; race 16-el-folio-sin-huecos/get_lock_mysql.race
py 16-el-folio-sin-huecos/cajas.py --design counter --invoices 10000
for d in counter at_authorization; do py 16-el-folio-sin-huecos/cajas.py --design $d --invoices 1500 --hold 0.010; done
echo "== F17" | tee -a $P
for s in counter results para_llamar; do py 17-mvcc-y-su-factura/mvcc.py $s; done
py 17-mvcc-y-su-factura/mysql_history.py
echo "== F18" | tee -a $P
pg 18-bloqueos-deadlocks-y-ddl/01_setup.sql
for r in lunch_form lunch_form_timeout optimistic deadlock ddl_queue ddl_lock_timeout deadlock_mysql lock_wait_timeout_mysql ddl_queue_mysql ddl_lock_timeout_mysql; do race 18-bloqueos-deadlocks-y-ddl/$r.race; done
py 18-bloqueos-deadlocks-y-ddl/ddl_rewrite.py
py 18-bloqueos-deadlocks-y-ddl/ten_am.py
pg 18-bloqueos-deadlocks-y-ddl/boss/01_july.sql
py 18-bloqueos-deadlocks-y-ddl/boss/afternoon.py
echo "== listo" | tee -a $P
