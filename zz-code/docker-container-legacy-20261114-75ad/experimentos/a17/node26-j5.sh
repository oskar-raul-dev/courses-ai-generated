# repetición de la corrida 3 tras el OOM: -j5 (≈2 GB por cc1plus en 11 GiB útiles)
set -u; L=~/lab; cd ~/node-v26.13.1 || exit 1; exec > >(tee -a $L/j5.log) 2>&1
export CCACHE_DIR=$HOME/.ccache
echo "== j5-frío (ccache desactivado)"; make clean >/dev/null 2>&1
CCACHE_DISABLE=1 /usr/bin/time -v make -j5 > $L/make-j5-frio.log 2>&1; echo "exit=$?"; grep -E "Elapsed \(wall|Maximum resident" $L/make-j5-frio.log; grep -E "fatal error|Killed" $L/make-j5-frio.log | head -3
echo "== j5-caliente (ccache)"; make clean >/dev/null 2>&1; ccache -z >/dev/null
/usr/bin/time -v make -j5 CC="ccache gcc" CXX="ccache g++" > $L/make-j5-caliente.log 2>&1; echo "exit=$?"; grep -E "Elapsed \(wall|Maximum resident" $L/make-j5-caliente.log; ccache -s | grep -iE "hits|misses" | head -2
echo "== instalar"; make install -j5 > $L/install.log 2>&1; echo "install exit=$?"
~/opt/node-26.13.1/bin/node --version; file ~/opt/node-26.13.1/bin/node; du -sh ~/opt/node-26.13.1/bin/node; ls -la ~/node-v26.13.1/out/Release/node | awk '{print $5}'
sudo dmesg | grep -c "Killed process"; du -sh ~/node-v26.13.1 ~/.ccache
echo "== fin j5"
