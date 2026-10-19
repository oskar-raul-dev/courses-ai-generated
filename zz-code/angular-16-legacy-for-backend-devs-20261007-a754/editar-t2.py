#!/usr/bin/env python3
"""T2: reemplazos exactos en el track base (Colombia -> tres sedes; regla de vigencia
en la hora del activo). Cada reemplazo debe aparecer exactamente una vez; si no, aborta
sin escribir nada. Uso: python3 editar-t2.py [CURSO]."""
import sys
from pathlib import Path

CURSO = Path(sys.argv[1]) if len(sys.argv) > 1 else (
    Path(__file__).resolve().parents[2] / "cursos-legacy/angular-16-legacy-for-backend-devs")

CAMBIOS = {
    "07-plantillas-versionadas.md": [
        (""" * La zona horaria de referencia del negocio. CertCore opera en Colombia, que
 * no tiene horario de verano, así que un desplazamiento fijo es correcto y no
 * hace falta Intl para esto.
 *
 * ⚠️ Si algún día CertCore opera en una zona CON horario de verano, este
 * archivo entero cambia: haría falta `Intl.DateTimeFormat` con `timeZone`, no
 * un número. Está escrito aquí para que ese día se cambie UN archivo.""",
         """ * La zona horaria de referencia del negocio. CertCore opera desde Bogotá,
 * Lima y Quito, las tres en UTC-5 y sin horario de verano, así que un
 * desplazamiento fijo es correcto y no hace falta Intl para esto.
 *
 * ⚠️ Si algún día un activo está en otra zona, o en una CON horario de verano,
 * este archivo entero cambia: haría falta `Intl.DateTimeFormat` con `timeZone`,
 * no un número. Está escrito aquí para que ese día se cambie UN archivo."""),
        ("Aquí no hay horario de verano y aun así se escribe bien: el día que CertCore abra en otro país, este archivo ya está preparado.",
         "Ninguna de las tres sedes tiene horario de verano y aun así se escribe bien: el día que haga falta una zona que lo tenga, este archivo ya está preparado."),
    ],
    "10-certificados-vigencia.md": [
        ("> [Incidentes asociados](cuaderno-incidentes.md): 14, 15\n",
         "> [Incidentes asociados](cuaderno-incidentes.md): 14, 15, 21\n"),
        ("significa que el certificado vale todo el día 10 en Colombia, que es donde opera CertCore y donde se hacen las inspecciones. Es la única",
         "significa que el certificado vale todo el día 10 en la hora local del lugar donde está el activo, que es donde se hacen las inspecciones. Las tres sedes —Bogotá, Lima y Quito— están en UTC−5 sin cambio de hora, y por eso el código la llama *la zona del negocio* y la escribe una sola vez. Es la única"),
        (" * no lo es en cuanto aparece un cambio de hora. Aquí no hay horario de verano\n * y aun así se escribe bien.",
         " * no lo es en cuanto aparece un cambio de hora. En las tres sedes no hay\n * horario de verano y aun así se escribe bien."),
        ("  // El documento se lee en Colombia: se imprime el día de negocio, no el\n",
         "  // El documento se lee donde está el activo: se imprime el día de negocio, no el\n"),
        ("lo que haría falta el día que CertCore opere en una zona **con** horario de verano, que es cuando el offset fijo de `business-day.ts` deja de servir. Hoy no hace falta; conviene saber dónde está la puerta.",
         "lo que haría falta el día que un activo esté en otra zona, o en una **con** horario de verano, que es cuando el offset fijo de `business-day.ts` deja de servir. Conviene saber dónde está la puerta."),
        ("que es el problema que Colombia **no** tiene;",
         "que es el problema que ninguna de las tres sedes tiene;"),
        ("es la respuesta a una pregunta que este curso no tiene, y leerla antes confunde.",
         "es la respuesta a una pregunta que estas fases todavía no hacen, y leerla antes confunde."),
    ],
    "06-clientes-activos.md": [
        ("> [Incidentes asociados](cuaderno-incidentes.md): 07\n",
         "> [Incidentes asociados](cuaderno-incidentes.md): 07, 22\n"),
    ],
    "forense-fase-10.md": [
        ("Un certificado vence al final del día **en el huso donde opera la empresa**, y eso",
         "Un certificado vence al final del día **en el huso donde está el activo**, y eso"),
        ("vence al final del día laboral de donde opera la empresa.",
         "vence al final del día laboral del lugar donde está el activo."),
        ("**Incidentes del cuaderno que usan esta ruta:** 14 (el PDF que no coincide) y 15 (venció ayer/hoy).",
         "**Incidentes del cuaderno que usan esta ruta:** 14 (el PDF que no coincide), 15 (venció ayer/hoy) y 21 (vencido antes de hora en Galápagos)."),
    ],
    "forense-fase-06.md": [
        ("**Incidentes del cuaderno que usan esta ruta:** ninguno directamente, y es a propósito: esta ruta es la **herramienta** con la que se resuelven varios de la semana 2 y 3.",
         "**Incidentes del cuaderno que usan esta ruta:** el 22 (el RUC que el formulario no acepta) directamente; los demás, a propósito, solo como **herramienta**: con esta ruta se resuelven varios de la semana 2 y 3."),
    ],
    "a13-i18n.md": [
        ("CertCore opera en un solo país, con una norma en un solo idioma, y sus certificados se emiten en español porque así los exige quien los recibe.",
         "CertCore opera en tres países, cada uno con su norma, y los tres hablan el mismo idioma: sus certificados se emiten en español porque así los exige quien los recibe."),
    ],
}

nuevos = {}
for nombre, pares in CAMBIOS.items():
    texto = (CURSO / nombre).read_text(encoding="utf-8")
    for viejo, nuevo in pares:
        n = texto.count(viejo)
        if n != 1:
            sys.exit(f"{nombre}: {n} apariciones de {viejo[:60]!r}; no se escribe nada")
        texto = texto.replace(viejo, nuevo)
    nuevos[nombre] = texto
for nombre, texto in nuevos.items():
    (CURSO / nombre).write_text(texto, encoding="utf-8")
    print("editado", nombre)
