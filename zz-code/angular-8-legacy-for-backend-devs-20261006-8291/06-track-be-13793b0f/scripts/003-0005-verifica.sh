# rescatado de la sesión 13793b0f, 2026-09-11T00:05:19Z · Check Testcontainers bytecode target version
cd /tmp && for v in 1.21.4 1.19.8 1.17.6; do curl -s --max-time 40 -o tc-$v.jar "https://repo1.maven.org/maven2/org/testcontainers/testcontainers/$v/testcontainers-$v.jar" && python3 -c "
import zipfile,sys
v='$v'
z=zipfile.ZipFile('tc-'+v+'.jar')
n=[x for x in z.namelist() if x.endswith('GenericContainer.class')][:1]
d=z.read(n[0])[:8]
major=int.from_bytes(d[6:8],'big')
print(v, 'class major', major, '-> Java', major-44)
"; done
