# post: diseccion a03 del binario compilado y comparacion con el oficial; en node26 ademas pasada caliente real
set -u; V=$1; J=${2:-}; L=~/lab; exec > >(tee -a $L/post.log) 2>&1
B=$HOME/opt/node-$V/bin/node; export CCACHE_DIR=$HOME/.ccache
if [ -n "$J" ]; then
  echo "== caliente real -j$J"; cd ~/node-v$V; make clean >/dev/null 2>&1; ccache -z >/dev/null
  /usr/bin/time -v make -j$J CC="ccache gcc" CXX="ccache g++" > $L/make-caliente-real.log 2>&1; echo "exit=$?"
  grep -E "Elapsed \(wall|Maximum resident|Percent of CPU" $L/make-caliente-real.log; ccache -s | grep -iE "hit|miss" | head -3
fi
echo "== file"; file $B
echo "== readelf -h"; readelf -h $B | grep -E "Class|Machine|Type"
echo "== NEEDED"; readelf -d $B | grep NEEDED
echo "== GLIBC max"; readelf -V $B | grep -oE "GLIBC_[0-9.]+" | sort -uV | tail -3
echo "== versiones"; $B -p 'JSON.stringify({v8:process.versions.v8,openssl:process.versions.openssl,icu:process.versions.icu,temporal:typeof Temporal})'
echo "== strip"; cp $B /tmp/node-s; strip /tmp/node-s; du -h /tmp/node-s; /tmp/node-s --version
echo "== oficial"; cd /tmp; curl -fsSL https://nodejs.org/dist/v$V/node-v$V-linux-arm64.tar.xz | tar -xJ
O=/tmp/node-v$V-linux-arm64/bin/node; file $O; du -h $O; readelf -V $O | grep -oE "GLIBC_[0-9.]+" | sort -uV | tail -1
$O -p 'JSON.stringify({v8:process.versions.v8,openssl:process.versions.openssl,icu:process.versions.icu,temporal:typeof Temporal})'
echo "== fin post"
echo "== sonda CPU (mismo trabajo en las dos VM, un hilo)"
for i in 1 2 3; do s=$(date +%s.%N); head -c 2000000000 /dev/zero | sha256sum >/dev/null; e=$(date +%s.%N); echo "sha256 2GB: $(echo "$e - $s" | bc) s"; done
echo "== fin sonda"
