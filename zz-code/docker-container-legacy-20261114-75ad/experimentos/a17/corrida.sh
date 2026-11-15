#!/usr/bin/env bash
# corrida.sh NOMBRE PLANTILLA NODE_VERSION VMTYPE — crea la VM, corre el guion y trae los logs
N=$1; T=$2; V=$3; VT=${4:-vz}; Z=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/docker-container-legacy-20261114-75ad; O=$Z/logs/P6/$N; mkdir -p $O
{ echo "== host"; uname -m; sw_vers | head -2; sysctl -n hw.ncpu hw.memsize; limactl --version
s=$(date +%s); limactl start --tty=false --name=$N --cpus=8 --memory=12 --disk=60 --vm-type=$VT template:$T > $O/start.log 2>&1; echo "limactl start (vmType $VT) exit=$? en $(( $(date +%s)-s )) s"
limactl list $N; limactl shell $N uname -a; limactl shell $N cat /etc/debian_version; } > $O/host.log 2>&1
limactl copy $Z/experimentos/a17/guion.sh $N:/tmp/guion.sh
s=$(date +%s); limactl shell $N env NODE_VERSION=$V bash /tmp/guion.sh > $O/guion-stdout.log 2>&1; echo "guion en $(( $(date +%s)-s )) s" >> $O/host.log
limactl copy -r $N:lab $O/vm-lab 2>>$O/host.log
echo fin >> $O/host.log
