# 🕵️ Track forense — índice y método

> Tutorial Angular 16 — Inspecciones y certificaciones · Puerta de entrada del track
> Cubre las quince piezas: [`forense-fase-00.md`](forense-fase-00.md) … [`forense-fase-14.md`](forense-fase-14.md)

Este archivo es la puerta. Nadie llega a una investigación sabiendo de qué fase es su problema: llega con un síntoma, y casi siempre con uno mal descrito. Por eso el índice que de verdad importa aquí no es el de fases (§2) sino el de **síntomas** (§3).

**Las horas del track forense ya están dentro de las 108h de las fases.** Esto no es material adicional: es el desarrollo de una sección que cada fase ya cuenta.

---

## 1. El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Es que cada pregunta cuesta un orden de magnitud más que la anterior, y contestar la barata primero descarta la mitad de las caras.

**Pregunta 1 — ¿Se reproduce, y con qué?** Antes de mirar una línea de código: ¿esto se reproduce **con un flag** del inyector de caos, **con un dato** distinto, o hace falta **otro código**? Las tres respuestas llevan a investigaciones distintas y averiguar cuál es te ahorra la mitad del camino. Es la misma pregunta que ordena la preparación de los incidentes del cuaderno.

**Pregunta 2 — ¿Qué dice la evidencia observable, antes de lo que dice el código?** La URL de una petición, el cuerpo crudo de una respuesta, el estado de un control, el paréntesis de un `NullInjectorError`. Casi todas las rutas de este track se resuelven aquí, y ninguna requiere abrir un archivo. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿En qué capa está?** Plantilla, componente, servicio de estado, `*ApiService`, interceptor, guard, mock, build, contenedor. Localizar la capa es el entregable de una investigación; el fix suele ser de tres líneas y viene después.

**Pregunta 4 — ¿De qué generación es el archivo que voy a tocar?** 🧬 Ésta es la pregunta propia de este track y no existe en un sistema de una sola época. Un fix en un componente de NgModule se escribe como el resto de ese componente; uno en un standalone, con `inject()`. Contestarla antes de escribir evita el diff que mezcla dos estilos y que nadie sabe revisar.

> 🧭 **La regla que resume las cuatro:** *"funciona en mi máquina", "a veces pasa" y "desde ayer" no son descripciones de un bug: son descripciones de una diferencia.* El trabajo es encontrar cuál.

---

## 2. 📇 Índice de las quince piezas

| Fase | Síntoma que cubre | Herramienta principal | Archivo |
|---|---|---|---|
| 0 | "Le di guardar y no pasó nada" | Consola · Network · source maps | [`forense-fase-00.md`](forense-fase-00.md) |
| 1 | "La ruta funciona pero la pantalla sale en blanco" | Errores de NgModule · Network (JS) | [`forense-fase-01.md`](forense-fase-01.md) |
| 2 | "Me saca al login sin decir nada" | Breakpoints en interceptor · Headers | [`forense-fase-02.md`](forense-fase-02.md) |
| 3 | "A veces carga y a veces no" | Los seis fallos del caos · Network | [`forense-fase-03.md`](forense-fase-03.md) |
| 4 | "La lista se actualizó dos veces" | `console.count` · panel Memory | [`forense-fase-04.md`](forense-fase-04.md) |
| 5 | "No hay proveedor para…" 🧬 | Los dos `NullInjectorError` | [`forense-fase-05.md`](forense-fase-05.md) |
| 6 | "No me deja guardar y no dice por qué" | `ng.getComponent($0)` · estado del formulario | [`forense-fase-06.md`](forense-fase-06.md) |
| 7 | "Esta inspección se ve con otra plantilla" ⭐ | La URL de `/templates` | [`forense-fase-07.md`](forense-fase-07.md) |
| 8 | "Escribo y la aplicación se queda pegada" ⭐ | Network en reposo · claves del `FormRecord` | [`forense-fase-08.md`](forense-fase-08.md) |
| 9 | "Aprobó y no debía" | JSON crudo · `null` frente a `undefined` | [`forense-fase-09.md`](forense-fase-09.md) |
| 10 | "Venció ayer para uno y hoy para otro" | El offset de la cadena ISO | [`forense-fase-10.md`](forense-fase-10.md) |
| 11 | "Desde ayer el panel va lentísimo" | Los cuatro sospechosos, en orden | [`forense-fase-11.md`](forense-fase-11.md) |
| 12 | "Pasa en mi máquina y falla en el pipeline" | La semilla de Jasmine · bisección | [`forense-fase-12.md`](forense-fase-12.md) |
| 13 | "En UAT entra y en PROD no" | Digest de la imagen · `curl -I` | [`forense-fase-13.md`](forense-fase-13.md) |
| 14 | "El pod no arranca" 🔥 | `describe` frente a `logs` | [`forense-fase-14.md`](forense-fase-14.md) |

