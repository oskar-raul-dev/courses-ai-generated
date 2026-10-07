# rescatado de la sesión 13793b0f, 2026-09-11T03:55:32Z · Check root documents coherence
import re,io,os,glob
print("═══ 5. DOCUMENTOS RAÍZ ═══")
cl=io.open('CLAUDE.md',encoding='utf-8').read()
rd=io.open('README.md',encoding='utf-8').read()
print("  CLAUDE.md menciona bea-NN:", 'bea-NN' in cl)
cursos=[d for d in os.listdir('.') if os.path.isdir(d) and not d.startswith('.') and not d.startswith('_')]
print(f"  directorios de curso en disco: {len(cursos)}")
falt=[c for c in cursos if c not in rd]
print(f"  cursos no mencionados en el README raíz: {falt or 'ninguno'}")
sinreadme=[c for c in cursos if not os.path.exists(os.path.join(c,'README.md'))]
print(f"  cursos sin README propio: {sinreadme or 'ninguno'}")
