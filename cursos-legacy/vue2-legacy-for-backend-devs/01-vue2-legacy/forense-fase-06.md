# 🕵️ Forense Fase 06 — "Volví atrás en el wizard y perdí lo que había escrito"

> **Sale de:** [Fase 6 — Wizard mínimo](06-wizard-minimo.md) ·
> **Herramientas:** Vue DevTools → Components (el árbol y los hooks), y la
> consola · **Recorrido:** cuatro pasos
>
> **El síntoma, en una línea:** el paso al que vuelves aparece vacío, o
> parcialmente vacío, y nadie borró nada.

Acá el sistema no pierde datos: **destruye componentes**, que es otra cosa y se
diagnostica distinto. La investigación consiste en separar tres estados que el
usuario ve como uno solo — lo que está en el borrador, lo que está en el
formulario del paso, y lo que está en el estado de validación — y averiguar
cuál de los tres murió.

---

## 🎫 El ticket

> "Estoy creando un ticket con el asistente, lleno el paso 1, paso al 2, me doy
> cuenta de que me equivoqué en el título y le doy 'Atrás'. El título está,
> pero la descripción se me borró. Y los mensajitos rojos de error también
> desaparecieron, aunque el campo sigue mal."
>
> — agente de soporte · **Ambiente:** desarrollo

Ojo al detalle que casi nadie reporta: **una parte se conservó y otra no.** Eso
descarta de entrada "se perdió todo" y convierte el caso en una pregunta mucho
más precisa: ¿qué distingue lo que sobrevivió de lo que no?

---

## 🧭 La ruta

Del más barato al más caro: el árbol de componentes y sus hooks contestan casi
todo, y solo al final hace falta abrir el archivo.

### Paso 1 — ¿el componente del paso sigue vivo, o vuelve a nacer?

Vue DevTools → **Components**. Avanza al paso 2, vuelve al paso 1, y mira el
árbol mientras lo haces.

```
<TicketWizardView>
  └─ <TicketStepBasics>      ← desaparece del árbol al avanzar
```

Para confirmarlo sin depender del ojo, la fase ya trae el experimento hecho
—es su ejercicio 5—: pon un `console.log` en `created` del paso 1 y navega
adelante y atrás.

```
[paso 1] created
[paso 1] created      ← al volver: nació otra vez
```

**Qué descarta.** Descarta que alguien esté limpiando datos. Nadie borró la
descripción: el componente que la contenía dejó de existir y volvió a nacer
vacío. Si en vez de un segundo `created` vieras un `activated`, el componente
estaría vivo y el caso sería otro — salta al paso 3.

### Paso 2 — ¿por qué se destruye?

Mira la plantilla del wizard, solo esa línea:

```bash
grep -n "component :is\|keep-alive" src/views/TicketWizardView.vue
```

```
84:      <component :is="currentStepComponent" ref="stepComponent" />
```

**Qué descarta.** Cierra la primera mitad del caso. `<component :is>` **destruye
y monta** por diseño: es su contrato. `keep-alive` es lo que lo convierte en
"esconder y mostrar", y acá no está. Sin él, cada avance es una muerte y cada
retroceso, un nacimiento.

### Paso 3 — entonces, ¿por qué el título sí sobrevivió?

Con el paso 1 en pantalla, compara sus datos con los del padre:

```
<TicketWizardView>
  data
    draft: { title: "La impresora no imprime", description: "", priority: "" }

  <TicketStepBasics>
    data
      form: { title: "La impresora no imprime", description: "" }
```

**Qué descarta.** Descarta la teoría de "se pierde todo al volver" y explica el
reporte tal cual: el paso **entrega** sus datos al borrador del padre cuando
avanzas, y al volver a nacer se inicializa leyendo ese borrador. Lo que llegó al
`draft` sobrevive; lo que se quedó a medio escribir en el paso, no. Por eso
sobrevivió el título —validado y entregado— y no la descripción.

### Paso 4 — ¿y los mensajes de error?

Última pregunta del ticket, y la que más despista:

```js
> $vm0.$v.$dirty
false
```

**Qué descarta.** Descarta cualquier problema con vuelidate. El estado de
validación —`$dirty`, `$error`, el `$touch()` que ya habías provocado— vive
**dentro** del componente, no en el borrador. Un componente nuevo trae un `$v`
nuevo, virgen, sin memoria de que alguien tocó nada. El campo sigue siendo
inválido, pero volvió a ser "todavía no lo tocaste", que es exactamente lo que
la [Fase 5](forense-fase-05.md) enseñó a distinguir.

Acá termina el recorrido: sabes qué se destruye, por qué, y qué parte de lo
perdido vive en cada sitio. El fix es de la fase (`keep-alive`, y el hook pasa a
ser `activated`).

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Vuelves atrás y el paso está vacío | Falta `keep-alive`: el componente se destruyó y nació de nuevo |
| Vuelves atrás y sobrevive parte de lo escrito | Lo que llegó al `draft` vive; lo que se quedó en el paso, no |
| Los errores de validación desaparecen al volver | `$v` es del componente: nace virgen con él |
| Pusiste `keep-alive` y ahora los datos no se refrescan | `created`/`mounted` ya no se repiten: el hook que buscas es `activated` |
| Te deja avanzar con el paso 2 vacío | La validación corre al final, no por paso: `validate()` no se está invocando al avanzar |
| No te deja volver atrás con el paso inválido | Se está validando también hacia atrás: retroceder nunca debería exigir validez |
| Sales del wizard y te pregunta si quieres abandonar, después de crear el ticket | Falta apagar el `beforeRouteLeave` en el camino del éxito |
| Recargas con F5 y pierdes todo | Es el diseño: el borrador vive en el componente, no en `sessionStorage` |

---

## ⚰️ Los callejones

**"Se borró el borrador."** El `draft` del padre no se toca nunca en este flujo:
el paso 3 lo muestra intacto. Cuando un dato "se borra" al navegar dentro de la
misma vista, sospecha del ciclo de vida antes que de una asignación — es mucho
más frecuente que alguien destruya un componente sin querer que alguien escriba
`draft = {}`.

**"Es que `$refs` no está funcionando."** `$refs.stepComponent` apunta al
componente vivo, y cuando el paso se remonta apunta al nuevo. Funciona
perfectamente; lo que cambió es a quién apunta. Si sospechas de `$refs`,
compruébalo en la consola antes de tocar nada: es una línea.

**"Hay que meter el borrador en Vuex."** Es la respuesta correcta a **otro**
problema —pasos en rutas distintas, o "retomar donde quedé"— y la fase lo
explica en su tabla de decisión. Para este síntoma no arregla nada: el estado de
validación seguiría muriendo con el componente, porque `$v` nunca estuvo en el
borrador.

---

## 🧨 Deshacer

Si quitaste el `keep-alive` para reproducir —el ejercicio 6 lo pide—, vuelve con:

```bash
git checkout -- src/views/TicketWizardView.vue
```

Y si dejaste `console.log` en los hooks para el paso 1, bórralos antes de
commitear: el ruido en consola de mañana es el bug fantasma de pasado mañana.

---

## 🧠 El patrón transferible

**El estado de un formulario no es una cosa: son tres**, y viven en sitios
distintos con vidas distintas. Los datos entregados (el borrador), los datos en
edición (el `form` del paso), y el estado de la interacción (qué tocó el
usuario, qué se le mostró). Cuando algo "se pierde", la pregunta útil no es
"¿quién lo borró?" sino **"¿en cuál de los tres vivía, y quién es dueño de esa
vida?"**.

Y una regla que se transfiere a cualquier framework con componentes: **montar y
desmontar no es lo mismo que mostrar y ocultar**, aunque en pantalla se vean
idénticos. Cada vez que veas un intercambio dinámico de componentes, pregúntate
qué muere con ellos — porque algo siempre muere, y el usuario lo va a notar
antes que tú.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 6](06-wizard-minimo.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 06](cuaderno-incidentes.md) del cuaderno.