---

## 3. 🩺 Índice de síntomas transversal

La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la derecha, dónde empezar.

| Lo que ves o te cuentan | Empieza en |
|---|---|
| La pantalla se queda en blanco al entrar a una ruta | [Fase 1](01-estructura-base-ngmodules.md) (módulo/declaración) → [Fase 5](05-standalone-convivencia.md) si el componente es standalone 🧬 |
| "Le di guardar y no pasó nada", sin errores en consola | [Fase 0](00-setup-hola-mundo.md) — la consola miente por omisión |
| Network dice `(failed)` sin status | [Fase 3](03-mock-api-caos.md) — `cors`, servidor caído o red ausente: **son indistinguibles desde el código** |
| `200` verde y la pantalla dice que el dato no tiene la forma esperada | [Fase 3](03-mock-api-caos.md) — `malformed`, el fallo que miente |
| Spinner eterno, la petición en `pending` para siempre | [Fase 3](03-mock-api-caos.md) — `timeout` |
| Me devuelve al login sin explicación | [Fase 2](02-autenticacion.md) — ¿guard o interceptor? Lo dice Network en diez segundos |
| `NullInjectorError: No provider for X` | [Fase 5](05-standalone-convivencia.md) — el paréntesis del mensaje decide dónde buscar 🧬 |
| `NG0203: inject() must be called from an injection context` | [Fase 2](02-autenticacion.md) · [**A04**](a04-inject-vs-constructor.md) §7 — casi siempre un `subscribe` o un hook |
| "No me deja guardar y no dice por qué" | [Fase 6](06-clientes-activos.md) — el formulario contesta antes que el código |
| Un formulario que nunca llega a ser válido | [Fase 6](06-clientes-activos.md) — `PENDING` no es `INVALID`: un validador asíncrono no completó |
| Una inspección vieja se ve con la plantilla nueva | [Fase 7](07-plantillas-versionadas.md) ⭐ — la URL de `/templates`, sin abrir un archivo |
| Una inspección vieja se ve con la plantilla vieja | [Fase 7](07-plantillas-versionadas.md) ⭐ — **no es un bug**; hay que demostrarlo |
| La aplicación se arrastra al escribir en un formulario | [Fase 8](08-formulario-dinamico.md) ⭐ — Network en reposo delata el bucle |
| Aparecen campos que no son de esta inspección | [Fase 8](08-formulario-dinamico.md) — control huérfano: compara claves del formulario con ítems |
| `NG0100 ExpressionChangedAfterItHasBeenChecked` | [Fase 8](08-formulario-dinamico.md) — y ojo: **desaparece en producción**, el bug no |
| Una regla de negocio no se aplicó y no hay error | [Fase 9](09-hallazgos-severidad.md) — `null`, `undefined` y campo ausente son tres cosas |
| Un dato cambió y volvió solo al día siguiente | [Fase 9](09-hallazgos-severidad.md) — dato guardado frente a dato derivado |
| Un documento exportado no dice lo mismo que la pantalla | [Fase 10](10-certificados-vigencia.md) · [**A08**](a08-pdf-cliente.md) §7 — se armó desde la vista |
| "Venció ayer/hoy según a quién le preguntes", y sólo por la tarde | [Fase 10](10-certificados-vigencia.md) — nunca es un bug de fechas: es no haber decidido a qué hora vence algo |
| La pestaña va poniéndose lenta con las horas | [Fase 4](04-estado-servicios.md) — fuga de suscripción; el panel Memory sólo si el comportamiento no basta |
| Sales de una pantalla y el servidor sigue recibiendo peticiones | [Fase 11](11-dashboard-alertas.md) → [Fase 4](04-estado-servicios.md) — dos minutos de Network y ya lo sabes |
| El panel va lento | [Fase 11](11-dashboard-alertas.md) — cuatro sospechosos, y `ChangeDetectionStrategy` es **el último** |
| Un test falla a veces | [Fase 12](12-testing-coverage.md) — reloj, azar, orden, o el DOM que quedó sucio |
| "Desplegamos el fix y la gente sigue viendo el error" | [Fase 13](13-build-despliegue.md) — caché del `index.html`, casi siempre |
| "En UAT funciona y en PROD no" | [Fase 13](13-build-despliegue.md) — configuración, caché, versiones, y **sólo al final**, código |
| Un pod no arranca 🔥 | [Fase 14](14-casi-prod-kind.md) — `describe` si nunca llegó a `Running`, `logs --previous` si arrancó y murió |
| `CrashLoopBackOff` sin logs, en un Mac con chip M 🔥 | [**A12**](a12-arm64-m1.md) §6 — casi siempre una imagen amd64 |

