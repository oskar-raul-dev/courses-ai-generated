# 🕵️ Forense Fase 04 — "La lista se actualizó dos veces"

> Pieza forense de la **Fase 4 — Estado con servicios y `BehaviorSubject`** · Recorrido: ~40 min
> Herramientas: `console.count` · DevTools → Memory (heap snapshot) · Network en reposo
> Síntoma que cubre: algo ocurre más veces de las que debería, o la pestaña se va poniendo lenta con las horas.

Una fuga de suscripción no se ve. Lo que se ve son sus consecuencias, y son dos muy distintas: **un efecto que se repite** —fácil de cazar, gratis— y **una pestaña que se degrada** —más difícil, y ahí sí hace falta el perfilador—. Esta pieza recorre las dos, en ese orden, porque la primera resuelve el 80% de los casos sin abrir ninguna herramienta pesada.

La fase construye el componente con fuga y lo cierra de cuatro formas. Aquí está cómo se **encuentra** una que no sabías que tenías.

---

## 🎫 El ticket

> *"Cuando guardo una plantilla me sale el mensaje de confirmación dos veces, a veces tres. Y si dejo la pestaña abierta toda la mañana, el navegador se pone lento."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

Dos síntomas otra vez, y aquí sí son **la misma causa** vista de dos maneras. Que el reporte los junte es, por una vez, correcto.

---

## 🧭 La ruta

Cuatro pasos, del más barato al más caro. El paso 1 cuesta una línea y un minuto; el paso 4 cuesta diez minutos y un snapshot. La mayoría de las investigaciones terminan en el paso 2.

### Paso 1 — ¿Se repite un efecto? Cuéntalo

No hace falta ninguna herramienta. Un contador en el sitio donde ocurre el efecto:

```ts
// Temporal, en la suscripción sospechosa.
this.templateState.templates$.subscribe((templates) => {
  console.count('TemplateList recibió');
  // …lo que hacía…
});
```

Entra a la pantalla, sal, vuelve a entrar. Cinco veces. En la sexta, provoca **una** emisión —guardar, recargar la lista, lo que dispare un `load()`—:

```
TemplateList recibió: 1
TemplateList recibió: 2
TemplateList recibió: 3
TemplateList recibió: 4
TemplateList recibió: 5
TemplateList recibió: 6
```

**Qué descarta.** Una emisión, seis recepciones. Hay **seis componentes vivos** y cinco de ellos ya no están en pantalla. Eso es una fuga, confirmada, sin abrir DevTools más allá de la consola. Si el contador dice `1`, no hay fuga en **esta** suscripción y hay que buscar en otra.

> 🧠 **El número es información, no sólo un sí o un no.** El contador dice exactamente cuántas instancias zombis hay, y eso se corresponde con cuántas veces navegaste. Si navegaste cinco veces y el contador dice seis, cada navegación deja una: la fuga está en el ciclo de vida del componente. Si dice tres tras cinco navegaciones, algo se está limpiando a veces — y eso es un bug distinto y más interesante.

### Paso 2 — ¿Qué suscripción es? La que no completa

No todas las suscripciones pueden fugarse. La pregunta que reduce la búsqueda a un par de líneas:

| La fuente | ¿Completa? | ¿Puede fugarse? |
|---|---|---|
| `this.http.get(...)` | sí, al llegar la respuesta | **no** |
| `state$` de un `*StateService` raíz | **nunca** | **sí** |
| `form.valueChanges` | nunca | **sí**, aunque muere con el formulario |
| `route.paramMap` | nunca | **sí** |
| un `async` pipe en la plantilla | — | **no**: se desuscribe con la vista |

```bash
# Busca sólo lo que puede fugarse: subscribe manuales sobre fuentes que no completan.
grep -rn "\.subscribe(" src/app --include="*.ts" | grep -v "spec.ts"
```

**Qué descarta.** Un `subscribe` sobre `HttpClient` no es sospechoso aunque no tenga desuscripción: el observable completa solo. Un `subscribe` sobre `state$` sin `takeUntilDestroyed`, `takeUntil` ni `unsubscribe` **es la fuga**, y normalmente hay una sola en toda la pantalla.

Y el caso que parece una fuga y no lo es, que conviene reconocer para no "arreglarlo":

```ts
// TemplateStateService, constructor. Nadie se desuscribe, y es CORRECTO:
// los dos servicios son providedIn: 'root' y viven lo que la aplicación.
// Una fuga es una suscripción que sobrevive a su dueño; ésta no tiene a
// quién sobrevivir.
this.authService.currentUser$
  .pipe(filter((user) => user === null))
  .subscribe(() => this.reset());
```

### Paso 3 — Cuando el efecto no es visible: Network en reposo

Hay fugas que no cuentan nada porque su efecto no se ve. Si la suscripción dispara peticiones, se cazan sin tocar el código:

DevTools → **Network** → filtro `Fetch/XHR` → **sal de la pantalla** → espera dos minutos sin tocar nada.

```
Name          Status    Type    Time
certificates  200       xhr     14 ms
certificates  200       xhr     11 ms
certificates  200       xhr     13 ms
```

**Qué descarta.** Si sigue saliendo tráfico de una pantalla que ya no está abierta, hay una suscripción viva. Y el **ritmo** te dice cuántas: si el intervalo original era de un minuto y ves tres peticiones por minuto, hay tres zombis.

Es la misma técnica que abre la investigación del panel en `forense-fase-11.md`, y es el sospechoso número uno de "el panel va lento".

### Paso 4 — Y sólo ahora: el panel Memory

Cuando el síntoma es *"se va poniendo lenta con las horas"* y no hay ningún contador que mirar ni ninguna petición que contar, toca el perfilador. Cuesta diez minutos y es la última opción, no la primera.

