# 🕵️ Forense Fase 05 — "Le di a guardar y no pasó nada"

> **Sale de:** [Fase 5 — CRUD de tickets](05-crud-tickets.md) ·
> **Herramientas:** la consola, Network, y Vue DevTools → Components ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el clic no produce ni request, ni error, ni
> mensaje — el formulario simplemente no hace nada.

El silencio es lo que hace difícil este caso, y el silencio tiene una causa
concreta: **el formulario ya decidió que no envía, y la decisión no se pinta en
ninguna parte.** Vuelidate sabe perfectamente qué campo está mal; el usuario no,
porque el sistema que muestra los errores depende de una condición que nadie
cumplió.

---

## 🎫 El ticket

> "Lleno el formulario de ticket nuevo, le doy a 'Crear ticket' y no pasa nada.
> No sale error, no se crea el ticket, no me lleva a ninguna parte. El botón
> hace clic, se ve que se hunde, pero de ahí no pasa. Ya probé en Chrome y en
> Edge."
>
> — agente de soporte · **Ambiente:** desarrollo

"No sale error" y "el botón se hunde" son las dos pistas. La segunda descarta
un botón deshabilitado; la primera dice que el sistema tomó una decisión en
silencio, que es exactamente lo que pasó.

---

## 🧭 La ruta

Los pasos van del más barato al más caro, y en este caso el primero es
literalmente gratis: mirar si hubo tráfico.

### Paso 1 — ¿salió algún request?

DevTools → **Network** → filtro `XHR` → clic en "Crear ticket".

```
(sin peticiones)
```

**Qué descarta.** Descarta la mitad del sistema de una vez: el servicio, el
`apiClient`, el interceptor, el mock, la red. Nada de eso llegó a intervenir. El
problema está **antes** del HTTP, en el propio componente. Si hubieras visto un
`POST /tickets` en rojo, ésta sería otra investigación completamente distinta —
la de la [Fase 3](forense-fase-03.md).

### Paso 2 — ¿el handler llegó a ejecutarse?

En la consola, sin tocar el código, con el componente del formulario
seleccionado en Vue DevTools (que lo expone como `$vm0`):

```js
> $vm0.$v.$invalid
true
> $vm0.$v.$dirty
false
```

**Qué descarta.** Descarta que el clic se haya perdido: el formulario **sí**
evaluó su estado y sabe que es inválido. Y descarta también la hipótesis de "el
`@submit.prevent` está mal puesto", porque si el evento no llegara, `$v` seguiría
en su estado inicial y no habría nada que contar. El código hizo su trabajo:

```js
handleSubmit: function () {
  this.$v.$touch();
  if (this.$v.$invalid) {
    return; // los errores ya se pintan solos vía $error
  }
  this.$emit("submit", Object.assign({}, this.form));
}
```

El `return` es correcto. Lo que hay que averiguar es por qué el usuario no ve
nada de eso.

### Paso 3 — ¿qué campo está mal, y por qué no se pinta?

Pregúntale a vuelidate campo por campo:

```js
> $vm0.$v.form.description.$invalid
true
> $vm0.$v.form.description.required
true
> $vm0.$v.form.description.minLength
false
> $vm0.$v.form.description.$error
false        // ← acá está el caso
```

**Qué descarta.** Cierra el diagnóstico. El campo `description` viola
`minLength(10)`, pero `$error` es `false`, y `$error` es lo que la plantilla
usa para pintar el mensaje. La razón está en su definición: **`$error` es
`$invalid && $dirty`**, y `$dirty` solo se pone en `true` cuando el usuario toca
el campo o alguien llama a `$touch()`. Si el `@blur` no está puesto en ese input
—o si el usuario llegó al botón sin pasar por el campo— el error existe y es
invisible.

### Paso 4 — el caso simétrico: el formulario en rojo desde el principio

Vale la pena mirarlo aunque no sea el reporte de hoy, porque es el mismo
mecanismo al revés y llega como ticket la semana siguiente. Si en la plantilla
aparece `$invalid` donde debería ir `$error`:

```
El formulario se pinta con todos los campos en rojo antes de escribir una letra.
```

