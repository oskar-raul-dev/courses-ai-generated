Z=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/docker-container-legacy-20261114-75ad; O=$Z/logs/P6/p6-node14; mkdir -p $O
until grep -q "^j5 en" $Z/logs/P6/p6-node26/j5-stdout.log 2>/dev/null; do sleep 30; done
limactl stop p6-node26 >/dev/null 2>&1; s=$(date +%s); limactl start p6-node14 > $O/start.log 2>&1; echo "start exit=$? en $(( $(date +%s)-s )) s" > $O/host.log
limactl copy $Z/experimentos/a17/fix-bullseye.sh p6-node14:/tmp/; limactl copy $Z/experimentos/a17/guion.sh p6-node14:/tmp/
limactl shell --workdir / p6-node14 bash /tmp/fix-bullseye.sh > $O/fix.log 2>&1
s=$(date +%s); limactl shell --workdir / p6-node14 env NODE_VERSION=14.21.3 bash /tmp/guion.sh > $O/guion-stdout.log 2>&1; echo "guion en $(( $(date +%s)-s )) s" >> $O/host.log
limactl copy -r p6-node14:lab $O/vm-lab 2>>$O/host.log; echo fin >> $O/host.log
