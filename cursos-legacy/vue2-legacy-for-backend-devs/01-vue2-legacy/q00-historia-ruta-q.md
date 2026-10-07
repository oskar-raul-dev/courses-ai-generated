# 🔷 Historia de la ruta Q — la rama `quasar-app`

> Ruta Q · Ficha de contexto · **Se lee antes de Q0**
> ~8 minutos · Viene de la ficha del sistema,
> [`../00-historia-del-sistema.md`](../00-historia-del-sistema.md), §3
> ("Las ramas de los sábados") y §3 ("Hoy: PizzaPaisa").

Esta ficha cuenta solo lo propio de la rama que vas a rescatar. Todo lo
compartido —quién es Felipe, qué es Cuadre, qué pidió PizzaPaisa y qué dice el
plan de remediación— vive en la ficha del sistema, y esa manda: si algo de aquí
la contradice, la equivocada es esta.

---

## 1. 🕹️ El sábado en que empezó (2021)

Felipe llevaba meses mirando Quasar de reojo. Lo que lo convenció no fueron los
componentes, sino una frase de su documentación: el **mismo código fuente** se
compila como SPA, como PWA, como app de escritorio o como app de celular. Para
alguien que había armado máquinas de arcade con una sola imagen maestra para
todas, la idea era irresistible: *"con Quasar sacamos la app del celular para
los agentes con el mismo código"*.

Quasar 2 ya existía, pero pedía Vue 3. Felipe escogió **Quasar 1** sin dudarlo:
era la versión que corría sobre el Vue 2 que ya tenían, y no tocar Vue era
condición para que el experimento cupiera en unos sábados.

## 2. 🧑‍💻 Quién la llevó

**Santiago Henao**, uno de los chicos por horas que llegaron por la cartelera,
estudiante de sistemas, el que más sabía de celulares del equipo. Felipe ponía
la idea y el entusiasmo; Santiago, la paciencia para pelear con Cordova y con
el SDK de Android. Se graduó en 2022 y se fue a trabajar a un banco. Contesta
por LinkedIn, con cariño y sin detalles.

## 3. 🏚️ El estado en que la encuentras

La rama `quasar-app` tiene tres cosas, en este orden de utilidad:

1. **Un proyecto Quasar CLI armado**, con su `quasar.conf.js`, los boot files
   del cliente HTTP y del interceptor de token, y el layout principal en
   `QLayout`. Es lo más valioso de la rama: las decisiones de estructura ya
   están tomadas.
2. **El login y la mitad del formulario de tickets migrados.** El resto de la
   aplicación sigue siendo el Bootstrap de siempre, cargado al lado de Quasar,
   con las dos hojas de estilo peleándose por clases como `.row`. Es el estado
   exacto que Q1 te describe: *alguien empezó a migrar, no terminó, y quedaron
   los dos.*
3. **Un build de Cordova** que instaló una vez en el Android de Felipe y en
   ningún otro teléfono.

Y tiene un problema que no se ve en el código: **la rama se quedó atrás**. Desde
2021 el tronco siguió recibiendo características sobre Vue 2 a pelo —el panel
de soporte creció, entró la tabla de puntajes en el monitor, cambiaron filtros—,
y nadie las llevó a la rama. Mezclarla hoy con el tronco sería resolver
conflictos durante semanas para obtener algo viejo.

Por eso, en esta ruta, **rescatar no es mezclar: es rehacer sobre el tronco de
hoy, con la rama abierta al lado como referencia**. Por eso Q1 crea un proyecto
nuevo (`tiquetera-q`) en vez de abrir la rama: lo que viaja de 2021 son las
decisiones, no los archivos.

## 4. ⏸️ Por qué paró

Porque nadie la necesitaba. Los agentes trabajaban en el portátil, con dos
pantallas, y una app en el celular no les resolvía nada. Sin un usuario que la
pidiera, la rama quedó para "cuando haya tiempo", que en una empresa de tres
socios es nunca.

## 5. 🍕 Lo que PizzaPaisa le pide hoy

El usuario que faltaba apareció con la cadena. En las sedes de PizzaPaisa
**nadie tiene portátil**: el gerente y el franquiciado tienen el celular y, con
suerte, la caja. La cadena pidió que puedan **abrir un caso y seguirlo desde el
teléfono**, sin llamar a nadie. Una interfaz que se adapte al celular, con
formularios y tablas que no se rompan en una pantalla de seis pulgadas, es
exactamente lo que Quasar trae resuelto.

| Fase | Qué es en esta historia |
|---|---|
| **Q0** | El primer compromiso del plan de remediación: pruebas antes de tocar nada |
| **Q1** | Leer lo que dejaron Felipe y Santiago, y entender Quasar antes de escribir |
| **Q2** | Terminar lo que la rama dejó a medias: el formulario de tickets |
| **Q3** | Lo que la rama nunca tocó: la tabla del dashboard |
| **Q4** | Lo que la cadena pidió de nuevo: el historial de cada caso, visible para quien lo abrió |

La app de celular instalable queda **fuera** del rescate, y a propósito: la
cadena pidió verlo en el teléfono, no instalar nada. Si algún día lo pide, la
base ya estará en Quasar.

## 6. 🧭 El camino que abre

Rescatar esta rama no mejora la primera respuesta del cuestionario de
PizzaPaisa: **Quasar 1 llegó al final de su soporte el 30 de junio de 2023**,
antes incluso que Vue 2. Lo que sí cambia es **por dónde se sale**: desde Quasar
1 el camino natural es Quasar 2, que corre sobre Vue 3, con su propia guía de
migración. Escoger esta rama hoy es escoger esa salida mañana.

Al terminar Q4 escribe la **nota de decisión** del rescate, una página: qué
pedía la cadena, por qué esta rama y no las otras dos, qué cuesta después el
salto a Quasar 2, y qué queda sin resolver. Es el documento que Felipe le
muestra a la firma de TI de PizzaPaisa en la siguiente revisión.

> **La señal de que esta ficha hizo su trabajo:** cuando abras el `quasar.conf.js`
> en Q1 y tu pregunta no sea "¿qué es esto?", sino "¿qué de esto decidió Felipe
> en 2021, y sigue valiendo para un gerente con un celular?".
