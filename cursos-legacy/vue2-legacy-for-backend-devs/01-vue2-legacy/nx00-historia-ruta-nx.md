# 🟩 Historia de la ruta NX — la rama `nuxt-ayuda`

> Ruta NX · Ficha de contexto · **Se lee antes de NX0**
> ~8 minutos · Viene de la ficha del sistema,
> [`../00-historia-del-sistema.md`](../00-historia-del-sistema.md), §3
> ("Las ramas de los sábados") y §3 ("Hoy: PizzaPaisa").

Esta ficha cuenta solo lo propio de la rama que vas a rescatar. Todo lo
compartido —quién es Felipe, qué es Cuadre, qué pidió PizzaPaisa y qué dice el
plan de remediación— vive en la ficha del sistema, y esa manda: si algo de aquí
la contradice, la equivocada es esta.

Esta ruta es distinta de las otras dos, y su rama también. Quasar y Vuetify son
frameworks de componentes: cambian cómo se ve la aplicación. Nuxt cambia **dónde
corre**. Esa diferencia explica toda la historia de abajo.

---

## 1. 🕹️ El sábado en que empezó (2022)

La idea fue de soporte, no de Felipe. Laura Marcela llevaba la cuenta: un tercio
de los tickets eran la misma docena de preguntas —*¿cómo anulo una factura?*,
*¿por qué no me imprime el cierre?*—, y la respuesta ya estaba escrita en algún
WhatsApp. Si existiera un **centro de ayuda público** que Google encontrara, el
dueño del negocio lo buscaría antes de escribir.

Felipe investigó y encontró la palabra que le faltaba: **SSR**. Una aplicación
de Vue normal le manda al navegador una página vacía y la llena con JavaScript,
y Google indexa mal lo que llega vacío. Nuxt renderiza en el servidor y manda la
página llena. Nuxt 3 todavía no era estable; Nuxt 2 corría sobre el Vue 2 que
tenían.

Y ahí Felipe tomó la decisión que define la rama: *"si el centro de ayuda va a
vivir en Nuxt, que la Tiquetera también: un solo proyecto"*. Antes de escribir
la primera página de ayuda, había que pasar toda la aplicación a Nuxt.

## 2. 🧑‍💻 Quién la llevó

**Daniela Rojas**, chica por horas desde 2022, estudiante de sistemas, la única
del equipo que había trabajado en una agencia web y sabía qué era SEO. Le tocó
la parte ingrata: meter la Tiquetera entera en Nuxt. En 2023 consiguió la
práctica profesional en otra empresa y se fue con la rama a medio camino.

## 3. 🏚️ El estado en que la encuentras

La rama `nuxt-ayuda` no tiene **ni una página de ayuda**. Tiene:

1. **La Tiquetera montada en Nuxt 2**, con las rutas convertidas a `pages/` y
   el store adaptado.
2. **Una lista de errores de `window is not defined`** a medio resolver. El
   token en `localStorage`, el socket, los restos de jQuery, el gráfico de
   chart.js: todo lo que en el navegador era obvio revienta en el servidor, donde
   `window` no existe. Daniela los fue apagando uno por uno con parches, y dejó
   anotados en un README los que faltaban. Es el mapa exacto de NX2.
3. **Una pregunta abierta** sobre dónde cargar los datos: si en el store, como
   siempre, o en `asyncData`, como pide Nuxt. Es NX3.

Y la rama **se quedó atrás**. Desde 2023 el tronco siguió recibiendo
características sobre Vue 2 a pelo. Rescatar no es mezclar: es **rehacer sobre el
tronco de hoy con la rama abierta al lado como referencia**. Lo que viaja de
2022 es el README de Daniela con los errores encontrados, que vale más que
cualquier archivo de la rama.

## 4. ⏸️ Por qué paró

Por el calendario. La migración a Nuxt se cruzó con un cierre de año de la DIAN,
el soporte se llenó de casos de facturación y los sábados se acabaron. Cuando
volvió la calma, Daniela ya no estaba y el centro de ayuda seguía sin una sola
página. Felipe aprendió ahí lo que le costó la decisión de "un solo proyecto":
para tener cinco páginas públicas, había que mover toda la aplicación.

## 5. 🍕 Lo que PizzaPaisa le pide hoy

La cadena trajo un caso que la Tiquetera no tenía previsto: el gerente de una
sede **no tiene usuario** en el sistema, y quiere saber en qué va su caso sin
llamar. Cuadre le propuso un **enlace por caso** que muestre el historial —quién
lo tomó, qué se hizo, en qué estado está— y que llegue por WhatsApp. Ese enlace
tiene que abrir rápido en el celular y mostrar la información apenas carga, sin
esperar a que una aplicación entera se monte. Renderizar en el servidor es
justo lo que Nuxt hace bien.

El centro de ayuda sigue siendo buena idea, y la cadena la mencionó: con la
rotación de cajeros en las sedes, las mismas preguntas vuelven cada mes. Pero no
está en el anexo del contrato, y por eso no está en esta ruta.

| Fase | Qué es en esta historia |
|---|---|
| **NX0** | El primer compromiso del plan de remediación: pruebas antes de tocar nada, sabiendo dónde no alcanzan |
| **NX1** | Leer lo que dejó Daniela, y entender Nuxt antes de escribir |
| **NX2** | Terminar lo que la rama dejó a medias: los `window is not defined` del README de Daniela |
| **NX3** | La pregunta que la rama dejó abierta: store o `asyncData` |
| **NX4** | Lo que la cadena pidió: el historial del caso, renderizado en el servidor |

## 6. 🧭 El camino que abre

Rescatar esta rama no mejora la primera respuesta del cuestionario de
PizzaPaisa: **Nuxt 2 llegó al final de su soporte el 30 de junio de 2024**. Lo
que sí cambia es **por dónde se sale**: desde Nuxt 2 el camino es Nuxt 3, sobre
Vue 3, y es el salto más grande de las tres rutas, porque cambian a la vez el
framework, la forma de cargar datos y el servidor que lo corre. Escoger esta
rama hoy es escoger esa salida mañana.

Al terminar NX4 escribe la **nota de decisión** del rescate, una página: qué
pedía la cadena, por qué esta rama y no las otras dos, qué cuesta después el
salto a Nuxt 3, y qué queda sin resolver. Incluye la pregunta que Felipe nunca
se hizo: ¿hacía falta mover toda la aplicación para tener unas pocas páginas en
el servidor?

> **La señal de que esta ficha hizo su trabajo:** cuando en NX2 aparezca el
> primer `window is not defined`, tu primera reacción no sea "Nuxt está roto",
> sino "esto ya lo vio Daniela; a ver qué anotó y por qué no lo terminó".
