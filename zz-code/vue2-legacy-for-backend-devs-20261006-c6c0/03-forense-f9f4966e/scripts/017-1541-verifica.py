# rescatado de la sesión f9f4966e, 2026-09-10T15:41:54Z · Read status section
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
i=s.index("## 11. 🚦 Estado y siguiente paso")
j=s.index("## 12. ✅ Checklist de ejecución")
print(s[i:j])
