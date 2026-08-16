# 📎 Apéndice A08 — PDF en cliente

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **3h**
> Usado por: Fase 9 · Versión cubierta: **jsPDF 1.5.3** sobre Angular 8.2.14 y TypeScript 3.5.3
> Comparadas y no instaladas: `pdfmake` 0.1.x · `jspdf-autotable` 3.5.x
> Estado: Base

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una sola pregunta, la que aparece cada vez que un informe sale distinto de lo que esperabas: **por qué el papel no se parece a la pantalla.**

Antes de nada, la idea que ordena todo lo demás: **un PDF no es texto, es dibujo.** jsPDF no maqueta, no reflowea, no sabe qué es un párrafo ni una tabla. Te da una hoja con un sistema de coordenadas y un lápiz, y cada llamada pone tinta en un punto. Si el texto se sale de la hoja, se sale; si el glifo no existe en la fuente, sale un cuadradito; si escribiste antes de elegir la fuente, ese texto ya salió con la anterior. Casi todos los bugs de este apéndice son consecuencia directa de esa frase.

**Qué queda fuera:** el dato viejo del informe —el `reportSnapshot` congelado en `ngOnInit`, la deuda 💸 de la fase y el incidente **14**— porque **no es un problema de PDF**: la librería dibuja fielmente lo que le pasan, y si le pasan un valor de hace diez minutos, lo dibuja. Eso vive en la **Fase 9 §4, §5.2 y §6**, y si tu síntoma es "el PDF dice 105 y la pantalla dice 118", este apéndice no te sirve. Tampoco entra el armado concreto del informe del laboratorio (**Fase 9 §5.1**), cómo se resuelven las etiquetas por i18n (**A07 §7**, con su regla de guardar la clave y traducir al dibujar), el marcado de entrega (**Fase 9 §5.4**), las herramientas para medir el peso de un bundle (**A04 §5**, que es su dueño), ni la **firma digital real**, que está fuera del alcance del curso y solo aparece en §7 para decir por qué no se puede hacer desde el navegador.

---

## Índice

