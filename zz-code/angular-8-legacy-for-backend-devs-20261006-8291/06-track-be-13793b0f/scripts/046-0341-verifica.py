# rescatado de la sesión 13793b0f, 2026-09-11T03:41:06Z · Check whether the style guide references the forensic format
import io,re
# Dejar constancia en la guía de estilo del curso, que es donde se listan las convenciones del track forense
p='prompts/guia-de-estilo-y-convenciones.md'; s=io.open(p,encoding='utf-8').read()
m=re.search(r'[^\n]*formato-piezas-forenses[^\n]*', s)
print("mención en la guía:", (m.group(0)[:160] if m else "NINGUNA"))
