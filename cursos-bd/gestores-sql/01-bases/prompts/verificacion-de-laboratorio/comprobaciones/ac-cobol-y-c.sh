# P8 bloque A.C.: GnuCOBOL con un archivo INDEXED, Harbour y GCC en modo ANSI C.
set -u
. /etc/os-release; echo "### $PRETTY_NAME · $(uname -m)"
apt-get update -qq >/dev/null
apt-cache policy gnucobol gnucobol3 gnucobol4 harbour gcc 2>/dev/null | grep -E '^[a-z0-9]|Candidate'
apt-get install -y -qq gnucobol gcc >/dev/null 2>&1
cobc --version | head -1
cobc --info | grep -iE 'indexed|isam|BDB|LMDB' | head -4
cd /tmp && cat > idx.cob <<'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. IDX.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT STUDENT-FILE ASSIGN TO "student.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS STUDENT-ID.
       DATA DIVISION.
       FILE SECTION.
       FD STUDENT-FILE.
       01 STUDENT-REC.
          05 STUDENT-ID   PIC 9(4).
          05 STUDENT-NAME PIC X(20).
       PROCEDURE DIVISION.
           OPEN OUTPUT STUDENT-FILE
           MOVE 2 TO STUDENT-ID MOVE "Beatriz" TO STUDENT-NAME
           WRITE STUDENT-REC
           MOVE 1 TO STUDENT-ID MOVE "Ana" TO STUDENT-NAME
           WRITE STUDENT-REC
           CLOSE STUDENT-FILE
           OPEN INPUT STUDENT-FILE
           MOVE 2 TO STUDENT-ID
           READ STUDENT-FILE KEY IS STUDENT-ID
           DISPLAY "LEIDO POR CLAVE: " STUDENT-NAME
           CLOSE STUDENT-FILE
           STOP RUN.
COB
cobc -x idx.cob && ./idx
cat > ansi.c <<'C'
#include <stdio.h>
int main(void) {
    int count = 0;  /* declaración al inicio del bloque, como exige C89 */
    for (count = 0; count < 3; count++) printf("%d ", count);
    printf("\n");
    return 0;
}
C
gcc --version | head -1
gcc -std=c89 -pedantic -Wall -Wextra -Werror ansi.c -o ansi && ./ansi && echo "c89 sin advertencias"
printf 'int main(void) { for (int i = 0; i < 1; i++) {} // comentario C99\nreturn 0; }\n' > c99.c
gcc -std=c89 -pedantic -Wall -Wextra c99.c -o c99 2>&1 | grep -E 'error|warning' | head -3
