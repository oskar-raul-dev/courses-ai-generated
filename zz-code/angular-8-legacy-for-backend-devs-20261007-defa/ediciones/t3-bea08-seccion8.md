## 8. Horario de verano: Ottawa sí, y por eso

Ottawa y Gatineau **sí** tienen horario de verano. `America/Toronto` es UTC−05:00 de noviembre a marzo y UTC−04:00 de marzo a noviembre, y el cambio cae en domingo a las 02:00 de la madrugada. Los de los años que importan aquí, sacados de la base IANA y no de un calendario:

| Año | Empieza el horario de verano | Termina |
|---|---|---|
| 2019 | 10 de marzo | 3 de noviembre |
| 2020 | 8 de marzo | 1 de noviembre |
| 2021 | 14 de marzo | 7 de noviembre |
| 2022 | 13 de marzo | 6 de noviembre |

Y eso explica la frase del anclaje: el `-05:00` de los datos es correcto **porque todos caen en invierno**. Es el desfase que la Era 1 escribió como constante, en un proyecto que arrancó en febrero, con la mitad del equipo en Costa Rica, donde la hora no cambia nunca. Nadie se hizo la pregunta de marzo.

La aritmética del error, comprobada en Java 8:

```java
OffsetDateTime era1 = OffsetDateTime.parse("2021-07-15T09:00:00-05:00");
era1.atZoneSameInstant(ZoneId.of("America/Toronto"));
// 2021-07-15T10:00-04:00[America/Toronto]
```

Quien escribió `09:00:00-05:00` en julio quería decir "las nueve en Ottawa". El instante que guardó son **las diez**. Una hora corrida en todo lo que se escribió con la constante entre marzo y noviembre, y ningún error en ningún lado: es una cadena ISO válida que representa un instante que existe. Cuando dos marcas así quedan a menos de una hora de una marca bien escrita —una muestra *recibida* con la constante y *validada* con el reloj del navegador—, el orden entre las dos se invierte. Es el incidente **22** del cuaderno base, y su síntoma es exactamente ese: resultados que se validaron antes de que llegara la muestra.

Y las dos madrugadas del año que no se parecen a ninguna otra:

```java
ZoneId ottawa = ZoneId.of("America/Toronto");
ZonedDateTime.of(LocalDateTime.parse("2021-03-14T02:30"), ottawa);
// 2021-03-14T03:30-04:00 — las 02:30 de ese domingo no existen: java.time las corre una hora
ZonedDateTime early = ZonedDateTime.of(LocalDateTime.parse("2021-11-07T01:30"), ottawa);
// 2021-11-07T01:30-04:00 — y esta existe dos veces:
early.withLaterOffsetAtOverlap();
// 2021-11-07T01:30-05:00
```

Una muestra tomada "a la 01:30" del primer domingo de noviembre es ambigua si solo se guardó la hora local; con un instante no lo es. Es el argumento más corto que existe a favor de §2.

> 💡 **Nunca calcules un desplazamiento a mano.** `ZoneId.of("America/Toronto")` consulta la base de datos IANA, que tiene la historia completa de los cambios por decreto. Y la historia importa aunque parezca trivia: hasta 2006, Canadá cambiaba la hora el primer domingo de abril y el último de octubre; desde 2007, el segundo domingo de marzo y el primero de noviembre. Una regla escrita a mano con las fechas de hoy calcula mal cualquier marca de 2006 o anterior. Restar cinco horas a mano es correcto medio año, y falso en general.

Dónde más te muerde, aparte de la constante:

- **Un contenedor con la zona mal puesta**: el proceso cree estar en otro sitio, y todo `Date.toString()` y todo `LocalDate` de Spring Data se van con él (§5).
- **Una biblioteca con la base de zonas desactualizada**: los cambios de huso los deciden gobiernos, a veces con semanas de aviso, y una JVM vieja tiene la tabla de cuando se publicó. La tuya dice qué versión trae: `ZoneRulesProvider.getVersions("America/Toronto")`.
- **Los datos de un proveedor**: un fabricante de analizadores con soporte en otra zona escribe sus marcas con su propio desfase, y el de él también cambia, en otras fechas.

---

