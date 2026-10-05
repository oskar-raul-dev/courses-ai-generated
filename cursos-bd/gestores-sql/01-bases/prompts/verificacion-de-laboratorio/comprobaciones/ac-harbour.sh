# P8 bloque A.C.: Harbour 3.2.0 compilado desde el fuente, y un .dbf con índice.
set -eu
apt-get update -qq >/dev/null
apt-get install -y -qq build-essential curl ca-certificates >/dev/null 2>&1
cd /tmp && curl -fsSL -o hb.tgz https://github.com/harbour/core/releases/download/v3.2.0/harbour-3.2.0.src.tar.gz
# el tarball no trae carpeta raíz: se extrae en una propia
mkdir -p hb && tar xzf hb.tgz -C hb && cd hb
make -j"$(nproc)" >/tmp/build.log 2>&1 && make install >/tmp/install.log 2>&1 || { tail -20 /tmp/build.log; exit 1; }
# make install deja libharbour en /usr/local/lib/harbour, fuera de la ruta del cargador
echo /usr/local/lib/harbour > /etc/ld.so.conf.d/harbour.conf && ldconfig
harbour -build 2>&1 | head -3
cd /tmp && cat > dbf.prg <<'PRG'
PROCEDURE Main()
   dbCreate( "student", { { "ID", "N", 4, 0 }, { "NAME", "C", 20, 0 } } )
   USE student NEW EXCLUSIVE
   APPEND BLANK ; REPLACE ID WITH 2, NAME WITH "Beatriz"
   APPEND BLANK ; REPLACE ID WITH 1, NAME WITH "Ana"
   INDEX ON ID TO student_id
   SEEK 2
   ? "SEEK 2 ->", FOUND(), AllTrim( NAME )
   GO TOP
   DO WHILE ! Eof()
      ? ID, NAME
      SKIP
   ENDDO
   CLOSE
   RETURN
PRG
hbmk2 -q dbf.prg >/dev/null 2>&1 || hbmk2 dbf.prg
./dbf; echo; ls -1 student*