- [1. El mapa en una página](#1-el-mapa-en-una-página)
- [2. Armar el documento más allá de cinco líneas](#2-armar-el-documento-más-allá-de-cinco-líneas)
- [3. Fuentes: de un `.ttf` a un `addFont`](#3-fuentes-de-un-ttf-a-un-addfont)
- [4. Acentos: qué pasa exactamente y cómo se diagnostica](#4-acentos-qué-pasa-exactamente-y-cómo-se-diagnostica)
- [5. El peso: dónde vive y cómo se saca del arranque](#5-el-peso-dónde-vive-y-cómo-se-saca-del-arranque)
- [6. Descargar, abrir, imprimir](#6-descargar-abrir-imprimir)
- [7. Lo que jsPDF 1.5.3 no hace](#7-lo-que-jspdf-153-no-hace)
- [8. 🔥 Las dos librerías vecinas: `jspdf-autotable` y `pdfmake`](#8--las-dos-librerías-vecinas-jspdf-autotable-y-pdfmake)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios (8)](#-ejercicios-8)

---

## 1. El mapa en una página

Un documento son cuatro cosas: una hoja, un lápiz con estado (fuente, tamaño, color), coordenadas, y una salida. Todo lo demás son variaciones.

```
new jsPDF('p', 'mm', 'a4')          ← la hoja: vertical, milimetros, A4 (210 x 297)

   x=0                                          x=210
 y=0 ┌───────────────────────────────────────────┐
     │  (20, 20)  ← doc.text('Titulo', 20, 20)   │   la y CRECE hacia ABAJO
     │                                           │   el origen es la esquina
     │  (20, 40)  ← doc.text('Valor: 105', 20,40)│   superior izquierda
     │                                           │
     │                                           │   el "lapiz" tiene estado:
     │                                           │   setFont / setFontSize /
     │                                           │   setTextColor afectan a lo
 y=297────────────────────────────────────────────┘   que se dibuje DESPUES
```

Y el ciclo completo, que es el mismo siempre:

```
new jsPDF(...)  →  registrar fuente  →  setFont / setFontSize  →  text() x N  →  save()
                   ▲                    ▲
                   │                    └── cambia el estado del lapiz de aca en adelante
                   └── ANTES del primer text(), o lo ya escrito queda con la fuente vieja
```

> 🧠 **La regla que evita la mitad de los bugs:** *todo lo que configura el lápiz afecta solo a lo que se dibuja después.* `setFont`, `setFontSize`, `setTextColor`, el registro de la fuente. No hay "aplicar al documento": hay un estado que va cambiando mientras dibujas. Cuando veas un PDF donde **una parte** salió bien y **otra** mal —una fuente distinta, un tamaño distinto, unos acentos rotos y otros no—, no busques dos bugs: busca **una llamada que quedó en el lugar equivocado del orden**.

Y la segunda regla, la que separa este apéndice de la Fase 9: **jsPDF dibuja lo que le das.** No lee del store, no sabe qué es fresco y qué es viejo, no valida nada. Si el informe imprime un dato equivocado, el problema está aguas arriba de la primera línea de este apéndice.

---

## 2. Armar el documento más allá de cinco líneas

La **Fase 9 §5.1** dibuja cinco líneas con coordenadas fijas y le alcanza. Esta sección es lo que te falta el día que el informe crece: texto que no cabe, una segunda página, una línea separadora, algo centrado.

### La hoja y sus medidas

```typescript
// Orientación, unidad y formato. Con 'mm' y 'a4' los números de las
// coordenadas son milímetros reales, que es lo más fácil de razonar: el ancho
// útil es 210 menos los margenes que decidas.
var doc = new (jsPDF as any)('p', 'mm', 'a4');

// Las medidas de la página, por si el formato cambia y no quieres números
// magicos regados por el servicio.
var pageWidth = doc.internal.pageSize.getWidth();    // 210 en A4 vertical
var pageHeight = doc.internal.pageSize.getHeight();  // 297
```

> 💡 Define los márgenes como constantes al inicio del servicio (`var MARGIN_X = 20;`) y calcula el ancho útil como `pageWidth - MARGIN_X * 2`. Es la diferencia entre mover un margen en una línea o buscar el número `20` en treinta llamadas.

### Texto que no cabe: `splitTextToSize`

Este es el problema número uno cuando el informe deja de ser cinco etiquetas. `doc.text()` **no corta el texto**: lo dibuja recto hasta salirse de la hoja, sin avisar y sin error.

```typescript
// Corta el texto en un arreglo de líneas que caben en el ancho dado, usando la
// fuente y el tamaño ACTUALES. Si cambias setFontSize después de esto, el
// calculo deja de valer: primero se fija el lapiz, después se corta.
var lines = doc.splitTextToSize(snapshot.comments, pageWidth - 40);

// text() acepta un arreglo y dibuja una línea por elemento, separandolas según
// el tamaño de fuente. Es la única forma de "parrafo" que hay.
doc.text(lines, 20, 100);
```

### Una segunda página

No hay salto automático. Si dibujas en `y = 320` sobre una A4, esa tinta cae fuera de la hoja y no la ve nadie. El control de la `y` es tuyo:

```typescript
var y = 100;

items.forEach(function (item: any) {
  // Antes de dibujar, se comprueba si queda espacio. 20 mm de margen inferior
  // es un valor razonable; el punto es que la comprobación exista.
  if (y > pageHeight - 20) {
    doc.addPage();
    y = 20;          // se reinicia arriba de la página nueva
  }
  doc.text(item.label + ': ' + item.value, 20, y);
  y = y + 8;         // el avance de línea también es tuyo
});
```

### Alinear, medir y separar

```typescript
// Alineación: el tercer objeto de text() acepta align. Con 'center' la x deja
// de ser el inicio del texto y pasa a ser su centro.
doc.text('INFORME DE RESULTADO', pageWidth / 2, 20, { align: 'center' });

// Medir un texto para decidir donde ponerlo. La formula clásica de la 1.x:
// unidades de la fuente * tamaño / factor de escala del documento.
var textWidth = doc.getStringUnitWidth('Total') * doc.internal.getFontSize() / doc.internal.scaleFactor;

// Una línea separadora. line() dibuja con el color de trazo, no con el de texto:
// son dos estados distintos del lapiz y se configuran por separado.
doc.setDrawColor(150);
doc.line(20, 90, pageWidth - 20, 90);

// Un rectangulo de fondo. 'F' rellena, 'S' solo contornea, 'FD' hace las dos.
doc.setFillColor(240);
doc.rect(20, 95, pageWidth - 40, 10, 'F');
```

> ⚠️ **`setTextColor` y `setDrawColor` son estados distintos y se olvidan por separado.** Un `setTextColor(200, 0, 0)` para marcar un valor crítico en rojo **no se revierte solo**: todo el texto que dibujes después sigue rojo hasta que lo cambies. El síntoma clásico es un informe donde, a partir del primer valor fuera de rango, la firma y la fecha también salen rojas. Vuelve al negro explícitamente en cuanto termines el fragmento de color.

---

## 3. Fuentes: de un `.ttf` a un `addFont`

La **Fase 9 §5.3** muestra el mínimo —registrar una Roboto y llamar a `setFont`— y remite acá el resto. Esto es el resto.

### Por qué hace falta: las 14 fuentes estándar

El formato PDF define catorce fuentes que todo lector debe conocer sin que el archivo las lleve adentro: Helvetica, Times, Courier, Symbol y ZapfDingbats con sus variantes. Son de 1993 y su repertorio de glifos apunta al alfabeto latino occidental básico. jsPDF usa **Helvetica** por defecto porque es gratis en tamaño: no embebe nada.

Embeber una fuente es lo contrario: metes el archivo `.ttf` dentro del PDF, el documento crece, y a cambio el lector dibuja exactamente los glifos que tú elegiste. Para acentos, esa es la única salida honesta (§4).

### Qué fuente y con qué licencia

Este proyecto usa **Roboto Regular y Roboto Bold**. Dos razones prácticas y ninguna estética: cubre el latín extendido completo —todos los acentos del español y del francés, más los que aparecerían si mañana entra el portugués— y su licencia **Apache 2.0** permite redistribuirla dentro del bundle sin trámite. Esa segunda razón importa más de lo que parece: embeber una fuente es **distribuirla**, y no todas las licencias tipográficas lo permiten. DejaVu Sans (licencia libre derivada de Bitstream Vera) es la alternativa habitual si necesitas un repertorio aún más ancho.

> ⚠️ Antes de embeber una fuente que no sea Roboto o DejaVu, lee su licencia. Las fuentes comerciales y varias de las que trae un sistema operativo **no se pueden redistribuir dentro de un archivo**, y un PDF que las embebe es exactamente eso. Es el tipo de problema que nadie detecta durante años y que aparece de golpe en una auditoría.

### De `.ttf` a base64

jsPDF 1.5.3 no lee archivos: lee cadenas base64 que tú le entregas. La conversión se hace una vez, fuera del build, y su resultado se versiona como código:

```javascript
// scripts/build-font.js
// Convierte un .ttf en un modulo TypeScript con la fuente en base64, listo para
// importar desde el código de la aplicación. Se corre a mano cuando cambia la
// fuente, NO en cada build: el resultado se versiona.
var fs = require('fs');

var FONTS = [
  { file: 'Roboto-Regular.ttf', constant: 'ROBOTO_REGULAR_BASE64' },
  { file: 'Roboto-Bold.ttf', constant: 'ROBOTO_BOLD_BASE64' }
];

var output = '// Generado por scripts/build-font.js. No editar a mano.\n\n';

FONTS.forEach(function (font) {
  // El .ttf se lee como binario y se codifica. base64 crece alrededor de un
  // tercio sobre el tamaño del archivo original: eso es lo que termina en el
  // bundle, no el peso del .ttf.
  var base64 = fs.readFileSync('fonts/' + font.file).toString('base64');
  output += 'export var ' + font.constant + " = '" + base64 + "';\n\n";
});

fs.writeFileSync('src/app/reports/report-fonts.data.ts', output);
console.log('fuentes escritas en report-fonts.data.ts');
```

> 💡 El repositorio de jsPDF trae un `fontconverter` en HTML que hace lo mismo desde el navegador: arrastras el `.ttf` y te devuelve el archivo listo. Sirve para una prueba rápida; para algo que se versiona, un script reproducible es mejor.

### El registro completo, con las dos variantes

```typescript
// src/app/reports/report-fonts.ts
import { ROBOTO_REGULAR_BASE64, ROBOTO_BOLD_BASE64 } from './report-fonts.data';

// Registra la familia Roboto completa -normal y bold- en la instancia del
// documento y la deja activa. Se llama UNA vez, justo después de crear el doc y
// ANTES de cualquier text(). En la 1.5.3 el VFS es por instancia: cada doc
// nuevo necesita su propio registro.
export function registerLatinFont(doc: any): void {
  // addFileToVFS mete el binario en el sistema de archivos virtual de jsPDF con
  // un nombre; addFont asocia ese archivo a una familia y un estilo. Los dos
  // pasos son necesarios y en este orden.
  doc.addFileToVFS('Roboto-Regular.ttf', ROBOTO_REGULAR_BASE64);
  doc.addFont('Roboto-Regular.ttf', 'Roboto', 'normal');

  // La variante bold se registra aparte. NO es un efecto de setFont('Roboto',
  // 'bold'): si este par de líneas falta, esa llamada no encuentra la variante
  // y jsPDF cae de vuelta a Helvetica, que rompe los acentos. Ver la trampa
  // justo debajo.
  doc.addFileToVFS('Roboto-Bold.ttf', ROBOTO_BOLD_BASE64);
  doc.addFont('Roboto-Bold.ttf', 'Roboto', 'bold');

  // Deja el lapiz en la variante normal. Quien quiera negrita pide
  // setFont('Roboto', 'bold') y después vuelve.
  doc.setFont('Roboto', 'normal');
}
```

Y su uso, que son dos líneas en el servicio:

```typescript
var doc = new (jsPDF as any)('p', 'mm', 'a4');
registerLatinFont(doc);          // antes de escribir NADA
```

> ⚠️ **La trampa de la variante que falta.** Registrar `normal` y pedir `bold` no da error: jsPDF no encuentra la combinación familia+estilo y **cae en silencio a Helvetica**. El resultado es un informe donde los títulos en negrita tienen los acentos rotos y el cuerpo normal está perfecto. Ese síntoma parcial se parece muchísimo al del incidente **15** —el registro que corre tarde, **Fase 9 §6**— y tiene causa distinta. La pregunta que los separa es una sola: *¿lo que salió mal está en negrita?* Si sí, es la variante; si no, es el orden.

**Detalles con intención.**

- **Un `setFont` intermedio revierte todo.** Cualquier `doc.setFont('helvetica')` que alguien meta en medio del servicio deja el lápiz en la fuente estándar, y todo lo que se dibuje después vuelve a romper acentos. Es el ejercicio 27 de la Fase 9 y es sorprendentemente frecuente cuando dos personas tocan el mismo servicio.
- **El registro es por instancia.** Si el servicio genera dos documentos, cada uno necesita su `registerLatinFont`. Es la razón por la que la función recibe el `doc` en vez de configurar algo global.
- **Registrar no es usar.** Puedes tener la fuente registrada y seguir dibujando en Helvetica si nadie llamó a `setFont`. Por eso `registerLatinFont` termina dejando el lápiz en Roboto: para que olvidarse sea imposible.

---

## 4. Acentos: qué pasa exactamente y cómo se diagnostica

> 🕵️ **El árbol de descarte aplicado a un PDF concreto** —acentos rotos sólo en el encabezado frente a rotos en todo el documento— está en [`forense-fase-09.md`](forense-fase-09.md) §Paso 5.

La **Fase 9 §4** da la intuición —"el francés cruza más seguido el borde del set básico"— y con eso alcanza para entender el incidente 15. Acá va la mecánica, que es un poco menos indulgente.

**Lo que ocurre de verdad.** Una cadena de JavaScript son caracteres Unicode. Las fuentes estándar del PDF no se direccionan por Unicode: se direccionan por una tabla de un byte por carácter. jsPDF 1.x, cuando no hay fuente embebida, escribe la cadena al documento **sin traducir** a esa tabla, así que todo lo que esté por encima del ASCII de siete bits queda a merced de cómo interprete el lector cada byte. Un `é` puede salir como dos símbolos, como uno equivocado o como nada.

De ahí se siguen tres consecuencias prácticas:

**No es "un problema del francés".** El español rompe igual: `Órdenes`, `Número`, `día` están todos por encima del ASCII. Lo que hace que el bug se reporte siempre en francés es la densidad —las etiquetas francesas del informe (`Résultat`, `Référence`, `Validé par`) llevan un diacrítico casi todas, mientras que en español hay pantallas enteras sin uno— y que el español tolera peor la queja: alguien ve `Ordenes` sin tilde y lo reporta como cosmética, no como bug de encoding. **Si un informe en español te sale limpio, es suerte del vocabulario, no que el problema no esté.**

**No se arregla "escapando" el texto.** Las soluciones que dan vueltas por internet —reemplazar acentos, pasar la cadena por `unescape(encodeURIComponent(...))`, normalizar a la forma descompuesta— cambian el síntoma en algunos lectores y lo empeoran en otros. **La única solución estable es embeber una fuente con esos glifos** (§3), que es lo que hace este proyecto.

**Y no lo detecta ningún test que compare cadenas.** El texto que le pasaste a `doc.text()` es correcto; lo que está mal es el dibujo. Solo se ve abriendo el PDF, y por eso la Prueba de fuego de la Fase 9 pide abrirlo con los ojos.

### El árbol de tres preguntas

Cuando llegue el informe con símbolos raros, en este orden:

| # | Pregunta | Si la respuesta es sí | Dónde |
|---|---|---|---|
| 1 | ¿Está **todo** el documento roto? | Falta el registro de la fuente, o `registerLatinFont` no se está llamando | §3 |
| 2 | ¿Está roto solo lo que se dibuja **primero**? | El registro corre después del primer `text()`: es el orden | §1 y **Fase 9 §6** |
| 3 | ¿Está roto solo lo que está en **negrita**? | La variante `bold` no se registró y cayó a Helvetica | §3 |

Y si ninguna de las tres da: busca un `setFont` intermedio metido en medio del servicio, que revierte el lápiz sin que nadie lo note.

---

## 5. El peso: dónde vive y cómo se saca del arranque

Dos cosas viajan al navegador por culpa del PDF: **la librería** y **la fuente en base64**. Las dos se cargan aunque el usuario nunca genere un informe, porque un `import` estático entra en el bundle inicial pase lo que pase.

Este apéndice **no te da cifras**: medirlas sobre el proyecto ya montado es el ejercicio 7, y la herramienta para hacerlo —`--stats-json`, `webpack-bundle-analyzer`, `source-map-explorer`— vive en **A04 §5**, que es su dueño. Lo que sí te da son las tres formas de que ese peso no esté en el arranque, con su costo.

**Opción A — El módulo de reportes por carga diferida**

Qué es: `loadChildren` sobre la ruta del informe, para que la librería y la fuente viajen en su propio chunk.
Cuándo conviene: casi siempre. Es la opción por defecto y la que pide el ejercicio 28 de la Fase 9.
El costo: la primera vez que alguien entra a la vista del informe hay una descarga extra. En una red interna no se nota.
Veredicto: es lo primero que harías si el budget salta.

**Opción B — `import()` dinámico solo de la librería**

Qué es: importar jsPDF dentro del método `generate()` con un `import()` que devuelve una promesa, en vez de en la cabecera del archivo.
Cuándo conviene: cuando el módulo de reportes **no** se puede aislar porque el botón vive en una pantalla que sí es de arranque.
El costo: `generate()` se vuelve asíncrono y el tipado se pone incómodo con TypeScript 3.5 y la forma de importar de la 1.5.3.
Veredicto: sirve, y es más quirúrgico que elegante.

**Opción C — La fuente por HTTP en vez de base64**

Qué es: dejar el `.ttf` en `assets/`, pedirlo con `HttpClient` al generar el primer PDF y convertirlo a base64 en el navegador.
Cuándo conviene: cuando la fuente pesa más que la librería y hay varias variantes.
El costo: una petición más, un estado de carga que manejar, y el archivo queda expuesto a lo mismo que los diccionarios de i18n —**es un asset sin hash en el nombre**, con su problema de caché al desplegar (**Fase 13 §5.9**).
Veredicto: solo si A y B no alcanzaron.

> 🧭 El orden de intento es A, después B, después C. Y antes de cualquiera de las tres: **mide**. Un budget que salta por 40 kB no se arregla con arquitectura, se arregla mirando qué más entró en ese chunk (**A04 §5.1**).

---

## 6. Descargar, abrir, imprimir

`doc.save('archivo.pdf')` cubre el caso del curso y esconde lo que hace: arma un blob, crea un enlace invisible, lo hace clic y lo descarta. Cuando eso no alcanza, la salida se pide en crudo.

```typescript
// La descarga directa. El nombre lleva el id para que dos informes no se pisen
// en la carpeta de descargas del usuario.
doc.save('report-' + snapshot.resultId + '.pdf');

// El documento como Blob, para subirlo, adjuntarlo o guardarlo en otro lado.
var blob = doc.output('blob');

// Una URL temporal del blob, para abrirlo en una pestaña nueva en vez de
// descargarlo. Ojo con el bloqueador de popups: ver la advertencia.
var url = doc.output('bloburl');
window.open(url, '_blank');

// El documento como data URI, útil para un <iframe> de previsualización.
// Cuidado: para documentos grandes esta cadena es enorme y algunos navegadores
// la truncan; el blob es más seguro.
var dataUri = doc.output('datauristring');
```

> ⚠️ **`window.open` fuera de un clic lo bloquea el navegador.** Si abres la pestaña dentro de un `subscribe` que llegó tres segundos después del clic, el navegador ya no considera que haya interacción del usuario y lo bloquea en silencio: no hay error, no pasa nada, y el ticket dice "el botón no hace nada". Si necesitas abrir en pestaña, arma el PDF de forma síncrona dentro del handler del clic — que es justamente lo que permite el snapshot de la Fase 9, con todos sus problemas.

> 💡 Para mandar el documento a la impresora, jsPDF trae `doc.autoPrint()`: se llama **antes** de la salida y marca el documento para que el lector abra el diálogo de impresión al abrirlo. Depende del visor del usuario, así que trátalo como una sugerencia y no como una garantía.

**El nombre del archivo importa más de lo que parece.** Dos informes que se llaman igual se guardan como `report.pdf` y `report (1).pdf` en la carpeta de descargas, y a la semana nadie sabe cuál es cuál. El patrón del proyecto —`report-<resultId>.pdf`— es el mínimo; si algún día hay reimpresiones, agregarle la fecha de generación evita una confusión que llega como ticket de negocio, no de software.

---

## 7. Lo que jsPDF 1.5.3 no hace

Sección de expectativas. Todo lo de acá se intenta al menos una vez por proyecto.

**Convertir tu HTML en un PDF decente.** `doc.fromHTML(...)` existe en la 1.x y entiende un subconjunto muy pequeño de HTML y casi nada de CSS. Con una pantalla de Angular —con Material, con Bootstrap, con flexbox— el resultado no se parece a lo que ves. No es un bug: nunca fue un motor de maquetado.

**Capturar la pantalla tal cual.** La salida habitual es `html2canvas`: se rasteriza el DOM a una imagen y se pega la imagen en el PDF. Funciona visualmente y tiene tres costos que hay que declarar antes de proponerlo: el texto deja de ser texto —no se puede buscar, copiar ni leer con un lector de pantalla—, el archivo pesa muchísimo más, y los estilos que el navegador no puede rasterizar salen distintos. Para un informe clínico que alguien va a archivar y auditar, convertir el texto en un dibujo es un mal negocio.

**Tablas.** No hay `doc.table()`. Una tabla se dibuja con `line`, `rect` y `text` calculando cada columna a mano, o se delega en `jspdf-autotable` (§8).

**Alfabetos no latinos.** Roboto no trae glifos chinos, japoneses, coreanos, árabes ni hebreos. Embeber una fuente que sí los traiga es posible y pesa varios megabytes; y en árabe y hebreo, además, hay que resolver la dirección del texto, que jsPDF 1.5.3 no maneja. No está en el alcance del sistema, igual que RTL no lo está en i18n (**A07**).

**PDF accesible o PDF/A.** Un PDF "etiquetado" —con estructura semántica para lectores de pantalla— y los perfiles de archivado PDF/A son otra liga y esta librería no los produce. Si aparece un requisito de accesibilidad o de archivado normativo sobre los informes, la conversación es "esto se genera en servidor", no "buscamos una opción de jsPDF".

**Firmar el documento.** Está **fuera del alcance del curso** y conviene saber por qué, porque es la petición que más veces llega mal formulada. Una firma digital real necesita una clave privada y un certificado de una autoridad; poner una clave privada en el navegador es entregársela a cualquiera que abra las DevTools. Se firma en un servidor, siempre. Lo que hace este proyecto —estampar quién y cuándo dentro del texto del PDF— es **evidencia de custodia, no firma**: cualquiera con un editor de PDF puede cambiarla, y nada en el archivo lo delata. Si alguien pide "que el informe esté firmado", esa distinción es la primera pregunta que hay que hacer.

---

## 8. 🔥 Las dos librerías vecinas: `jspdf-autotable` y `pdfmake`

Ninguna está instalada. Están acá porque las dos aparecen en cuanto el informe crece, y conviene saber qué resuelven antes de proponerlas en una reunión.

### `jspdf-autotable` — tablas sin dibujar líneas

Es un plugin **de** jsPDF, no un reemplazo: se importa por su efecto secundario y agrega un método al documento. La línea compatible con jsPDF 1.5.3 es la **3.5.x**.

```typescript
import * as jsPDF from 'jspdf';
import 'jspdf-autotable';        // se importa por efecto secundario: agrega doc.autoTable

// ...

// head y body son arreglos de filas; cada fila es un arreglo de celdas. El
// plugin calcula anchos, dibuja bordes, repite el encabezado si la tabla parte
// en dos páginas y devuelve donde termino.
(doc as any).autoTable({
  head: [['Analyte', 'Value', 'Unit', 'Verdict']],
  body: rows,
  startY: 90,
  styles: { font: 'Roboto' }      // la fuente registrada en §3, o los acentos se rompen
});

// Donde quedó el cursor, para seguir dibujando debajo sin adivinar.
var nextY = (doc as any).lastAutoTable.finalY + 10;
```

Lo que gana: el salto de página de una tabla larga, que a mano es tedioso y se hace mal. **La trampa:** el plugin usa Helvetica por defecto, así que si no le pasas `styles.font` con tu fuente registrada, **los acentos vuelven a romperse dentro de la tabla y solo dentro de la tabla**. Es el mismo bug de §4 con otro disfraz.

### `pdfmake` — el otro modelo

En vez de un lápiz, describes el documento como una estructura de datos y la librería lo maqueta. La línea contemporánea de este stack es la **0.1.x**; la 0.2 (2022 en adelante) cambió cómo se cargan las fuentes y no es la de la época.

Lo que gana: trae Roboto embebida en su archivo de fuentes, así que **los acentos salen bien sin registrar nada** y todo el §3 se evapora; y como no hay coordenadas, el bug de "acentos parciales por orden de llamadas" no puede existir.

Lo que cuesta: es otra librería entera en el bundle y reescribir el servicio.

> 🧭 **Y la lección que hay que tener clara antes de proponer la migración:** cambiar de librería arregla los acentos y **no toca el dato viejo**. El `reportSnapshot` congelado en `ngOnInit` sigue igual de viejo con `pdfmake` que con jsPDF, porque el stale no vive en la capa de dibujo sino en la capa de componente. La migración completa, con pistas y solución de referencia, es el ejercicio 🔥 de la **Fase 9**; el punto pedagógico está ahí y no se repite acá.

---

## 🧭 Cuándo usar qué

Primero la decisión de herramienta, que es la conversación de reunión:

| Situación | Qué usas | Por qué |
|---|---|---|
| Un informe de campos fijos, pocas líneas, sin backend | jsPDF a mano (§1, §2) | Es lo que hay y es suficiente. Es este proyecto |
| El informe crece a una tabla con salto de página | `jspdf-autotable` (§8) | El salto de página a mano se hace mal. Acuérdate de `styles.font` |
| Documentos con maquetado de verdad, muchos idiomas | `pdfmake` (§8) | Fuentes con acentos incluidas y layout automático |
| El PDF tiene que ser accesible, archivable o firmado | Generarlo en servidor (§7) | El navegador no puede firmar ni etiquetar |
| "Que salga igual que la pantalla" | CSS de impresión, no un PDF | `@media print` respeta el texto; `html2canvas` lo vuelve dibujo |
| Un PDF que tiene que reflejar el dato de **ahora** | Ninguna librería lo arregla | Es la Fase 9 §5.2, no este apéndice |

Y la tabla que de verdad se consulta: **abro el PDF y algo está mal**.

| Síntoma | Causa más probable | Dónde |
|---|---|---|
| Todos los acentos rotos | La fuente no se registró, o no se llamó a `registerLatinFont` | §3 |
| Rotos solo al principio del documento | El registro corre después del primer `text()` | §1, §4 |
| Rotos solo en negrita | La variante `bold` no se registró y cayó a Helvetica | §3 |
| Rotos solo dentro de una tabla | Falta `styles: { font: 'Roboto' }` en `autoTable` | §8 |
| Rotos a partir de cierta línea | Un `setFont` intermedio revirtió el lápiz | §3 |
| El texto se sale de la hoja | `text()` no corta; falta `splitTextToSize` | §2 |
| Falta contenido y el PDF tiene una sola página | Se dibujó más allá de `pageHeight` sin `addPage` | §2 |
| Todo rojo a partir de un valor crítico | `setTextColor` no se revirtió | §2 |
| El botón "no hace nada" al abrir en pestaña | El bloqueador de popups: `window.open` fuera del clic | §6 |
| El PDF pesa muchísimo | Se rasterizó con `html2canvas`, o se embebieron fuentes de más | §5, §7 |
| El build empezó a fallar por budget | Mide antes de tocar nada | **A04 §4 y §5**, después §5 |
| El PDF dice un valor y la pantalla otro | La foto vieja del componente | **Fase 9 §5.2** |

---

## ⚠️ Advertencias

**La documentación de jsPDF que vas a encontrar es la de la 2.x, y la diferencia empieza en el `import`.** Es la advertencia central de este apéndice porque afecta a cada búsqueda. En tu **1.5.3** se importa con `import * as jsPDF from 'jspdf'` y se instancia con `new (jsPDF as any)()`; en la 2.x es `import { jsPDF } from 'jspdf'`. Si copias un ejemplo y no compila, no estás loco: estás leyendo otra versión. Todo lo que encuentres sobre jsPDF datado después de 2021 asume la 2.x.

**Un PDF no avisa cuando sale mal.** No hay excepción, no hay consola, no hay test de cadenas que lo detecte: el texto que enviaste era correcto y lo que falló fue el dibujo. La única verificación real es **abrir el archivo y mirarlo**, en los tres idiomas, y por eso la Prueba de fuego de la Fase 9 está escrita así.

**Todo lo que configura el lápiz afecta solo a lo que viene después.** Fuente, tamaño, color de texto, color de trazo. La mayoría de los "dos bugs distintos" de este apéndice son una sola llamada en el lugar equivocado del orden.

**Registrar `normal` no registra `bold`.** Y pedir una variante no registrada no da error: cae a Helvetica en silencio, y el informe sale con los títulos rotos y el cuerpo sano.

**Embeber una fuente es distribuirla.** Roboto (Apache 2.0) y DejaVu se pueden; muchas otras no. Antes de cambiar de tipografía por gusto, lee la licencia.

**Lo que el informe llama "firma" no es una firma.** Es texto dibujado que dice quién y cuándo, alterable por cualquiera con un editor de PDF. Vale como evidencia de custodia dentro del sistema y no vale como garantía criptográfica de nada. Cuando alguien pida "informes firmados", esa es la distinción que hay que aclarar antes de estimar.

---

## 📚 Referencias

- https://github.com/MrRio/jsPDF/tree/v1.5.3 — **la documentación de tu versión exacta**, en su tag. La API de `text`, `setFont`, `addFileToVFS`, `addFont`, `output` y `save` de esta línea. ⚠️ La rama por defecto del repositorio documenta la 2.x.
- https://github.com/MrRio/jsPDF/tree/v1.5.3/fontconverter — el conversor de `.ttf` a base64 que trae la propia librería, alternativa manual al script de §3.
- https://github.com/MrRio/jsPDF — el repositorio actual. ⚠️ Útil solo para ver hacia dónde fue la librería; sus ejemplos no compilan en la 1.5.3.
- https://fonts.google.com/specimen/Roboto — Roboto y su licencia Apache 2.0, que es la que permite embeberla en el PDF (§3).
- https://www.apache.org/licenses/LICENSE-2.0 — el texto de la licencia, por si alguien de legal pregunta qué permite exactamente.
- https://dejavu-fonts.github.io — DejaVu, la alternativa de repertorio más amplio cuando Roboto no alcanza.
- https://github.com/simonbengtsson/jsPDF-AutoTable — `jspdf-autotable` (§8). ⚠️ Su README documenta la línea actual; para jsPDF 1.5.3 hay que mirar la **3.5.x** y recordar que `styles.font` es obligatorio si usas fuente embebida.
- https://pdfmake.github.io/docs/ — la documentación de `pdfmake` (§8). ⚠️ Cubre la 0.2; la línea de la época es la **0.1.x**, con otra forma de cargar las fuentes.
- https://developer.mozilla.org/es/docs/Web/CSS/@media/print — el CSS de impresión, que es la alternativa correcta cuando lo que se pide es "que salga igual que la pantalla" (§🧭).
- https://developer.mozilla.org/es/docs/Web/API/URL/createObjectURL — lo que hay debajo de `output('bloburl')` y por qué esa URL es temporal (§6).
- https://www.adobe.com/content/dam/acom/en/devnet/pdf/pdfs/PDF32000_2008.pdf — la especificación de PDF 1.7, capítulo 9, donde están las catorce fuentes estándar y el modelo de fuentes que explica todo el §4. No se lee entera: se consulta el capítulo cuando alguien discute qué garantiza un PDF y qué no.

> ⚠️ Los enlaces, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Con jsPDF el riesgo tiene una forma concreta: **la mayoría de las respuestas de foros sobre acentos son de la 2.x o proponen escapar la cadena**, que es el remedio que no funciona (§4). Cuando encuentres una solución, lo primero es fijarte en cómo hace el `import`: eso te dice la versión antes que cualquier otra cosa.

**Orden de lectura sugerido:** si llegaste por acentos rotos, ve directo al árbol de tres preguntas de §4 y de ahí a §3. Si llegaste porque el informe creció, §2 primero y §8 después. Si vas a proponer cambiar de librería, léete §8 completo y el 🔥 de la **Fase 9** antes de la reunión, no después.

---

## 🧪 Ejercicios (8)

Cortos y de consulta. Sobre el informe de la Fase 9, con el mock levantado y un resultado validado a mano.

1. Genera un informe en francés con `registerLatinFont(doc)` activo y otro con la línea comentada. Abre los dos y anota, glifo por glifo, qué cambia en `Résultat` y en `Validé par`. Después haz lo mismo en español con una etiqueta que lleve tilde y anota si el español también se rompe o si te salvó el vocabulario (§4).
2. Registra solo la variante `normal` en `registerLatinFont`, dibuja el título con `setFont('Roboto', 'bold')` y genera en francés. Anota el síntoma exacto y ubícalo en la tabla del §4. Después registra la variante bold y confirma que desaparece.
3. **Rompe a propósito.** Mete un `doc.setFont('helvetica')` entre dos `doc.text` del servicio y genera. Anota a partir de qué línea se rompen los acentos y explica en una frase por qué el documento tiene dos mitades distintas. Revierte.
4. Agrega al informe un campo de comentarios largo —tres o cuatro frases— con un `doc.text` normal, y comprueba que se sale de la hoja. Después arréglalo con `splitTextToSize` usando el ancho útil calculado desde `pageWidth`, y confirma que ahora corta donde debe (§2).
5. Haz que el informe imprima veinte líneas de detalle con un bucle, sin control de página. Anota cuántas se ven y dónde se pierde el resto. Después agrega la comprobación de `pageHeight` con `addPage()` y confirma que aparece la segunda página (§2).
6. Cambia `doc.save(...)` por `doc.output('bloburl')` más `window.open`, y prueba dos variantes: abriendo dentro del handler del clic, y abriendo dentro de un `setTimeout` de dos segundos. Anota cuál bloquea el navegador y qué mensaje deja (o no deja) en consola (§6).
7. **Cuando el proyecto esté montado:** mide qué aportan jsPDF y la fuente al bundle inicial. Compila con `npx ng build --prod --stats-json`, analiza con la herramienta de **A04 §5.1**, y anota los dos números en tu cuaderno. Después mueve el módulo de reportes a carga diferida (ejercicio 28 de la Fase 9), vuelve a medir y anota la diferencia. Esas cifras son las que este apéndice deliberadamente no inventa.
8. **Diagnóstico.** Te llega un informe donde el encabezado y el cuerpo están perfectos, pero los acentos de la tabla de resultados salen rotos. Sin ver el código, escribe las tres preguntas que harías en orden y di cuál fila de la tabla de síntomas del §🧭 corresponde a cada una. Después confírmalo montando la tabla con `jspdf-autotable` sin `styles.font` (§8).


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f09: …`), para que su `git log --oneline --grep '^f09'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a08/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **Las cifras del bundle.** El peso real de jsPDF y de la fuente en base64 no se declara en ninguna parte del curso, a propósito: se mide sobre el proyecto montado (**ejercicio 7** acá, **ejercicio 28** de la Fase 9) con las herramientas de **A04 §5**. Cuando alguien las mida, valen para fijar un budget realista en el `angular.json` → decisión de proyecto.
- **Versiones de las librerías vecinas.** `jspdf-autotable` **3.5.x** y `pdfmake` **0.1.x** son las líneas de la época y están declaradas como tales, no como pins verificados: ninguna de las dos está instalada. Si alguna se adopta, la versión exacta pasa a `propuesta-fases-y-alcance.md` §8 junto al resto del stack.
- **Un informe con tabla de verdad.** El informe de la Fase 9 imprime un solo resultado; en cuanto imprima todos los de una orden, la tabla deja de ser opcional y `jspdf-autotable` entra en el stack. Es material de un ejercicio 🔥 de la **Fase 9** o de una ampliación del informe, no de este apéndice.
- **La fuente como asset sin hash.** La opción C del §5 —cargar el `.ttf` por HTTP— hereda exactamente el problema de caché de los diccionarios de i18n resuelto en la **Fase 13 §5.9**. Si algún día se adopta, ese `location` de nginx necesita una regla más.
- 🪦 **Cerrado al escribir este apéndice.** El pendiente **[B]** de la Fase 9 —*"la carga diferida del módulo de reportes y el peso de la fuente, material central de A08"*— queda cubierto en §5, con la salvedad de que la medición es un ejercicio y no un dato del texto. La Fase 9 §5.3 registra solo la variante `normal`: el registro completo con `bold`, y la trampa que produce omitirla, viven acá en §3.
