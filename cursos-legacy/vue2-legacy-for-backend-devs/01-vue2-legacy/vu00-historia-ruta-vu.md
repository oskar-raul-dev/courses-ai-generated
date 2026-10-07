# 🟣 Historia de la ruta VU — la rama `vuetify-redesign`

> Ruta VU · Ficha de contexto · **Se lee antes de VU0**
> ~8 minutos · Viene de la ficha del sistema,
> [`../00-historia-del-sistema.md`](../00-historia-del-sistema.md), §3
> ("Las ramas de los sábados") y §3 ("Hoy: PizzaPaisa").

Esta ficha cuenta solo lo propio de la rama que vas a rescatar. Todo lo
compartido —quién es Felipe, qué es Cuadre, qué pidió PizzaPaisa y qué dice el
plan de remediación— vive en la ficha del sistema, y esa manda: si algo de aquí
la contradice, la equivocada es esta.

---

## 1. 🕹️ El sábado en que empezó (2022)

La rama nació de un cansancio. Cada tabla de la Tiquetera tenía su orden, su
filtro y su paginación **escritos a mano**, cada una un poco distinta, y cada
pedido nuevo de soporte ("¿se puede ordenar por agente?") era otra tarde de
código repetido. Felipe lo había hecho cuatro veces, y la quinta se preguntó si
no había algo que ya lo trajera hecho.

Lo había. `v-data-table`, de Vuetify, trae orden, filtro y paginación en una
sola etiqueta. Vuetify, además, prometía que la aplicación se viera *"como
Google"*, con Material Design, y eso fue lo que encendió al chico que la llevó.
Vuetify 3 todavía no había salido; Vuetify 2 corría sobre el Vue 2 que tenían.

## 2. 🧑‍💻 Quién la llevó

**Kevin Marín**, chico por horas desde 2021, el más rápido del equipo y el que
más cuidaba cómo se veían las cosas. Felipe le dio los sábados y la libertad, y
Kevin rediseñó media aplicación en la cabeza antes de escribir la primera
línea. A mediados de 2022 una empresa de afuera lo contrató remoto, en dólares,
y se fue con dos semanas de aviso. Nadie lo culpa: es la historia de media
generación de desarrolladores colombianos de esos años.

## 3. 🏚️ El estado en que la encuentras

La rama `vuetify-redesign` tiene:

1. **Vuetify instalado sobre el proyecto de siempre**, con `vue add vuetify`.
   No hay proyecto nuevo: Vuetify entró encima de Vue CLI, y por eso Bootstrap y
   Vuetify cargan juntos.
2. **El layout principal en `v-app` y `v-navigation-drawer`**, y el tema de
   colores que Kevin eligió.
3. **La tabla del dashboard migrada a medias**: `v-data-table` pinta los datos,
   pero el orden y la paginación se pelean con el estado que el dashboard guarda
   en Vuex. Es el conflicto exacto que VU3 te va a poner delante: *¿quién manda,
   el componente o el store?* Kevin no alcanzó a decidirlo.
4. **Ninguna prueba.** Kevin probaba mirando.

Y la rama **se quedó atrás**. Desde 2022 el tronco siguió recibiendo
características sobre Vue 2 a pelo, y nadie las llevó a la rama. Rescatar no es
mezclar: es **rehacer sobre el tronco de hoy con la rama abierta al lado como
referencia**. Lo que viaja de 2022 son las decisiones de Kevin —el layout, el
tema, la lista de pantallas que pensaba migrar—, no sus archivos.

## 4. ⏸️ Por qué paró

Porque se fue la única persona que la entendía, en la peor semana: con la tabla
a medio migrar y sin una nota que dijera en qué estaba pensando. Felipe la abrió
dos veces después, no supo por dónde seguir sin romper el dashboard, y la volvió
a cerrar. La regla de taller ganó: *si sirve, no lo toque*.

## 5. 🍕 Lo que PizzaPaisa le pide hoy

La firma de TI de la cadena preguntó cómo se miden los tiempos de respuesta del
soporte, y el contrato terminó con un compromiso: **informes de cumplimiento por
sede**, con tablas que se puedan ordenar, filtrar, paginar y exportar. Veinte
sedes, cientos de casos al mes, y el jefe de operaciones mirando. Escribir esas
tablas a mano por sexta vez es exactamente lo que Kevin quería dejar de hacer.

| Fase | Qué es en esta historia |
|---|---|
| **VU0** | El primer compromiso del plan de remediación: pruebas antes de tocar nada |
| **VU1** | Leer lo que dejó Kevin, y entender Vuetify antes de escribir |
| **VU2** | El formulario de tickets, que Kevin no alcanzó a tocar |
| **VU3** | Terminar lo que la rama dejó a medias: la tabla, y la decisión entre el componente y el store |
| **VU4** | Lo que la cadena pidió de nuevo: el historial de cada caso, base para medir tiempos |

## 6. 🧭 El camino que abre

Rescatar esta rama no mejora la primera respuesta del cuestionario de
PizzaPaisa: **Vuetify 2 llegó al final de su soporte el 25 de enero de 2025**.
Lo que sí cambia es **por dónde se sale**: desde Vuetify 2 el camino es Vuetify
3, sobre Vue 3, con cambios fuertes en la grilla y en `v-data-table`. Escoger
esta rama hoy es escoger esa salida mañana.

Al terminar VU4 escribe la **nota de decisión** del rescate, una página: qué
pedía la cadena, por qué esta rama y no las otras dos, qué cuesta después el
salto a Vuetify 3, y qué queda sin resolver. Y escríbela pensando en el próximo
Kevin: que quien abra la rama dentro de un año sepa en qué estabas pensando.

> **La señal de que esta ficha hizo su trabajo:** cuando en VU3 la tabla y el
> store se peleen, tu primera reacción no sea "qué desorden", sino "aquí fue
> donde Kevin se quedó, y ahora me toca decidir lo que él no alcanzó".
