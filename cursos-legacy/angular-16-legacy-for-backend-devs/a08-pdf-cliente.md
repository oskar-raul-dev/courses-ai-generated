# 📎 Apéndice A08 — PDF en cliente con jsPDF 2

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: [Fase 10](10-certificados-vigencia.md) · Versión cubierta: `jspdf` 2.5.1 + `jspdf-autotable` 3.8.x

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve el problema que empieza justo donde termina el ejemplo oficial: **armar el certificado en PDF desde el navegador más allá de las cinco líneas del README**, con acentos, con una tabla que pagina, con encabezado repetido, y sin meter 300 KB en el bundle inicial de todo el mundo.

Y hay una cosa que este apéndice repite aunque la Fase 10 ya la enseñe, porque es el error que todo el mundo comete **dos** veces: **el documento se arma desde la fuente del dato, nunca desde lo que hay pintado en la vista.**

**Qué queda fuera:** la firma digital real (jsPDF no la hace y no hay forma honesta de simularla), PDF/A y cualquier requisito de archivo normativo, y la generación en servidor — que se nombra en la §8 como el límite y no se implementa, porque CertCore no tiene backend propio. `pdfmake` y `html2canvas` se comparan en una tabla y **no se instalan**: el stack está cerrado.

---

## Índice

