# 🕵️ Track forense — índice y método

> Tutorial Angular 8 — Laboratorio clínico · Puerta de entrada del track
> Cubre las quince piezas: `forense-fase-00.md` … `forense-fase-14.md`

Este archivo es la puerta. Nadie llega a una investigación sabiendo de qué fase es su problema: llega con un síntoma, y casi siempre con uno mal descrito por alguien que no sabe qué es un effect. Por eso el índice que de verdad importa acá no es el de fases (§2) sino el de **síntomas** (§3).

**Las horas del track forense ya están dentro de las 108h de las fases.** Esto no es material adicional: es el desarrollo de la sección 6 que cada fase ya cuenta.

---

## 1. El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Es que cada pregunta cuesta un orden de magnitud más que la anterior, y contestar la barata primero descarta la mitad de las caras.

**Pregunta 1 — ¿Se reproduce, y con qué?** Antes de mirar una línea de código: ¿esto se reproduce **con un flag** del inyector de caos, **con un dato** distinto en el `db.json`, o hace falta **otro código**? Las tres respuestas llevan a investigaciones distintas y averiguar cuál es te ahorra la mitad del camino. Es la misma pregunta que ordena la preparación de los incidentes del cuaderno, y no es casual: la 🔧 Preparación de un incidente **es** la respuesta a esta pregunta, ya escrita.

Con un corolario que vale por sí solo: **un bug que no reproduces no es un bug intermitente, es un bug de temporización que todavía no aprendiste a provocar.** `CHAOS=latency=3000` convierte la mitad de los "a veces pasa" de este curso en "pasa siempre".

**Pregunta 2 — ¿Qué dice la evidencia observable, antes de lo que dice el código?** La URL de una petición, el cuerpo crudo de una respuesta, el `status: 0` de un `HttpErrorResponse`, la secuencia de acciones del log. Casi todas las rutas de este track se resuelven acá, y ninguna requiere abrir un archivo. **El código es el paso 4, no el paso 1.**

Y la desconfianza tiene un orden fijo, que la Fase 4 instala y el resto del curso reutiliza: **pantalla, store, red**. La pantalla te cuenta lo que un programador decidió contarte un día en que nadie pensaba en depurar. El store te cuenta lo que el effect creyó entender. El cuerpo de la respuesta es la única capa que no interpreta nada.

**Pregunta 3 — ¿En qué capa está?** Plantilla, componente, selector, reducer, effect, servicio, interceptor, guard, mock, build, contenedor. Localizar la capa **es** el entregable de una investigación; el fix suele ser de dos líneas y viene después. Y ojo con la trampa que la Fase 6 enseña: el stack trace nombra la capa donde reventó, no la capa donde está el bug.

**Pregunta 4 — 🧬 ¿Esto lo escribió el sistema, o llegó ya roto en el dato?** Ésta es la pregunta propia de este track. Si alguien transicionó ilegalmente *acá*, hay un intento en el log de acciones. Si no hay ni el intento, la muestra llegó rota del `db.json` o de una migración, y es otra investigación con otras herramientas. Esa bifurcación se decide leyendo el log y ahorra medio día de buscar en el lugar equivocado.

> 🧭 **La regla que resume las cuatro:** *"funciona en mi máquina", "a veces pasa" y "desde ayer" no son descripciones de un bug: son descripciones de una diferencia.* El trabajo es encontrar cuál.

---

## 2. 📇 Índice de las quince piezas

