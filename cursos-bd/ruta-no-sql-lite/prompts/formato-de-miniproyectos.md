# 🧰 Formato de los miniproyectos de familia
## Ruta NoSQL Lite — cómo se escribe un `h-mini` y qué se decidió sobre ellos

> **Qué es este documento:** el formato propio (etapa E4 de los lineamientos) de los diez
> miniproyectos `h-mini-NN-<familia>-<empresa>.md`: su plantilla, su encaje en el curso y las
> decisiones cerradas. El índice para el lector, con el reparto y los stacks, es
> [`../miniproyectos.md`](../miniproyectos.md).
> **Origen:** sale de partir el antiguo `propuestas-mini-proyectos.md` de la raíz del curso
> (14/09/2026, decidido el 29/09/2026) en la revisión contra los lineamientos del 06/10/2026: lo
> que lee el lector quedó en la raíz y lo que necesita quien escribe, aquí.
> **Precedencia:** por debajo de [`alcance-del-proyecto.md`](alcance-del-proyecto.md) (§13) y de la
> [guía](guia-de-estilo-y-convenciones.md) (§5.2 y §9.3). Las empresas salen de
> [`propuestas-historias.md`](propuestas-historias.md) §3.
> **Vigencia:** 2026-10-06.

---

## 1. 🧩 La plantilla de un `h-mini`

Los diez archivos siguen la misma forma, y es corta a propósito: un miniproyecto no es una
fase y no lleva su aparato.

1. **La empresa en tres párrafos** — comprimida de [`propuestas-historias.md`](propuestas-historias.md).
   Lo justo para entender el negocio, nunca más.
2. ⚰️ **El dolor** — qué duele, desde cuándo, qué decisión lo causó y qué cuesta hoy. Con la
   estructura de autopsia de la guía §2.1: la decisión tenía su mejor argumento.
3. 🎯 **El encargo** — quién lo pide y qué espera recibir. En su voz.
4. 🧩 **Lo que se construye** — el entregable concreto.
5. 📐 **Lo que se observa** — medidas estructurales. Se **observan**, no se publican: no entran
   a la bitácora.
6. 💥 **Dónde se rompe** — el límite del planteamiento, que el lector tiene que encontrar solo.
7. ⚖️ **El veredicto que tiene que salir** — incluido el incómodo cuando corresponda.
8. 🧰 **El stack** — tabla completa: entorno, motor, CLI, driver, modelado, cómo se mide, de
   dónde salen los datos y dónde queda el entregable. Más lo que **no** entra. Siempre motores
   del `compose.yaml` de la ruta: un miniproyecto que necesita algo que el curso no monta está
   mal planteado, y **ninguna versión ni digest se escribe ahí** — eso vive en `a02`.
9. 🔗 **El puente con Cóndor** — qué de esto vuelve al dominio del curso y en qué fase.
10. 📋 **Criterios de aceptación** — verificables, en bloque `text` con casillas.

**Lo que se vigila al escribir uno:**

- **Los dos veredictos incómodos** (Bengala en búsqueda, Cumbre Roja en vectorial; índice para el
  lector §3.1) están puestos a propósito. Hay que resistir la tentación de "arreglarlos".
- **Rueda Viva no aparece.** Era la séptima candidata de `propuestas-historias.md` —mantenimiento de
  flota industrial— y se queda fuera a propósito: es hermana de Cóndor y su dolor sería el mismo.
- **Ningún `h-mini` cita `prompts/`**: las reglas que necesita (los dos entornos, la licencia de un
  motor) se citan por el apéndice que las publica (`a06`, `a10`).
- **Se revisa al cerrar la fase B de su familia**, contra lo que la fase terminó midiendo: el
  veredicto del `h-mini` tiene que resistir el matiz medido.

---

## 2. ⏱️ Horas y encaje — decidido: opción A

> ✅ **Decidido el 29/09/2026: opción A.** Los miniproyectos van fuera de las 252 h, son
> opcionales, de 4 a 6 h cada uno, y **se anuncian al abrir la fase B**, no al cerrarla. El
> conteo de ejercicios de las fases no cambia. Las tres opciones quedan abajo como registro.

**Opción A — fuera de las 252 h, como los boss.** Diez encargos opcionales de 4 a 6 horas cada
uno, al cierre de su minicurso. **Coste: 0 h de calendario**, y es coherente con cómo el curso
ya trata al boss de bloque y al global. Riesgo: lo opcional no se hace.

**Opción B — dentro de la fase B, sustituyendo ejercicios 🔴.** El miniproyecto se vuelve el
cierre obligatorio del minicurso y se compensa bajando entre tres y cinco ejercicios de la fase.
**Coste: 0 h**, pero toca el conteo de ejercicios de la
[propuesta de fases](propuesta-fases-y-alcance.md) §9 y la banda declarada de la guía §9.

**Opción C — como el bloque de refuerzo de cada bloque**, agrupando los dos o tres
miniproyectos de las familias del bloque en una sesión propia. Más limpio de calendario, pero
rompe el cierre de cada minicurso, que es donde el encargo tiene sentido.

Se eligió la A con una condición: que el miniproyecto se anuncie **al abrir** la fase B y no al
cerrarla. Un encargo que el lector conoce desde el principio cambia cómo lee la fase entera, y
eso vale más que las horas que ocupa.

---

## 3. ✅ Decisiones cerradas

Las cuatro se cerraron el 29/09/2026, y todas con el valor propuesto:

1. **Encaje: opción A** (§2). Fuera de las 252 h, anunciados al abrir la fase B.
2. **`h-mini-NN-<familia>-<empresa>.md` es una familia de archivos del curso**, registrada en
   la guía §5.2 y en la [propuesta de fases](propuesta-fases-y-alcance.md) §10. Los diez archivos
   conservan su nombre; ninguna sesión futura los renumera.
3. **Tag de git propio `mini-NN-<slug>`**, en su propio espacio, para que
   `git tag -l 'fase-*'` siga siendo el índice limpio del curso.
4. **Las cinco empresas no llevan archivo de historia propio.** Bastan los tres párrafos de
   cada `h-mini` y la ficha de `propuestas-historias.md`: la única empresa que merece
   historia larga es la que se mide.

Dos casillas que bloqueaban la escritura se cerraron el mismo día (alcance §12, decisiones 16 y
17): el cliente de Valkey es `iovalkey`, y columnar ancha va con Cassandra (se midió la RAM, las
dos cupieron con el heap fijado, y decidió la licencia).