---

## 4. 🧰 Las herramientas, y en qué miente cada una

Ninguna herramienta miente por malicia: cada una contesta una pregunta muy concreta, y el error es preguntarle otra.

**La consola** miente **por omisión**. Un `subscribe` sin callback de `error` traga el fallo entero: la petición falló, la pantalla se congeló, y la consola está limpia. Y miente por ilegibilidad: sin source maps, el stack apunta a un bundle minificado.

**La pestaña Network** miente **por status**. Un `201` significa que el servidor contestó, no que hizo lo que crees. Y un `200` con el cuerpo cambiado —el `malformed` de la Fase 3— es el caso donde el semáforo verde te cuesta media hora.

**Angular DevTools** miente **por versión de build**. `ng.getComponent($0)` sólo existe en el build de desarrollo. En producción no está, y ésa es exactamente la diferencia que la Fase 13 te obliga a mirar de frente.

**El panel Memory** no miente, pero **contesta tarde**. Un heap snapshot cuesta minutos y casi siempre el comportamiento ya te había dado la respuesta: un `console.count` bien puesto delata una fuga sin abrir nada. Úsalo cuando el síntoma sea "va poniéndose lenta" y no haya nada visible que contar.

**El panel Performance** miente **por interpretación**. Un ciclo de detección de cambios con doscientos componentes revisados no es un problema si dura 3 ms. La columna que importa es el tiempo, no el conteo.

**`kubectl`** miente **por momento**. `kubectl logs` te enseña el intento actual, que puede llevar dos segundos de vida y no haber fallado todavía. El mensaje que buscas está en `--previous`.

**Y el `git log`**, que no es una herramienta de depuración hasta que lo es. `git log -S"resolveTemplateVersion"` encuentra el commit donde una línea apareció o desapareció, y `git bisect` encuentra el commit que rompió algo cuando ninguna de las otras herramientas te dice por qué. La convención de commits y tags del curso —incluido el par `inc/<ID>/…-roto` e `inc/<ID>/…-fix`— existe para que ese `log` sirva: está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 5. Cómo se cierra el track

Este archivo te dice **dónde empezar**. Las quince piezas te dicen **cómo recorrer** cada camino. Y el entregable que te llevas al trabajo real no está en ninguno de los dos: es el `HOTFIX.md` de una página que escribes tú en la **Fase 13 §5.9**, con sus cuatro momentos —antes de escribir código, al escribir el fix, antes de desplegar, después de desplegar—.

Ese archivo es lo único de todo el curso que sirve en un sistema que no es CertCore. El resto es entrenamiento para poder escribirlo.

> 🧭 **Y el criterio para saber si el track hizo su trabajo:** que ante un ticket vago, tu primer movimiento ya no sea abrir el editor.