| Fase | Síntoma que cubre | Herramienta principal | Archivo |
|---|---|---|---|
| 0 | "No se pudo registrar el paciente" — y el servidor nunca habló | Consola · Network · `status: 0` | [`forense-fase-00.md`](forense-fase-00.md) |
| 1 | "Cambié el paciente y la lista no se entera" | Redux DevTools: Actions · Diff · time-travel | [`forense-fase-01.md`](forense-fase-01.md) |
| 2 | La clave sin traducir **y** la fecha que no cambia de idioma | Network (`fr.json`) · `LOCALE_ID` · `currentLang` | [`forense-fase-02.md`](forense-fase-02.md) |
| 3 | "Me manda al login sin decir nada" | Breakpoints condicionales en el interceptor · el log de Express | [`forense-fase-03.md`](forense-fase-03.md) |
| 4 | "A veces no carga" · el `200` que miente | Los modos del caos · Network · el log de acciones | [`forense-fase-04.md`](forense-fase-04.md) |
| 5 | "A veces guardo un paciente y se guarda dos veces" | Log de acciones · `CHAOS=latency` · `mergeMap`/`switchMap` | [`forense-fase-05.md`](forense-fase-05.md) |
| 6 | El estado que todavía no existe: el slice lazy sin cargar | Árbol del store · el stack trace que apunta mal | [`forense-fase-06.md`](forense-fase-06.md) |
| 7 | "Figura como procesada y el analista jura que nunca la recibió" ⭐ | Log de acciones · `SAMPLE_TRANSITIONS` · línea de custodia | [`forense-fase-07.md`](forense-fase-07.md) |
| 8 | El borde de vigencia que se resbala a UTC · el mapa que miente | `selectActiveRange` · source maps y su desfase | [`forense-fase-08.md`](forense-fase-08.md) |
| 9 | El PDF salió con un dato que ya no es el actual | `reportSnapshot` del componente frente al store | [`forense-fase-09.md`](forense-fase-09.md) |
| 10 | "El dashboard se arrastra al final del turno" | Panel Memory · panel Performance · `console.count` | [`forense-fase-10.md`](forense-fase-10.md) |
| 11 | "El sábado la orden 4021 salió entregada sin validar" | La bitácora: filtrar, ordenar, el asiento ausente | [`forense-fase-11.md`](forense-fase-11.md) |
| 12 | El test verde que no puede cazar el bug | Spec rojo → fix → verde · cobertura de casos | [`forense-fase-12.md`](forense-fase-12.md) |
| 13 | "En UAT entra y en PROD no" | Diff entre ambientes · `config.json` en Network | [`forense-fase-13.md`](forense-fase-13.md) |
| 14 | "El pod no arranca" 🔥 | `describe` (Events) frente a `logs --previous` | [`forense-fase-14.md`](forense-fase-14.md) |

---

## 3. 🩺 Índice de síntomas transversal

La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la derecha, dónde empezar.

Cada fila te manda **a la fase**, que es donde está el código y el contexto. El recorrido paso a paso vive en su pieza: la tienes enlazada en la sección 6 de esa fase y, directa, en el índice de §2 — que es la tabla de arriba y la que conviene abrir en otra pestaña mientras investigas.

