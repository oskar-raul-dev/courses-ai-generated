# rescatado de la sesión f9f4966e, 2026-09-10T02:40:42Z · Stitch course 02 phase 12
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("12-el-backend-habla.md","forense-fase-12.md",
"""Un backend que habla por dos canales tiene **dos fronteras**, y casi siempre solo
la primera está bien vigilada. Ésa es toda la pieza: el serializer que todo el
mundo aplica al responder un HTTP y nadie recuerda aplicar al emitir un evento.
El síntoma llega desde la interfaz —"en vivo se ve mal y al recargar se ve
bien"— y se diagnostica poniendo **los dos canales lado a lado**: pide el mismo
ticket con `curl` y escucha el evento por socket. Si las dos formas no coinciden,
ya sabes qué mitad del caso estás resolviendo. Después vienen las otras tres
preguntas de esta fase: dónde se emite, **si se emite antes o después de
escribir** —el orden es la deuda que este curso vino a pagar— y cuántos emisores
hay realmente, porque el relé tonto del sistema heredado puede seguir
encendido.""",
"""Compara las dos fronteras en treinta segundos. Con el backend arriba, en una
consola del navegador:

```js
socket.on("ticket:updated", function (t) { console.log("socket:", t); });
```

Y en la terminal, sobre el mismo ticket:

```bash
curl -s localhost:4000/tickets/<id> | head -c 300
```

Si uno trae `_id` y fechas crudas y el otro `id` y fechas ISO, acabas de
encontrar el bug que solo pasa "cuando llega en vivo".""",
RES + '| 11 | "En vivo llega mal y al recargar se ve bien" | Contrato | 🔴 |')