DevTools → **Memory** → *Heap snapshot* → **Take snapshot** (éste es el "antes").
Navega a la pantalla sospechosa y sal, **diez veces**.
**Take snapshot** otra vez (el "después").

En el segundo snapshot, en el filtro de clase escribe el nombre del componente:

```
Constructor                  Distance   Shallow Size   Retained Size
TemplateListComponent × 10       6            720          14 328
```

**× 10 es el diagnóstico entero.** Diez instancias vivas de un componente que debería tener cero, porque saliste de la pantalla diez veces.

**Cómo se sigue la cadena de retención**, que es la parte que casi nadie hace:

1. Despliega la clase y selecciona **una** de las instancias.
2. Abajo aparece el panel **Retainers** (en algunas versiones, *Object* → la ruta con `in`).
3. Léelo **de abajo hacia arriba**: la última fila es la raíz que lo mantiene vivo.

```
TemplateListComponent
  └── in destination of Subscriber          ← quién lo sostiene
      └── in _subscriptions of Subscriber
          └── in observers of BehaviorSubject
              └── in stateSubject of TemplateStateService
                  └── in _providers of R3Injector (root)          ← la raíz
```

Esa cadena se lee como una frase: **el inyector raíz mantiene vivo al servicio, el servicio a su `BehaviorSubject`, el sujeto a la lista de observadores, y ahí dentro está tu componente destruido.** Ése es el mecanismo exacto de una fuga de suscripción, y verlo una vez vale más que leerlo cinco.

**Qué descarta.** Si el componente **no** aparece en el snapshot, no hay fuga de componentes — y entonces lo que crece es otra cosa: un array que nadie vacía, una caché sin límite, o un `shareReplay` sin `refCount` reteniendo valores. Es el mismo panel y otro filtro.

> ⚠️ **Antes de creerte un snapshot, fuerza la recolección.** DevTools ejecuta un ciclo de recolección de basura al tomar el snapshot, pero si algo está vivo sólo porque el depurador lo tiene referenciado, el resultado miente. Cierra las pausas del depurador y no dejes variables en la consola apuntando a componentes.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa probable | Herramienta, por este orden |
|---|---|---|
| Un mensaje o una acción se repite N veces | N suscripciones vivas | `console.count` — paso 1 |
| Peticiones a una pantalla que ya cerraste | suscripción con efecto de red | Network en reposo — paso 3 |
| La pestaña se degrada con las horas, sin nada visible | fuga sin efecto observable | panel Memory — paso 4 |
| El derivado se recalcula muchas veces | falta `shareReplay` o `distinctUntilChanged` | `console.count` dentro del `map` |
| La memoria crece y el componente **no** aparece | no es fuga de componentes | filtra por arrays y cachés en el snapshot |
| Al volver a una pantalla ves datos viejos un instante | **no es un bug** | es tener estado: `providedIn: 'root'` — **A07** §3 |

---

## ⚰️ Los callejones

**"Toda suscripción sin cerrar es una fuga."** Falso, y creérselo lleva a llenar el proyecto de `takeUntilDestroyed` que no hacen nada. Una fuga es una suscripción que **sobrevive a quien la creó**. Un `subscribe` a `HttpClient` completa; un servicio raíz suscrito a otro servicio raíz no tiene a quién sobrevivir. El paso 2 tiene la tabla.

**"Es que Angular no libera la memoria."** La libera. Lo que no puede liberar es un objeto al que alguien sigue apuntando, y en el paso 4 se ve exactamente quién apunta. La cadena de retención no admite discusión.

**"Le pongo `OnPush` y se arregla."** Son problemas distintos. `OnPush` decide **cuándo se revisa** un componente; una fuga es un componente que **ya no existe** y sigue recibiendo. Un componente destruido con `OnPush` sigue fugado exactamente igual.

**"Los datos viejos que aparecen un segundo al volver son la fuga."** No: eso es un `BehaviorSubject` haciendo su trabajo. Guarda el último valor y se lo da a quien se suscriba, incluido el componente nuevo. Se puede evitar con un `reset()` al entrar y casi nunca conviene: un parpadeo de datos viejos molesta menos que un parpadeo de pantalla vacía.

---

## 🧨 Deshacer

Quita los `console.count` temporales antes de commitear — un contador olvidado en producción es ruido en la consola de todo el mundo. Si montaste el `TemplateCounterComponent` con fuga que construye la fase, **no lo dejes en el árbol de rutas**: está roto a propósito y su sitio es el ejercicio, no la aplicación.

Los snapshots del panel Memory viven en la sesión de DevTools y desaparecen al cerrarla; no dejan nada en el proyecto.

---

## 🧠 El patrón transferible

> **Cuenta antes de perfilar.** Un `console.count` bien puesto cuesta una línea y contesta la pregunta en un minuto; un heap snapshot cuesta diez minutos y contesta la misma pregunta. El perfilador es para cuando el efecto **no se puede contar**, no para empezar.

Y el segundo, que vale para cualquier stack con suscripciones, oyentes o *callbacks*: **la pregunta no es "¿cerré esto?" sino "¿esto puede sobrevivirme?"**. Una fuente que completa no se puede fugar por mucho que la ignores; una que no completa se fuga aunque tengas las mejores intenciones. Saber cuál es cuál convierte una revisión de código de una hora en una de cinco minutos.

**Incidentes del cuaderno que usan esta ruta:** 05 (el estado que devuelve siempre lo mismo) y 16 (el panel cerrado que sigue pidiendo).
**Amplía:** **A07** §7 para el ciclo de vida completo de una suscripción, **A06** §7 y §8 para `shareReplay` y las tres formas de desuscribirse 🧬.
