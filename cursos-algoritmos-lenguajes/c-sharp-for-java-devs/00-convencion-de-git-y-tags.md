# 🏷️ Convención de git y tags
## C# para desarrolladores Java senior

Documento de consulta. Todas las fases lo enlazan desde su bloque 🏷️ de cierre y ninguna lo
reexplica. No enseña git: fija la convención de este curso y dice qué tiene de particular, que es
tener **dos runtimes conviviendo en el mismo repositorio**.

---

## 📦 Un repositorio, dos soluciones

Todo el curso vive en un repositorio, y el código en `src/`, con la estructura que fija la fase 00:

```text
src/
  Sige.sln          ← la solución heredada, formato de 2017 · net48
  Cordillera.slnx   ← la solución nueva, formato SLNX · net10.0
  legacy/           ← el código de 2017: SIGE y su base de datos
  modern/           ← lo nuevo: el arnés, el dominio, los servicios
  fases/NN-nombre/  ← lo propio de una fase: su demo y su miniproyecto
```

Cada subárbol tiene su propio `Directory.Build.props` y su propio `.editorconfig`, y ahí está la
mitad del valor de esta separación: **`dotnet format` y los analizadores nunca tocan `legacy/`**.
Un `dotnet format` sobre el código de 2017 produce el diff más peligroso del curso — doscientos
archivos cambiados, ninguna prueba fallando, y tres cosas rotas que aparecen en dos semanas.

**Ningún `.csproj` está en las dos soluciones.** No es purismo: un proyecto multi-destino te
dejaría escribir `async` dentro de un archivo de 2017 sin que el compilador se queje, y ese es
exactamente el error que el curso enseña a no cometer. La frontera entre generaciones es física.

El directorio de una fase se llama **igual que su `.md`**, sin extensión: la fase
`09-acceso-a-datos-esquema-hostil.md` tiene su código en
`src/fases/09-acceso-a-datos-esquema-hostil/`.

---

## ✍️ Commits

Con el prefijo de la fase, siempre, y en español como el resto de la prosa del curso:

```text
fase 09: mapea MOVINVEN a InventoryMovement con el borde en un solo sitio
fase 09 ej12: mide el N+1 del catálogo con seguimiento activado
fase 09 mini: filtro global de BORRADO y los tres sitios donde no aplica
```

Un commit por unidad de trabajo con sentido —una sección, un ejercicio, el miniproyecto—, no uno
por párrafo ni uno por fase entera. Y los mensajes dicen **qué decidiste**, no qué archivo
tocaste: `git log --oneline` tiene que servir de bitácora de decisiones cuando vuelvas en la fase
veinte a entender por qué el borde quedó donde quedó.

Ramas de trabajo con prefijo, para no chocar con el espacio de nombres de los tags:

- **`wip/`** — lo que estás escribiendo y todavía no cierra. `wip/fase-10-doble-escritura`.
- **`spike/`** — el experimento que probablemente se tira. `spike/aot-reflexion`.

---

## 🏷️ Dos tags por fase

**`fase-NN`**, anotado, cuando la fase cierra: el checklist de su sección 2 en verde, el
miniproyecto corriendo y `git status` limpio. El mensaje lleva el checklist, una línea por ítem.

```bash
git tag -a fase-09 -m "F9 cerrada:
- MOVINVEN mapeado con el borde 🧬 en un solo archivo
- filtro global de BORRADO, y los tres sitios donde EF Core no lo aplica documentados
- Dapper, EF Core y ADO.NET medidos sobre la consulta de catálogo, con el plan medido antes
- deudas de la F02 y la F03 cobradas"
```

**`mini-NN`**, anotado, cuando el miniproyecto pasa sus criterios de aceptación. Y aquí va la
regla que hace útil el tag: **el número que arrojó su medición va en el mensaje**.

```bash
git tag -a mini-09 -m "Mini F9: MOVINVEN a modelo limpio contra SQL Server en contenedor · mediana 42 ms, p95 71 ms, 1,4 MB asignados"
```

Un miniproyecto es un entregable comparable: `git show mini-06` es cómo recuperas, tres fases
después, el pico de memoria que te dio entonces, sin volver a ejecutar nada y sin confiar en tu
memoria. Por eso el número vive en el tag y no en un archivo que se edita.

> 💡 `git tag -l 'fase-*'` es el índice del curso, y `git tag -l 'mini-*' -n99` es tu propio
> `BENCHMARKS.md` en bruto.

---

## 🧬 El tag de una fase mixta

Cinco fases del Bloque B y el Bloque C son **mixtas**: tocan la solución heredada y la nueva en el
mismo trabajo. Su tag cubre las dos mitades y no se parte en dos, porque el entregable es el
cruce: una fase que dejara `Sige.sln` compilando y `Cordillera.slnx` roto —o al revés— no está
cerrada.

De ahí sale lo único que este curso le pide a git y que un curso de un solo runtime no necesita:
**antes de etiquetar una fase mixta, las dos soluciones compilan y las dos suites pasan.**

```bash
msbuild src\Sige.sln /t:Rebuild /p:Configuration=Release
dotnet build src\Cordillera.slnx -c Release
dotnet test  src\Cordillera.slnx -c Release
```

El legado se compila con MSBuild y no con `dotnet build`, porque `net48` no está en formato SDK
hasta que la fase 11 lo migra. Que el comando sea distinto no es una molestia: es el recordatorio
diario de en qué lado de la frontera estás trabajando.

---

## 💸 Cómo se lee la factura de una deuda

El curso deja deudas técnicas a propósito, marcadas 💸, y cada una declara **en qué fase se
paga**. Cuando la fase que la cobra llega, el `git diff` entre los dos tags **es** la factura: lo
que costó el atajo, medido en el único lugar donde no se puede discutir.

```bash
git diff fase-02 fase-09 -- src/fases/02-nullable-y-pattern-matching/
git diff fase-07 fase-16 -- src/legacy/Sige.DataAccess/App.config
```

La segunda es la más vieja del curso y la más satisfactoria: la cadena de conexión que en la fase
07 estaba en el `App.config` de noventa equipos, y en la 16 ya no está en ninguno.

Cuando una fase cobra una deuda, su bloque 🏷️ cita el `git diff` exacto. Si el diff no muestra lo
que la fase dice que cobró, la deuda no está pagada — está declarada pagada, que no es lo mismo.

---

## 🧾 Qué **no** entra al repositorio

Un `.gitignore` de .NET estándar, más tres cosas propias de este curso:

- **`bin/`, `obj/` y la carpeta del perfilador.** Lo de siempre.
- **Los secretos, nunca.** Ni `appsettings.Development.json` con la cadena real, ni el `.env` del
  contenedor. La fase 16 trata el caso incómodo —qué hacer cuando **ya está en el historial**— y
  no es `git rm`.
- **Los datos generados.** El generador de datos sucios de la fase 07 tiene **semilla fija**: se
  versiona el generador, no los veinte megas que produce. Si dos lectores obtienen datos
  distintos con la misma semilla, eso es un bug del generador y se arregla ahí.