- [1. Coordenadas: por qué todo sale corrido la primera vez](#1-coordenadas-por-qué-todo-sale-corrido-la-primera-vez)
- [2. Acentos y fuentes: la mecánica exacta](#2-acentos-y-fuentes-la-mecánica-exacta)
- [3. La tabla de hallazgos con `jspdf-autotable`](#3-la-tabla-de-hallazgos-con-jspdf-autotable)
- [4. Encabezado y pie en todas las páginas](#4-encabezado-y-pie-en-todas-las-páginas)
- [5. Imágenes, y lo que pesan](#5-imágenes-y-lo-que-pesan)
- [6. Los 300 KB, y el `import()` que los difiere](#6-los-300-kb-y-el-import-que-los-difiere)
- [7. ⚠️ El documento se arma desde el dato](#7-️-el-documento-se-arma-desde-el-dato)
- [8. Los límites: cuándo esto se hace en el servidor](#8-los-límites-cuándo-esto-se-hace-en-el-servidor)
- [9. El PDF descargado no se revoca](#9-el-pdf-descargado-no-se-revoca)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 1. Coordenadas: por qué todo sale corrido la primera vez

```ts
const document = new jsPDF();
// Equivale a new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' }),
// que es exactamente lo que queremos: A4 vertical, medidas en milímetros.
```

Tres cosas que hay que interiorizar de una vez, y con eso se acaba el 90% del desconcierto:

**El origen está arriba a la izquierda y la `y` crece hacia abajo.** Al revés que en las matemáticas del colegio, igual que en el DOM.

**La `y` de `text()` es la línea base, no el borde superior.** `document.text('Certificado', 20, 20)` **no** deja el texto a 20 mm del borde: deja *la base de las letras* a 20 mm, así que la primera línea empieza más arriba de lo que crees, y por eso el primer intento siempre parece desplazado hacia arriba.

**No hay flujo.** Nada empuja a nada. Si escribes dos textos en la misma `y`, se superponen y el PDF sale perfecto y con las letras encima unas de otras. Todo el trabajo de "una línea debajo de la otra" lo llevas tú, y ésa es la diferencia de fondo con generar HTML.

La consecuencia práctica es que un documento de más de tres líneas se escribe **con un cursor**, no con números sueltos:

```ts
// Un cursor y una función que avanza. Escribir `document.text(x, 20)`,
// `document.text(x, 27)`, `document.text(x, 34)` a mano es cómo se llega a un
// documento imposible de modificar: cambiar una línea desplaza catorce números.
const MARGIN_X = 20;
const LINE_HEIGHT = 7;
let cursorY = 25;

const writeLine = (text: string): void => {
  document.text(text, MARGIN_X, cursorY);
  cursorY += LINE_HEIGHT;
};

writeLine(`Certificado ${source.certificate.id}`);
writeLine(`Cliente: ${source.client.legalName}`);
writeLine(`Activo: ${source.asset.description}`);
```

**Las tres medidas que vas a necesitar sí o sí:**

```ts
const pageWidth = document.internal.pageSize.getWidth();    // 210 en A4 vertical
const pageHeight = document.internal.pageSize.getHeight();  // 297
const textWidth = document.getTextWidth('Certificado');     // en la unidad del doc
```

Con `getTextWidth` se centra o se alinea a la derecha sin adivinar, y con `splitTextToSize` se parte un texto largo en líneas que caben:

```ts
// La descripción de un hallazgo puede tener 300 caracteres. Sin esto, se sale
// del papel: jsPDF no recorta ni avisa, simplemente escribe fuera de la página.
const lines = document.splitTextToSize(finding.description, pageWidth - MARGIN_X * 2);
document.text(lines, MARGIN_X, cursorY);
cursorY += lines.length * LINE_HEIGHT;
```

> ⚠️ **jsPDF nunca se queja.** Escribir fuera de la página, superponer dos textos, pasarse del borde inferior: todo eso produce un PDF válido con el contenido mal puesto. **La única verificación posible es abrir el archivo y mirarlo.** No hay nada en consola, no hay nada en Network. Es un cambio de hábito real para quien viene de un stack donde los errores se ven.

---

## 2. Acentos y fuentes: la mecánica exacta

Éste es el tema que la Fase 10 deja explícitamente aquí, y conviene contarlo bien porque la creencia popular —"jsPDF no soporta acentos"— es falsa y hace que la gente embeba fuentes que no necesita.

**Cómo funciona.** jsPDF trae las catorce fuentes estándar del formato PDF (Helvetica, Times, Courier y sus variantes) y **no las embebe**: las referencia, y las pinta el lector de PDF. Esas fuentes usan una codificación de un solo byte —de la familia de `cp1252`/WinAnsi—, y **el español entero cabe ahí**: `á é í ó ú ü ñ Ñ ¿ ¡ °` están todos. Por eso el certificado de CertCore sale con sus tildes puestas sin hacer nada especial.

**Lo que sí se rompe**, y es lo que la gente confunde con "los acentos no funcionan":

- **Caracteres fuera de esa codificación de un byte.** Flechas (`→`), símbolos de verificación (`✓`, `✗`), emoji, y cualquier alfabeto no latino. En un certificado eso aparece el día que alguien decide que la columna de estado quede más bonita con un `✓`.
- **Texto que ya llegó mal decodificado.** Si el dato viene con *mojibake* —`MarÃ­n` en vez de `Marín`— el PDF reproduce fielmente lo que le diste. El fallo está tres capas más atrás, y la pista es que en la pantalla también se ve mal si miras con atención.
- **Una fuente de marca que no es una de las catorce**, usada sin embeber. Ahí el lector sustituye por otra y el resultado varía según quién abra el archivo.

**Cuándo hay que embeber, y cómo.** Sólo en los dos últimos casos. La mecánica son tres pasos y un archivo grande:

```ts
// 1. La fuente convertida a base64. Se genera una vez con el conversor oficial
//    de jsPDF y queda como un .js que exporta una cadena enorme.
import { robotoRegularBase64 } from './roboto-regular.font';

// 2. Se mete en el sistema de archivos virtual de jsPDF y se registra.
document.addFileToVFS('Roboto-Regular.ttf', robotoRegularBase64);
document.addFont('Roboto-Regular.ttf', 'Roboto', 'normal');

// 3. Se activa. A partir de aquí, todo el texto usa esa fuente.
document.setFont('Roboto', 'normal');
```

> ⚠️ **Una fuente embebida no es gratis: es un archivo de cientos de kilobytes que se suma al PDF y, si lo importas arriba, también al bundle.** Y hay que embeber **una variante por estilo**: la negrita es otro archivo y otro `addFont(..., 'bold')`. Antes de embeber, la pregunta correcta es *¿qué carácter concreto se está rompiendo?* — y bastante a menudo la respuesta es un `✓` que se puede escribir como "Sí".

**Cómo se verifica.** Mirando el PDF, y sólo así. Un caracter roto no produce nada en consola. Los dos textos que hay que meter siempre en el certificado de prueba son un nombre con tilde y una eñe: `Edificio Aurora S.A.S. — inspección de ascensores, señalización`.

---

## 3. La tabla de hallazgos con `jspdf-autotable`

Dibujar una tabla a mano con `text()` y `line()` es posible y es una pérdida de tiempo: `jspdf-autotable` mide las columnas, parte el texto, salta de página y repite la cabecera.

```ts
// Se importa por separado y se pasa como parámetro a la función pura que arma
// el documento, para que ese archivo no arrastre la librería. Ver la Fase 10.
const autoTable = (await import('jspdf-autotable')).default;

autoTable(document, {
  startY: cursorY + 5,
  head: [['Ítem', 'Severidad', 'Estado', 'Nota']],
  body: findings.map((finding) => [
    finding.itemTitle,
    severityLabel(finding.severity),
    finding.resolved ? 'Resuelto' : 'Pendiente',
    finding.note ?? '',
  ]),
  styles: { fontSize: 9, cellPadding: 2 },
  headStyles: { fillColor: [63, 81, 181] },   // el índigo del tema, en RGB
  // Las anchuras se fijan donde importa y se dejan libres donde no: sin esto,
  // una nota larga estruja la columna de severidad hasta hacerla ilegible.
  columnStyles: {
    0: { cellWidth: 55 },
    1: { cellWidth: 25 },
    2: { cellWidth: 25 },
    3: { cellWidth: 'auto' },
  },
  margin: { left: 20, right: 20 },
});

// Dónde terminó la tabla, para seguir escribiendo debajo. Es la propiedad que
// más se busca del plugin y la que peor se encuentra en su documentación.
cursorY = (document as unknown as { lastAutoTable: { finalY: number } }).lastAutoTable.finalY + 10;
```

**Detalles con intención**

- **`head` es un array de filas, no un array de columnas.** `head: [['A', 'B']]` es una fila de dos columnas; `head: ['A', 'B']` es otra cosa y produce una tabla desconcertante sin dar error.
- **Todo el contenido de `body` tiene que ser texto.** Un `null` o un `undefined` en una celda se pinta como vacío o como la palabra literal según la versión; convertirlos explícitamente (`finding.note ?? ''`) es lo que hace que el resultado sea el mismo siempre.
- **El acceso a `lastAutoTable`** necesita un estrechamiento porque el plugin extiende el prototipo de `jsPDF` sin que los tipos del paquete principal lo sepan. Con `strict` puesto, `as unknown as {...}` con la forma mínima es lo honesto: `any` no.

---

## 4. Encabezado y pie en todas las páginas

`autoTable` expone ganchos que corren una vez por página, y el de dibujado es donde va todo lo que se repite.

```ts
autoTable(document, {
  // …head, body, styles…
  margin: { top: 35, left: 20, right: 20, bottom: 20 },   // hueco para el encabezado
  didDrawPage: () => {
    // Encabezado: corre en cada página que la tabla genere, incluida la primera.
    document.setFontSize(10);
    document.text(`Certificado ${source.certificate.id}`, 20, 15);
    document.text(`Emitido: ${source.certificate.issuedAt}`, 20, 21);
  },
});
```

**El pie con "página X de Y" es otro problema**, y la razón es estructural: mientras dibujas la página 1 no sabes cuántas habrá. Se resuelve en dos pasadas, al final, y es la receta que vas a copiar cada vez:

```ts
// Después de todo el contenido, cuando el total ya se conoce.
const totalPages = document.getNumberOfPages();
const pageHeight = document.internal.pageSize.getHeight();

for (let page = 1; page <= totalPages; page += 1) {
  document.setPage(page);
  document.setFontSize(8);
  document.text(`Página ${page} de ${totalPages}`, 20, pageHeight - 10);
}
```

> 💡 **El pie es el sitio del rastro.** Un certificado que sale de la empresa gana mucho con una línea que diga de qué momento son sus datos: `Generado el 2026-03-14 09:41 (-05:00)`. No es adorno — es lo que permite, dentro de dos años, saber si el PDF que alguien archivó reflejaba el estado de entonces. La zona horaria explícita es la de la **Fase 10**, y por la misma razón.

---

## 5. Imágenes, y lo que pesan

```ts
// La imagen va como data URL o como HTMLImageElement ya cargado. Las medidas
// son las del PDF (mm), no píxeles: aquí el logo mide 40 mm de ancho.
document.addImage(logoDataUrl, 'PNG', 20, 10, 40, 12);
```

Tres cosas que deciden el peso del archivo, y en un certificado con logo importan más de lo que parece:

**El formato.** `PNG` conserva transparencia y comprime sin pérdida — bien para un logo, muy mal para una fotografía. `JPEG` es lo contrario. Una evidencia fotográfica de una inspección metida como PNG multiplica el tamaño del PDF por varias veces sin ganar nada visible.

**La resolución real, no la del PDF.** Pasar una imagen de 4000 px de ancho y dibujarla a 40 mm **no la reduce**: el archivo carga los 4000 px enteros. Si el PDF va a llevar fotos de evidencia, hay que reescalarlas antes —con un `canvas`— y ese redimensionado es trabajo del cliente, no de jsPDF.

**El data URL en base64 ocupa un tercio más que el binario.** Es el precio de meterlo en una cadena, y es inevitable con esta API.

> ⚠️ **Un certificado con diez fotos de evidencia a resolución de cámara es un PDF de decenas de megabytes que nadie va a poder adjuntar a un correo.** Si el requisito aparece, la conversación no es sobre jsPDF: es sobre si esas evidencias van en el documento o van enlazadas — y ésa es la primera pregunta de la §8.

---

## 6. Los 300 KB, y el `import()` que los difiere

`jspdf` con `jspdf-autotable` es, con diferencia, la dependencia más pesada que este curso instala: el orden de magnitud que mide la Fase 10 son **unos 300 KB** añadidos al bundle.

Importarla arriba —en el servicio, en el módulo, o en cualquier archivo que se cargue de forma *eager*— la mete en `main.js`, y entonces **la descarga todo el mundo**: el inspector que sólo abre el formulario, el supervisor que sólo mira la lista, y quien entra a `/login` y se equivoca de contraseña.

```ts
// ✅ Dentro de un método privado, y sólo aquí. El bundler la deja en un chunk
//    propio que no se pide hasta que alguien pulsa "Descargar PDF".
private async render(source: CertificateDocumentSource): Promise<void> {
  const { jsPDF } = await import('jspdf');
  const autoTable = (await import('jspdf-autotable')).default;

  const document = buildCertificateDocument(new jsPDF(), source, autoTable);
  document.save(`${source.certificate.id}.pdf`);
}
```

```ts
// ✅ En el archivo puro que arma el documento, sólo el TIPO. `import type`
//    desaparece en la compilación: no arrastra ni un byte.
import type { jsPDF } from 'jspdf';
```

**Cómo se comprueba, que es lo que de verdad hay que saber hacer:**

```bash
ng build --named-chunks --stats-json
grep -o '"name":"[^"]*jspdf[^"]*"' dist/certcore/stats.json | sort -u
```

Si `jspdf` aparece dentro de `main`, algún archivo lo está importando arriba, y el culpable casi siempre es un `import { jsPDF } from 'jspdf'` en la cabecera de un servicio. El síntoma en producción es que el bundle inicial engorda 300 KB **para todos los usuarios**, incluidos los que nunca descargan un certificado.

> 💡 **La primera descarga tarda un poco más, y está bien.** Diferir significa que el chunk se pide cuando el usuario pulsa el botón. En una red lenta eso son unas décimas visibles; a cambio, todos los arranques de la aplicación son 300 KB más ligeros. Si quieres las dos cosas, el chunk se puede precargar cuando el usuario entra al detalle del certificado, que es un buen momento porque ahí ya se sabe que va a descargar.

---

## 7. ⚠️ El documento se arma desde el dato

> 🧭 **Regla del proyecto: lo que hay en la pantalla es una foto de hace un rato. Está bien para mirar y está mal para imprimir. Cualquier artefacto que sobreviva a la sesión —un PDF, un correo, un export— se arma pidiendo el dato otra vez.**

Ésta es la 💸 que la **Fase 10** declara en su §5.7 y paga en su §5.8, tras el **incidente 14**, y se repite aquí porque es el error que todo el mundo comete dos veces: una al escribirlo por primera vez, y otra seis meses después, cuando hay que añadir un campo al PDF y lo más rápido es sacarlo del objeto que la pantalla ya tiene.

El fallo no se parece a un fallo. El usuario abre el detalle de un certificado, se queda en esa pestaña, otra persona resuelve un hallazgo desde otro equipo, y él pulsa "Descargar PDF" veinte minutos después. **El PDF sale perfecto**, con acentos, con la tabla alineada, y afirma que hay un hallazgo mayor sin resolver. No hay error en consola, no hay nada rojo en Network, y el documento ya está camino de un correo.

Lo que lo hace peligroso no es que el dato esté viejo: es que **el PDF es el único artefacto del sistema que sobrevive al sistema**. Una pantalla desactualizada se arregla con F5. Un PDF desactualizado se archiva, se imprime y se adjunta a la respuesta de un requerimiento normativo.

**Cómo se escribe la versión correcta**, en dos decisiones:

**Una interfaz explícita con todo lo que el documento necesita.** Que sea un tipo con nombre y no "lo que tenga el componente" es la mitad del arreglo: se ve de un vistazo que hacen falta seis cosas, y las seis tienen que venir de la fuente.

```ts
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;   // la versión CONGELADA de la inspección
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}
```

**El armado es una función pura y vive en `core/pdf/`, no en la feature.** La feature sabe pedir datos y disparar una descarga; el documento es dominio. Es la misma frontera que la Fase 9 trazó entre `core/domain/` y las pantallas, y por la misma razón: lo que se puede probar sin navegador se prueba sin navegador.

**Prueba de fuego.** Abre el detalle de un certificado. Sin cerrar esa pestaña, abre otra y resuelve uno de sus hallazgos. Vuelve a la primera —que sigue mostrando el estado viejo— y descarga el PDF. **La tabla del PDF tiene que traer el hallazgo resuelto aunque la pantalla de detrás diga lo contrario.**

---

## 8. Los límites: cuándo esto se hace en el servidor

Generar en cliente tiene tres ventajas reales —no hay infraestructura, no hay latencia de red, y el dato no sale del navegador— y unos límites que conviene reconocer **antes** de haber escrito mil líneas de maquetación.

**Se queda corto cuando aparece cualquiera de estas cinco:**

- **Firma digital con validez legal.** jsPDF no la hace y ninguna librería de cliente puede: firmar exige una clave privada, y una clave privada en el navegador no es una clave privada.
- **PDF/A o cualquier requisito de archivo a largo plazo.** Es una familia de restricciones sobre fuentes embebidas, metadatos y color que jsPDF no garantiza.
- **El documento tiene que ser idéntico para todo el mundo, siempre.** En cliente depende del navegador, de la versión de la librería que tenga cacheada y de las fuentes disponibles. Si el PDF es la prueba de algo, esa variabilidad es un problema.
- **Maquetación compleja de verdad**: columnas, flotantes, texto que fluye alrededor de imágenes. jsPDF no tiene flujo (§1) y todo eso se convierte en aritmética a mano.
- **Volumen.** Un PDF por certificado está bien; cuatrocientos PDF en un lote no se generan en la pestaña de nadie.

**Las alternativas, comparadas y no instaladas:**

| | Cómo funciona | Le va bien | Le va mal |
|---|---|---|---|
| **jsPDF** (lo que usa CertCore) | dibujas con coordenadas | documentos de estructura fija y conocida | maquetación compleja, tipografía fina |
| **pdfmake** | describes el documento como un objeto y él maqueta | tablas y listas anidadas, flujo entre páginas | bundle mayor; el modelo declarativo hay que aprenderlo |
| **html2canvas + jsPDF** | captura el DOM como imagen y la mete en un PDF | reproducir exactamente lo que se ve | **el resultado es una imagen**: sin texto seleccionable, sin búsqueda, pesado, y borroso al imprimir |
| **Servidor** (Puppeteer, wkhtmltopdf, una librería de backend) | HTML o plantilla renderizados fuera | firma, PDF/A, lotes, resultado idéntico siempre | infraestructura, latencia, y un servicio más que mantener |

> ⚠️ **`html2canvas` merece un párrafo propio porque es la trampa más tentadora.** "Convertir la pantalla en PDF" suena a la solución perfecta y a menudo es la peor: produce un documento que es una foto, y una foto de un certificado no se puede buscar, no se puede copiar, pesa cinco veces más y se ve mal impresa. Además choca de frente con la regla de la §7 — armar el documento desde la vista es exactamente lo que ese enfoque hace por diseño.

---

## 9. El PDF descargado no se revoca

Merece medio párrafo porque es la mejor conversación que ofrece este tema sobre los límites de lo que un sistema puede garantizar.

Un certificado se puede **revocar** en CertCore: el estado pasa a `revoked` y todas las pantallas lo reflejan. **El PDF que alguien descargó ayer no se entera de nada.** Está en el disco de una persona, probablemente reenviado por correo, y no hay ninguna acción del sistema que lo alcance. Podrías generar uno nuevo; no puedes desandar el que salió.

Lo que sí se puede hacer, y es lo que hacen los sistemas serios, es reducir el daño:

- **Fechar el documento en el propio documento.** El pie de la §4 con la fecha y la hora de generación es lo mínimo, y convierte "este PDF miente" en "este PDF es de antes de la revocación", que es una conversación completamente distinta.
- **Poner un identificador y un punto de verificación.** Un código y una frase del tipo *"el estado vigente de este certificado se consulta en el sistema"* traslada la autoridad de vuelta a la fuente. Es lo que hace que el papel sea una copia y no el original.
- **No prometer en el PDF lo que el PDF no puede sostener.** Un documento que dice "vigente" sin más está afirmando algo sobre el futuro. Uno que dice "vigente al 14/03/2026 09:41" está afirmando algo que seguirá siendo cierto para siempre.

> 🧠 Ésta es la lección transferible del apéndice entero, y no es sobre PDF: **un artefacto que sale del sistema deja de estar bajo el control del sistema.** Todo lo que quieras poder afirmar sobre él dentro de dos años tiene que estar impreso dentro de él.

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer | Por qué |
|---|---|---|
| Documento de estructura fija | jsPDF con un cursor y funciones | es para lo que sirve |
| Una tabla que puede paginar | `jspdf-autotable` con `didDrawPage` | maquetar tablas a mano no compensa nunca |
| Texto largo en una celda o un párrafo | `splitTextToSize` | jsPDF escribe fuera del papel sin avisar |
| Texto en español | las fuentes estándar, sin tocar nada | el español cabe en su codificación |
| Un `✓`, una flecha, un emoji | cambiarlo por texto, o embeber fuente | y embeber cuesta cientos de KB |
| Un logo | PNG, reescalado antes | PNG para gráficos, JPEG para fotos |
| Fotos de evidencia | reescalar en `canvas` y JPEG | o decidir que van enlazadas y no incrustadas |
| Importar la librería | `await import()` dentro del método | 300 KB que no viajan en el arranque |
| El tipo de `jsPDF` en un archivo puro | `import type` | desaparece en la compilación |
| Componer el contenido | desde la fuente, con una interfaz explícita | la vista es una foto de hace un rato |
| Firma, PDF/A, lotes | servidor | no es una limitación de la librería: es del navegador |
| "Que salga igual que la pantalla" | replantear el requisito | `html2canvas` produce una foto, no un documento |

---

## 📚 Referencias

- https://github.com/parallax/jsPDF — el repositorio de `jspdf`. El README es el punto de partida y se queda corto enseguida, que es la razón de este apéndice.
- https://raw.githack.com/MrRio/jsPDF/master/docs/index.html — la documentación de la API generada, con `text`, `addImage`, `splitTextToSize`, `setPage` y `getNumberOfPages`. ⚠️ Documenta la rama principal; comprueba que el método que buscas exista en 2.5.1.
- https://github.com/simonbengtsson/jsPDF-AutoTable — `jspdf-autotable` 3.8.x, con sus opciones y sus ganchos. Los ejemplos de la página de demostración son la mejor referencia de `columnStyles` y `didDrawPage`.
- https://github.com/parallax/jsPDF/tree/master/fontconverter — el conversor oficial de fuentes a base64 de la §2.
- https://developer.mozilla.org/es/docs/Web/API/HTMLCanvasElement/toDataURL — para el reescalado de imágenes de la §5.
- http://pdfmake.org — la alternativa declarativa de la tabla de la §8. Se compara y no se instala.

> ⚠️ Las versiones de estas dos librerías se mueven más deprisa que su documentación, y varias respuestas populares de Stack Overflow describen la API de jsPDF 1.x, que era incompatible. La señal es `new jsPDF()` con argumentos posicionales (`new jsPDF('p', 'mm', 'a4')`): eso es la 1.x, y aunque siga tolerándose, es la marca de un ejemplo viejo.

**Orden de lectura sugerido:** la §1 antes de escribir la primera línea, porque sin las tres reglas de coordenadas todo lo demás parece magia. La §7 **antes** que la §3 y la §6 — es la única que trata de un bug con consecuencias fuera del sistema. La §2 sólo cuando algo salga con cuadros en el PDF. La §6 cuando midas el bundle en la Fase 13. La §8 y la §9 el día que alguien pregunte si el certificado tiene validez legal, que es una pregunta que llega siempre.

---

## 🧪 Ejercicios (7)

1. 🟢 Genera un PDF con tres `document.text()` en la misma `y`. Ábrelo y anota qué ves. Después arréglalo con el patrón del cursor de la §1 y explica en una línea por qué la consola no dijo nada en el primer caso.

2. 🟢 Escribe en el certificado un texto con tildes y eñes (`Edificio Aurora S.A.S. — inspección de señalización`) y otro con un `✓`. Abre el PDF y anota cuál de los dos se rompe. Explica por qué, con la §2 en la mano.

3. 🟡 Añade a la tabla de hallazgos una nota de 300 caracteres. Anota qué hace `autoTable` con ella, y qué pasa si el mismo texto lo escribes con `document.text()` sin `splitTextToSize`.

4. 🟡 Haz que el certificado ocupe tres páginas —duplicando hallazgos en la semilla— y añade el pie "Página X de Y" con la técnica de dos pasadas de la §4. Explica en dos líneas por qué no se puede hacer en una sola pasada.

5. 🟠 Mueve el `import { jsPDF } from 'jspdf'` a la cabecera del servicio. Construye con `ng build --named-chunks --stats-json`, localiza en qué chunk quedó la librería y anota el tamaño de `main.js` antes y después. Devuélvelo al `await import()` y anota la tercera cifra.

6. 🟠 Reproduce el incidente 14 completo: abre el detalle de un certificado en una pestaña, resuelve uno de sus hallazgos en otra, y descarga el PDF desde la primera. Después verifica que la versión de la Fase 10 §5.8 trae el dato correcto. Escribe el post-mortem de tres líneas: síntoma, causa raíz y prevención.

7. 🔴 Te llega el requisito: *"el certificado en PDF tiene que llevar firma digital con validez ante el ente regulador"*. Escribe la respuesta técnica de una página que le darías a tu líder: por qué no se puede hacer en el cliente, qué haría falta, qué alternativa hay mientras tanto (con la §9 como argumento), y una estimación honesta de qué implica montarlo en servidor. El criterio de éxito es que alguien de negocio entienda por qué la respuesta no es "una semana".

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el generador de certificados lo escribe la **Fase 10**, así que lo que salga de leerlo se commitea con el prefijo de esa fase (`fase 10: …`). Las tres cifras del ejercicio 5 van en el mensaje de un tag anotado (`ej/a08/5`), que es donde una medición de bundle queda fechada y comparable con la de la Fase 13. Si haces el ejercicio 6, el par de tags del incidente 14 está reservado en el cuaderno y es donde el `git diff` entre roto y arreglado **es** el fix aislado del ruido de la fase. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
