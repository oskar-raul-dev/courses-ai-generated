# 🕵️ Forense Fase 06 — El estado que todavía no existe

> Pieza forense de la [**Fase 6 — Órdenes**](./06-ordenes.md) · Recorrido: ~35 min · [Índice del track](./forense-master.md)
> Herramientas: el árbol del store · Network (filtro `JS`) · el stack trace, con desconfianza
> Síntoma que cubre: la aplicación se cae en una pantalla, y la culpa es de otra que nadie abrió.

Es la primera vez que el curso te pide diagnosticar algo cuyo síntoma **depende de la ruta que tomó el usuario**. Esa clase de bug es de las que más caro salen, porque no se reproduce contándole a alguien lo que hiciste: lo que importa es lo que hiciste *antes*. Y el reporte nunca lo incluye, porque para quien lo escribe no forma parte de la historia.

---

## 🎫 El ticket

> *"Abrí el sistema esta mañana y se cayó la pantalla de pacientes. Todo en blanco. Le mandé el pantallazo a mi compañera y a ella le funciona perfecto, con el mismo usuario."*

**Reportado por:** una auxiliar de recepción
**Ambiente:** UAT
**Lo que trae adjunto:** una pantalla en blanco y un mensaje de consola que alguien tuvo la precaución de copiar.

```
ERROR TypeError: Cannot read property 'items' of undefined
    at patient-list.component.html:14
```

"A ella le funciona" es el dato. No es un problema de datos, ni de permisos, ni de red: es que las dos sesiones no pasaron por los mismos sitios.

---

## 🧭 La ruta

Cuatro pasos. El primero cuesta veinte segundos y es el único que hace falta el 80% de las veces; el cuarto es el que convierte el hallazgo en una decisión, y no es de código.

### Paso 1 — El árbol del store: ¿la clave está, o no está?

Redux DevTools → pestaña **State**, con la pantalla rota delante. No mires el valor: mira **las claves de primer nivel**.

```json
{
  "patients": {
    "items": [ … ],
    "loading": false,
    "error": null
  }
}
```

Una sola clave. `orders` no aparece.

**Qué descarta.** Ésta es la distinción que decide la investigación entera, y es fácil pasarla por alto: **no está vacía, no está**. Una clave con un objeto dentro y `items: []` significaría que el slice existe y no trajo datos —problema de carga, de filtro o de servidor—. Una clave ausente significa que el reducer **nunca se registró**, y eso no tiene nada que ver con los datos.

Muere entonces todo lo relacionado con el mock, la red y el `db.json`. La pregunta pasa a ser por qué un reducer no está registrado.

### Paso 2 — La carga diferida, vista desde Network

No se lo preguntes al código: pregúntaselo al navegador. Network → filtro `JS` → *Disable cache* → recarga en `/patients` y mira qué `.js` se descargan. Después navega a `/orders` y mira otra vez.

```
Name                             Status  Type    Size     Time
patients-patients-module.js      200     script  24.1 kB  9 ms      ← al entrar a /patients
orders-orders-module.js          200     script  21.7 kB  8 ms      ← solo al navegar a /orders
```

**Qué descarta.** El chunk de órdenes llega **cuando se navega**, no al arrancar. Y `StoreModule.forFeature('orders', ordersReducer)` vive dentro de ese módulo, así que el slice nace en ese instante y no antes. Con eso queda explicado el "a ella le funciona": su sesión pasó por `/orders` en algún momento y la tuya no.

Si el chunk de órdenes **sí** apareciera al arrancar, el diagnóstico sería el contrario y también útil: alguien importó `OrdersModule` desde un módulo que se carga al inicio, la carga diferida murió, y el bug que estás persiguiendo no puede ser éste. Se comprueba con un `grep`:

```bash
grep -rn "OrdersModule" src/ --include="*.module.ts"
```

### Paso 3 — Quién preguntó, que casi nunca es donde revienta

El stack trace dice `patient-list.component.html:14`, y ahí no está el bug. Lo que hay en esa línea es **el consumidor**, no la causa. Ábrelo y busca qué selector se está pidiendo:

```bash
grep -n "Orders" src/app/patients/patient-list/patient-list.component.ts
# 12:import * as OrdersSelectors from '../../orders/store/orders.selectors';
# 47:    this.store.select(OrdersSelectors.selectAllOrders).subscribe(…)
```

Y en el selector, la línea que decide si esto revienta o no:

```typescript
export const selectAllOrders = createSelector(
  selectOrdersState,
  function (state) { return state.items; }          // ❌ revienta si el slice no existe
);

export const selectAllOrders = createSelector(
  selectOrdersState,
  function (state) { return state && state.items ? state.items : []; }   // ✅
);
```

**Qué descarta.** Con eso la ruta termina: sabes que el error no está en la pantalla que se rompió, sino en que **alguien preguntó por un estado que aún no había nacido**. La mentira del stack trace es de las más caras del curso, porque nombra un archivo real, existente y perfectamente inocente.

> 🧭 **La guarda va en el selector derivado, no en el `createFeatureSelector`.** Ése devuelve `undefined` y no hay forma de evitarlo: es NgRx diciéndote la verdad. Lo que se decide es qué hace el consumidor con esa verdad.

### Paso 4 — La pregunta que decide el fix: ¿tenía derecho a preguntar?

La guarda hace que la pantalla no se caiga. La pregunta que va antes es **si esa pantalla debía estar preguntando**, y la contestación cambia el fix por completo:

