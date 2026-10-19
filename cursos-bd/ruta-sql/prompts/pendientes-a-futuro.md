# 📌 Pendientes a futuro

## Ruta SQL

> **Qué es:** lo que quedó abierto al cerrar el curso (T16, 18/10/2026). Junta los 📌 *Pendientes
> sugeridos* que las fases dejaban al final, fuera de lo que lee el estudiante, y lo que el plan de
> producción no cerró. Los publicados ya no los llevan. No viaja al repositorio público, como el resto de
> `prompts/`.

---

## 🔓 Lo que sigue abierto

Nada bloquea al estudiante: las dos son límites que el curso ya declara donde aplican.

| Desde | Pendiente | Dónde se declara |
|---|---|---|
| `a01` | Linux y Windows 11 con WSL2, escritos desde la documentación y sin ejecutar; Podman probado solo con SQL Server | en la cabecera de `a01`, "no ejecutado todavía en esta plataforma". Se cierra corriéndolo en una máquina de cada una |
| E-98 | el contenedor de SQL Server muere por memoria recorriendo los 12,7 M de resultados de ss05, con 2, 3 y 4 GB | en `a08` y en ss05, sin causa encontrada |

## ✅ Resueltos al cerrar

- `shm_size` de Postgres (F25, E-69): en el `compose.yaml` desde T13, con M-58.
- Los núcleos del SIH y de Alameda (F25, F26): en la historia desde T13.
- `a04` con `lab measure` y `lab race` en SQL Server (ss02, ss03), `a07` con las tablas del track (ss01, ss02),
  y el perfil `dab` en `a02` (ss05): hechos en T14 y T16.
- Los README de `src/26-…/martes/` y `0-ESTRUCTURA-CURSO.md` (F26): T15.
- F07 remite a la Fase 23 para el "quién" de cada corrección (T16); a ss04 no, por la regla del track.
- Las palabras de F19–F23 (T16): ampliadas con prosa de mecanismo y M-78; el conteo de F19 además cortaba en el 🧪 de su sección 7, que pasó a ✍️.
- La historia y la caja (18/10/2026, después de T16):
  - F04: la historia, F00, F02 y su solucionario dicen "casi trescientas líneas", como el `ModParser.bas` de la caja (272).
  - F05: la historia agrega que la recepción aprendió a cargar el pasaporte directo en `dni` y el parser solo
    toca las fichas sin DNI, así que en 2026 ninguna conserva el país, como mide la Fase 05 (5.137 de 5.137).
  - F03: los centinelas `'SIN DATO'` y `1900-01-01` solo los nombraba el diseño en `prompts/`; nada publicado
    los cita. Se cierra sin tocar el generador.
  - F06: los protocolos fuera de convenio quedan como los declara el boss global (D50); ninguna otra fase los cruza.
- La nota de F10 sobre el UUIDv7 (ss04): **no se agrega**, decidido por la regla del track (cero añadidos al
  camino base). ss04 lo documenta entero.
- Los README de `src/ss01-…` a `src/ss05-…` y de `src/25-…` (18/10/2026), desde las cabeceras de cada script y
  la lista de comprobación de cada lección.
