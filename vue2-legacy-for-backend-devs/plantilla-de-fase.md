# 🧩 Plantilla de fase (esqueleto)
## Tutorial React 16 — Rifas y chances

Copia este esqueleto al iniciar cada fase y rellena los `{{placeholders}}`.
Mantiene la estructura de 9 secciones idéntica en todo el curso. Borra las
notas entre paréntesis antes de entregar.

> 🔄 **Recordatorio de convención (ver `GUIA-DE-ESTILO-Y-CONVENCIONES.md`
> §4 y `DICCIONARIO-CODIGO-INGLES.md`):** todo identificador de código
> (variables, funciones, componentes, slices, epics, action types,
> endpoints, constantes, enums) va en **inglés**. Los comentarios de
> código, los textos de interfaz de usuario (labels, botones, mensajes de
> alerta) y toda la narrativa van en **español**.

---

```markdown
# {{emoji}} Fase {{NN}} — {{Nombre}}

> Tutorial React 16 — Rifas y chances · Fase {{N}} de 11 · **{{X}} horas**
> Depende de: {{fase previa}} · Habilita: {{fase siguiente}}

---

## 🎯 1. Propósito

{{Una o dos frases: qué resuelve esta fase y por qué importa para
mantenimiento. Anclar al dominio de rifas.}}

---

## ✅ 2. Qué queda listo al terminar

- [ ] {{resultado verificable 1}}
- [ ] {{resultado verificable 2}}
- [ ] {{...3 a 5 items}}

---

## 🚫 3. Qué queda fuera por ahora

- {{tema diferido}} → Fase {{M}}.
- {{...}}

---

## 🧠 4. Conceptos mínimos

{{Solo lo necesario para esta fase, anclado al dominio. Prosa, no bullets.
Explicar el porqué de cada decisión. Si un concepto ya vive en un apéndice,
enlazarlo en vez de repetirlo.}}

{{Si aplica, nota de convivencia class/hooks o connect()/useSelector.}}

---

## 💻 5. Implementación y código comentado

{{El grueso de la fase. Código mínimo, ejecutable, coherente con las
versiones fijadas. Comentarios en español que explican el porqué.
Distinguir con claridad qué vive en frontend / store / epic / backend.}}

{{Identificadores en inglés: nombres de función, variable, componente,
slice, epic, action type, endpoint y constante. Consultar
DICCIONARIO-CODIGO-INGLES.md para el término correcto del dominio (ej.
`raffle`, `number`, `sold`, `settlement`). Los textos que ve el usuario
(labels, botones, mensajes de alerta) quedan en español.}}

{{Marcar 💸 cualquier deuda técnica intencional con nota de qué sería lo
correcto y en qué fase se aborda.}}

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

{{2-4 errores típicos: síntoma → causa → fix mínimo. Distinguir corrección
mínima de refactorización cuando aplique.}}

### Pieza forense de esta fase

{{Qué debuggear específico de esta fase. Enlazar a FORENSE FASE {{NN}}.
Incluir al menos un ejercicio de "rompe a propósito y observa".}}

---

## 🧪 7. Ejercicios ({{total}})

**🟢 Fácil (1–{{a}})**
1. {{...}}

**🟡 Intermedio ({{a+1}}–{{b}})**
{{...}}

**🟠 Difícil ({{b+1}}–{{c}})**
{{...}}

**🔴 Muy difícil ({{c+1}}–{{total}})**
{{...}}

**🔥 Opcionales**
- 🔥 {{...}}

{{Mínimo 25, ideal 30-35. Reparto equilibrado entre niveles (no cargar todo
en fácil). Numeración continua; el título lleva el conteo. Accionables y
verificables, anclados al dominio de rifas. Incluir varios de diagnóstico:
entregar un bug y pedir reproducir y localizar, no solo construir. Cuando
un enunciado nombra código, usar el identificador en inglés vigente
(ej. "agregá el thunk `createRaffle`").}}

---

## 📚 8. Referencias

**Documentación oficial**
- {{URL completa}} — {{nota de versión si aplica}}

**Libros** (si aplican)
- {{...}}

**Video / apoyo**
- {{crash course / tutorial en YouTube, URL completa}}

**Orden de lectura sugerido:** {{qué leer primero → después → volver al código}}

> ⚠️ {{Aclarar que URLs, títulos y contenidos pueden estar desactualizados;
> el lector debe verificarlos. Advertir cuando un enlace cubra otra versión.}}

---

## 🚀 9. Cierre y conexión con la siguiente fase

{{Resumen de lo logrado y puente a la Fase {{siguiente}}: qué se construye
allí y por qué es el paso natural.}}

> **La señal de que quedó bien:** {{criterio en forma de cita — cómo se
> siente el trabajo bien hecho de esta fase.}}
```

---

## Recordatorios al rellenar

- Las horas deben coincidir con `PLAN-DEL-CURSO` y sumar 96 en total.
- No contradigas nombres de slices, acciones o componentes de fases previas (todos en inglés, ver `DICCIONARIO-CODIGO-INGLES.md`).
- Todo identificador de código va en inglés; comentarios, textos de UI y narrativa van en español (`GUIA-DE-ESTILO-Y-CONVENCIONES.md` §4).
- Si estás ajustando una fase ya escrita en español-código, seguí el proceso de `GUIA-DE-ESTILO-Y-CONVENCIONES.md` §4.6 antes de tocar la pedagogía.
- Enlaza la pieza forense y los incidentes que correspondan a esta fase.
- Confirma las decisiones críticas pendientes (ver `DECISIONES-PENDIENTES`) antes de escribir código.
- Cero referencia al dominio bajo NDA.