| Lo que ves o te cuentan | Empieza en |
|---|---|
| "Le di a guardar y no pasó nada", sin errores en consola | [Fase 0](00-setup-hola-mundo.md) — la consola miente por omisión |
| Network dice `(failed)` y la consola, `status: 0` | [Fase 0](00-setup-hola-mundo.md) — el servidor **nunca habló**: puerto, DNS o CORS |
| El estado en DevTools es correcto y la pantalla muestra lo viejo | [Fase 1](01-estructura-base-ngrx.md) — mutación en el reducer; el selector no emitió |
| El primer error se ve bien y después el botón de reintentar no hace nada nunca más | [Fase 1](01-estructura-base-ngrx.md) — `catchError` fuera del `switchMap`: el effect murió |
| La pantalla se cae con `Cannot read property 'items' of undefined` | [Fase 6](06-ordenes.md) → [Fase 10](10-dashboard.md) — un slice lazy que nadie cargó todavía |
| "Funciona si vengo por acá y no si vengo por allá" | [Fase 6](06-ordenes.md) — el síntoma depende de la ruta que tomó el usuario |
| Una clave de i18n se ve en crudo en pantalla | [Fase 2](02-i18n.md) — cuatro causas posibles y el orden de descarte es todo |
| El idioma cambia en el toolbar y no en la pantalla | [Fase 2](02-i18n.md) — `forChild()` sin `isolate: false` |
| "Las fechas se ven raras" en otro idioma | [Fase 2](02-i18n.md) — `LOCALE_ID` es estático; los pipes no escuchan al selector |
| "Me desloguea a los pocos segundos" | [Fase 3](03-autenticacion.md) — segundos frente a milisegundos en `exp`, casi siempre |
| "Cerré sesión en una pestaña y en la otra sigo adentro" | [Fase 3](03-autenticacion.md) — quién consulta el storage, y cada cuánto |
| `Bearer null` en el header de Network | [Fase 3](03-autenticacion.md) — el interceptor corrió antes de que el token existiera |
| `200` verde y la pantalla dice que no hay datos | [Fase 4](04-mock-api-caos.md) — `malformed`: el store despachó **Success** con basura |
| "A veces no carga" | [Fase 4](04-mock-api-caos.md) — un intermitente es un flag del caos que todavía no encendiste |
| Spinner eterno, la petición en `pending` para siempre | [Fase 4](04-mock-api-caos.md) — `timeout`, y mira dónde está puesto el operador |
| "Guardo y a veces no se guarda" | [Fase 5](05-pacientes.md) — `switchMap` cancela y la cancelación **no es un error** |
| Dos peticiones en Network y una sola acción de éxito | [Fase 5](05-pacientes.md) — el operador de aplanado decide qué se pierde |
| Un dato imposible según las reglas del dominio 🧬 | [Fase 7](07-muestras-custodia.md) ⭐ — ¿hay intento en el log? Si no lo hay, llegó roto en el dato |
| Un hueco en la línea de custodia, sin ningún error | [Fase 7](07-muestras-custodia.md) ⭐ — el bug se ve como un dato imposible, no como algo rojo |
| Un veredicto de rango que cambia según la fecha, y sólo de noche | [Fase 8](08-resultados-rangos.md) — nunca es un bug de fechas: es no haber decidido la zona horaria |
| Un resultado `validated` con `rangeVersionApplied` en `null` | [Fase 8](08-resultados-rangos.md) — un veredicto sin norma detrás; ¿se sembró o se validó así? |
| Un breakpoint que no dispara sobre código que sí corre | [Fase 8](08-resultados-rangos.md) — source map desfasado respecto del bundle |
| El documento exportado no dice lo mismo que la pantalla | [Fase 9](09-entrega-pdf.md) — se armó desde una copia; mira la propiedad del componente |
| El PDF sale con los acentos rotos, y sólo en el título | [Fase 9](09-entrega-pdf.md) · [**A08**](./a08-pdf-cliente.md) — `setFont` sólo afecta a lo que se dibuja después |
| "La pestaña se arrastra al final del turno" y reabrirla lo cura | [Fase 10](10-dashboard.md) — suscripciones huérfanas; `console.count` antes que el heap |
| Los gráficos parpadean al escribir en otra parte de la pantalla | [Fase 10](10-dashboard.md) — un método llamado desde la plantilla devuelve referencia nueva |
| Un asiento de auditoría que no aparece | [Fase 11](11-trazabilidad-audit-log.md) — un effect no registrado no escucha nada aunque compile |
| Cada mutación genera **dos** asientos | [Fase 11](11-trazabilidad-audit-log.md) — el módulo se importó dos veces |
| "El log dice que yo hice eso y yo no estaba ese día" | [Fase 11](11-trazabilidad-audit-log.md) — la bitácora puede estar podrida por dentro y verse impecable |
| Un test en verde sobre código que sabes que está roto | [Fase 12](12-testing-coverage.md) — el `expect` dentro de un `subscribe` que nunca emitió |
| "El test pasa en mi máquina y falla en la de al lado" | [Fase 12](12-testing-coverage.md) — orden, reloj, azar, o el DOM que quedó sucio |
| "Desplegamos a PROD y le sigue hablando a UAT" | [Fase 13](13-build-despliegue.md) — `config.json` en Network, antes que cualquier otra cosa |
| Recargar una ruta profunda da 404 | [Fase 13](13-build-despliegue.md) — `try_files` del nginx, y es una línea |
| "En UAT funciona y en PROD no" | [Fase 13](13-build-despliegue.md) — configuración, caché, versiones, y **sólo al final**, código |
| El `-e` del contenedor no tiene ningún efecto | [Fase 13](13-build-despliegue.md) — caché del navegador o una variable que `envsubst` no listó |
| Un pod en `CrashLoopBackOff` 🔥 | [Fase 14](14-casi-prod-kind.md) — `describe` si nunca llegó a `Running`, `logs --previous` si arrancó y murió |
| Un Service con `ENDPOINTS: <none>` 🔥 | [Fase 14](14-casi-prod-kind.md) — siempre es un problema de etiquetas, nunca de red |
| `ERR_OSSL_EVP_UNSUPPORTED` al arrancar | [**A03**](./a03-node-npm.md) — estás en Node 17 o superior; el CLI 8 no llega ahí |
| `node-sass` que no compila, o un contenedor que muere sin decir nada en un Mac con chip M | [**A12**](./a12-arm64-m1.md) y [**A13**](./a13-docker-colima.md) — arquitectura antes que código |

---

## 4. 🧰 Las herramientas, y en qué miente cada una

Ninguna herramienta miente por malicia: cada una contesta una pregunta muy concreta, y el error es preguntarle otra.

**La consola** miente **por omisión**. Un `subscribe` sin callback de `error` traga el fallo entero: la petición falló, la pantalla se congeló, y la consola está limpia. Y `@ngx-translate` no registra las claves que no encuentra: devuelve la clave y sigue, tan tranquilo.