**Qué descarta.** Descarta que sea "otro bug": es el mismo par de propiedades,
usado al revés. `$invalid` contesta *"¿esto viola una regla ahora?"* —y un
formulario vacío las viola todas—; `$error` contesta *"¿esto viola una regla y
el usuario ya tuvo su oportunidad?"*. La UI se construye sobre la segunda.

### Paso 5 — ¿y el ticket que sí se creó… dos veces?

Última rama del mismo formulario, y la más cara en datos. Si el reporte fue "se
me creó dos veces el mismo ticket":

```
Name      Status   Type   Size
tickets   201      xhr    412 B
tickets   201      xhr    412 B
```

**Qué descarta.** Descarta el mock —contestó dos veces porque le pidieron dos
veces— y apunta al botón: sin `:disabled="saving"`, un doble clic manda dos
POST. La fase lo trae resuelto con la prop `saving`, así que si lo ves en un
proyecto ajeno, la pregunta es quién quitó el binding, y `git log -S "saving"`
te lo dice.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Clic en guardar y nada, sin request en Network | El submit se cortó en `$v.$invalid`, y el error no se pinta |
| Todo en rojo antes de escribir | `$invalid` usado donde va `$error` |
| Un campo inválido sin mensaje visible | Falta `$touch()` en ese campo: `$dirty` sigue en `false` |
| Se crean dos tickets iguales de un clic | Botón sin `:disabled="saving"` |
| Tooltips del navegador peleando con tus mensajes | Falta `novalidate` en el `<form>` |
| Editas un ticket y se modifica también en la lista antes de guardar | Se mutó la prop en vez de clonarla a `form` |
| El formulario limpia los campos pero sigue en rojo | Se reseteó `form` sin `$v.$reset()` |
| El ticket se crea con `status` o `reporter` inventados por el navegador | Reglas de negocio en el formulario: 💸 deuda declarada, se paga con backend real |

---

## ⚰️ Los callejones

**"El evento no llega, será el `.prevent`."** Es la primera sospecha razonable y
se descarta en el paso 2: si el handler no corriera, `$dirty` no habría cambiado
nunca. Además, si `@submit.prevent` estuviera mal, verías la página recargarse
entera — un síntoma imposible de confundir.

**"Es el servicio, que no está devolviendo la Promise."** Ese bug existe y es
real, pero produce otro síntoma: request en Network y vista que no reacciona. Acá
no hubo request. Cuando el paso 1 sale vacío, todo lo que vive detrás del HTTP
queda descartado de un plumazo, y conviene decírselo a uno mismo en voz alta
para no seguir mirando ahí.

**"Vuelidate está mal configurado."** Casi nunca. La confusión `$error` /
`$invalid` no es un fallo de la librería sino de lectura: las dos propiedades
existen, las dos son correctas, y contestan preguntas distintas. Antes de
sospechar de la herramienta, mira su tabla de estado —está en la sección de
concepto de la fase— y decide cuál de las dos preguntas querías hacer.

---

## 🧨 Deshacer

Si probaste el paso 5 y te quedaron tickets duplicados en el mock:

```bash
git checkout -- db.json     # si tenías tus escenarios commiteados
npm run mock:reset          # o desde la semilla, y se lleva todo lo demás
```

---

## 🧠 El patrón transferible

**Un sistema que decide en silencio produce tickets sin información.** El
formulario sabía exactamente qué estaba mal, con nombre de campo y regla
violada, y esa información se quedó adentro porque la condición que la muestra
—"el usuario ya tuvo su oportunidad"— no se cumplió. El bug no está en la
validación: está en el puente entre lo que el sistema sabe y lo que el sistema
cuenta.

Cuando heredes un formulario ajeno, la pregunta rápida es siempre la misma:
**¿qué distingue "todavía no" de "está mal"?** Si el código no tiene esa
distinción escrita en alguna parte, o vas a molestar al usuario desde la primera
tecla, o vas a callarte cuando más falta hace.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 5](05-crud-tickets.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 05](cuaderno-incidentes.md); y la versión con tres pasos y estado
compartido en la [pieza de la Fase 6](forense-fase-06.md).