- **Sí tenía derecho.** El dashboard de la Fase 10 lee órdenes, muestras y resultados por diseño: es una pantalla transversal y no puede exigir que el usuario haya paseado antes por las tres rutas. Ahí la guarda es correcta y además insuficiente — la solución completa es asegurar la carga del slice antes de entrar, o registrar el reducer en la raíz. Decisión de arquitectura, no hotfix ([**A06 §6**](./a06-ngrx.md)).
- **No tenía derecho.** Si la pantalla de pacientes está leyendo órdenes para mostrar un contador que nadie pidió, la guarda **tapa un error de diseño**: devuelve `[]`, la pantalla dice "0 órdenes", y ese cero es mentira. No es lo mismo "no hay" que "no lo sé todavía", y el `[]` borra la diferencia.

**Qué descarta.** Nada técnico: descarta la ilusión de que había un solo fix. Devolver `[]` es una traducción cómoda que **esconde información**, y hay pantallas donde esconderla cuesta un dato equivocado en vez de una pantalla caída.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| `Cannot read property 'items' of undefined` | slice no registrado; nadie navegó a esa ruta | las **claves** del árbol del store |
| La clave existe con `items: []` | el slice existe y no trajo datos | el log de acciones: ¿hubo `Load … Success`? |
| Funciona si vengo por acá y no si vengo por allá | dependencia del orden de navegación | qué chunks llegaron en Network |
| Reventó en una pantalla que no menciona el slice culpable | el stack trace nombra al consumidor | el `import` del selector en ese componente |
| El chunk del módulo llega al arrancar y no al navegar | alguien lo importó desde un módulo eager | `grep` del módulo en los `.module.ts` |
| La pantalla muestra "0" donde debería mostrar "no lo sé" | la guarda devolvió `[]` sobre un slice ausente | el mismo selector, y la decisión del paso 4 |
| La columna del paciente sale vacía en la tabla de órdenes | el slice de pacientes no se cargó, o filtras por `active` | el selector que consume esa columna |
| `Cannot find control with name: 'i'` | `formControlName="i"` sin corchetes | la plantilla del `FormArray` |
| Borras un examen y desaparece otro | se guardó un índice y `removeAt` corrió los demás | el `*ngFor` del `FormArray` |

---

## ⚰️ Los callejones

**"Es un problema de la pantalla de pacientes."** Lo dice el stack trace, y por eso mucha gente empieza —y termina— ahí. Pero la pantalla de pacientes funciona perfectamente si el usuario pasó antes por órdenes: **el mismo código, la misma sesión, dos comportamientos.** Cuando un archivo funciona a veces sin haber cambiado, el bug no está en ese archivo.

**"El servidor no devolvió las órdenes."** Se descarta sin abrir Network: si el slice no está registrado, **nadie pidió nada**. No hay petición que mirar, y buscarla es la forma más rápida de perder veinte minutos.

**"Hay que quitar la carga diferida."** Arregla el síntoma y traslada el costo a todos los usuarios: el bundle inicial se lleva por delante los cuatro módulos, y la primera carga se paga en cada visita para que una pantalla no falle. La conversación correcta es qué slices son transversales de verdad y merecen vivir en la raíz — que son pocos, y ninguno es "todos".

**"Con la guarda ya está resuelto."** Está resuelto que no se caiga. Si la pantalla que preguntó no tenía derecho a preguntar, la guarda convierte una caída ruidosa en un dato silencioso y equivocado, que es un cambio a peor disfrazado de fix. El precio de esa comodidad es el ejercicio 14 de la fase.

---

## 🧨 Deshacer

El recorrido sólo toca una línea, y conviene devolverla:

```bash
git checkout -- src/app/orders/store/orders.selectors.ts
```

Comprueba que quedó como estaba por el camino corto: **cierra la pestaña** —no basta con recargar si el módulo ya se cargó en esta sesión— y abre la aplicación directamente en `/patients`. Si se cae, la guarda no está; si no se cae, está.

Ese "cierra la pestaña" es parte del método, no una manía: reproducir un bug que depende del orden de navegación exige empezar la sesión de cero, y una recarga con el chunk ya en caché no lo es.

---

## 🧠 El patrón transferible

> **"Funciona si vengo por acá y no si vengo por allá" es una firma, y una vez que la reconoces la ves en todas partes.** Cuando el mismo código se comporta distinto sin haber cambiado, la variable no está en el código: está en el camino. En una SPA con carga diferida ese camino decide qué existe y qué no, y el reporte del usuario nunca lo menciona porque para él no es parte de la historia. La primera pregunta ante un bug irreproducible es *"¿por dónde entraste?"*.

Y el segundo, que es el más transferible de la fase: **el error te da el nombre del síntoma, no el del culpable.** Un stack trace apunta a donde reventó, que es siempre el consumidor. En un sistema con estado compartido, el consumidor casi nunca es el responsable — y aprender a leer el trace hacia atrás, del que se rompió al que preguntó, es lo que separa treinta segundos de veinte minutos.

**Incidentes del cuaderno que usan esta ruta:** ninguno propio — esta fase no reserva IDs. Pero la ruta se reutiliza entera en el **16** (Fase 10), donde el mismo `undefined` llega desde el dashboard y con más slices en juego.
**Amplía:** el [**Apéndice A06 §6**](./a06-ngrx.md) para la decisión entre `forFeature` y `forRoot`, y [`forense-fase-10.md`](./forense-fase-10.md) para la versión del mismo bug con tres slices ausentes a la vez.