**La pestaña Network** miente **por status**. Un `201` significa que el servidor contestó, no que hizo lo que crees. Y un `200` con el cuerpo cambiado —el `CHAOS=malformed` de la Fase 4— es el caso donde el semáforo verde te cuesta dos horas.

**Redux DevTools** miente **por reconstrucción**. El time-travel repone el estado, no los efectos que ya salieron: retrocedes el deslizador y las peticiones que se dispararon siguen habiendo ocurrido, el `db.json` sigue escrito y el PDF sigue descargado. Es una máquina del tiempo para el estado, no para el mundo. Y en su panel Diff un dato puede estar perfecto y aun así no haber notificado a nadie, que es exactamente el bug de la mutación en el reducer.

**El panel Memory** no miente, pero **contesta tarde**. Un heap snapshot cuesta minutos y casi siempre el comportamiento ya te había dado la respuesta: un `console.count` en `ngOnInit` delata cuatro suscripciones acumuladas sin abrir nada. Úsalo cuando el síntoma sea "va poniéndose lenta" y no haya nada visible que contar.

**El panel Performance** miente **por interpretación**. Un ciclo de detección de cambios con doscientos componentes revisados no es un problema si dura 3 ms. La columna que importa es el tiempo, no el conteo.

**Los source maps** mienten **por desfase**. Si se recompiló el JS y se subió el map viejo, el mapa te lleva a una línea de tu fuente que *parece* la culpable. La firma es un breakpoint que nunca dispara sobre código que claramente se ejecuta.

**El log del mock** miente **por parcialidad**: te cuenta lo que Express vio, no lo que el navegador envió. Con poco tráfico las dos mitades se emparejan por método, ruta y hora; en cuanto hay volumen eso deja de funcionar y hace falta un identificador que viaje con la petición. LabCore no lo tiene, y [`forense-fase-03.md`](forense-fase-03.md) enseña a añadirlo como instrumento temporal —y a quitarlo después.

**`kubectl`** miente **por momento**. `kubectl logs` te enseña el intento actual, que puede llevar dos segundos de vida y no haber fallado todavía. El mensaje que buscas está en `--previous`. Y `CrashLoopBackOff` no es un diagnóstico: es el comportamiento del cluster, no la causa.

**Angular DevTools no entra en este elenco:** la extensión oficial no soporta Angular 8, y saberlo te ahorra media hora de instalarla y buscar la pestaña que no aparece. En este curso el papel que allá cumple la extensión lo cumplen Redux DevTools y la consola.

**Y el `git log`**, que no es una herramienta de depuración hasta que lo es. `git log -S"SAMPLE_TRANSITIONS"` encuentra el commit donde una línea apareció o desapareció, y `git bisect` encuentra el que rompió algo cuando ninguna de las otras te dice por qué. La convención de commits y tags del curso —incluido el par `inc/<ID>/…-roto` e `inc/<ID>/…-fix`— existe para que ese `log` sirva: está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 5. Cómo se cierra el track

Este archivo te dice **dónde empezar**. Las quince piezas te dicen **cómo recorrer** cada camino. Y lo que convierte un recorrido en algo que le sirve a alguien más es el **post-mortem de ocho puntos** —síntoma en palabras del usuario, reproducción, evidencia observable, causa raíz hasta la línea, corrección aplicada, prueba de regresión que falla antes del fix, prevención, y análisis del sistema sin culpabilizar a nadie—. Es el formato con el que se cierran los veintiún incidentes de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), y no se duplica acá.

Sus puntos 1 a 6 tienen traducción exacta a git, y conviene pedirla: el par de tags `inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix` deja el síntoma y la regresión en rojo en el primero, la causa y el fix en el segundo, y el `git diff` entre los dos **es** el punto 5 aislado del ruido de la fase.

Y hay un segundo artefacto, más corto y más operativo: **el checklist de una página** de [`forense-fase-13.md`](forense-fase-13.md) §🧾, con sus cuatro momentos —antes de escribir código, al escribir el fix, antes de desplegar, después de desplegar—. El master no lo duplica; la pieza 13 lo escribe y la retrospectiva del cuaderno te pide reescribirlo con lo que aprendiste.

Esos dos son lo único de todo el track que sirve tal cual en un sistema que no es LabCore. El resto es entrenamiento para poder escribirlos.

> 🧭 **Y el criterio para saber si el track hizo su trabajo:** que ante un ticket vago, tu primer movimiento ya no sea abrir el editor.
