# 🧪 ruta-no-sql-lite-20261006-8b0f · cómo correr estas pruebas

> **Curso:** ruta-no-sql-lite · **Tanda:** revisión contra `zz-instrucciones/` · **Creado:** 2026-10-06
> **Propósito:** las comprobaciones de la revisión: `.gitignore` unificado, diagramas Mermaid y los
> reemplazos que alinearon lo publicado. No hay laboratorio ni contenedores.

## 1. 🎯 Qué se prueba y para qué

- **Que fundir `src/lab/.gitignore` en `src/.gitignore` no cambia qué se ignora** → guía §18.5 y la
  regla de un solo `.gitignore` por curso de los lineamientos.
- **Que los diagramas pasados a Mermaid dibujan y se leen** → `a05` (relaciones entre entidades) y el
  ejemplo de la guía §3 (D-12).
- **Que lo publicado quedó sin enlaces rotos, sin enlaces a otros cursos y sin citas a `prompts/`** →
  el verificador del curso en 0/0.

## 2. 🛠️ Prerrequisitos

Python 3 (biblioteca estándar), git y `mmdc` 12.0.0 (Mermaid CLI, instalado por Oskar en el host con
Node 24). El estado previo: el curso con las Tandas 0–2 cerradas.

## 3. 🧭 Reglas antes de correr

No toca Docker ni la configuración de la máquina. Los pasos 3–5 de `comandos-revision.sh` **editan el
curso**; ya se aplicaron, así que volver a correrlos no encuentra nada.

## 4. ▶️ Cómo se corre

```bash
bash zz-code/ruta-no-sql-lite-20261006-8b0f/comandos-revision.sh
```

Para repetir solo una comprobación:

```bash
cd cursos-bd/ruta-no-sql-lite
python3 prompts/verificar-corpus.py
mmdc -i ../../zz-code/ruta-no-sql-lite-20261006-8b0f/diagramas/a05-entidades.mmd -o /dev/null
```

## 5. 📏 Cómo se mide

No hay medición de rendimiento. El criterio del `.gitignore` es que las tres listas de
`git ls-files` (`-oi`, `-o`, `-ci`, con `--exclude-standard`, sobre `src/`) salgan idénticas antes y
después; el de los diagramas, que `mmdc` termine sin error y el PNG se lea; el de lo publicado, el
verificador en cero.

## 6. 🧮 Los intermedios que amasan la salida

`diff -q` entre cada par de listas de `salidas/`. Para las anclas y los enlaces, la salida del
verificador filtrada con `grep ANCLA-FE0F` y `grep ROTO` (`salidas/ancla-fe0f-antes.txt`,
`salidas/roto-antes.txt`) es la entrada de los dos reemplazos de `comandos-revision.sh`.

## 7. ✅ Qué se espera ver

Al 06/10/2026: `oi idéntico`, `o idéntico`, `ci idéntico` (37 543 archivos ignorados, casi todos de
`node_modules/` y `.venv/`); los dos PNG; el verificador en `0 errores, 0 avisos`, y con
`--publicacion` un solo error, el enlace de `a02` a `verificar-lab.sh` (deuda del plan).

## 8. 📂 Salidas

`salidas/gitignore-{antes,despues}-{oi,o,ci}.txt`, `salidas/ancla-fe0f-antes.txt`,
`salidas/roto-antes.txt`, `salidas/a05-entidades.png` y `salidas/guia-ficha-de-aeronave.png`.

## 9. 🧹 Limpieza

Nada fuera del directorio. `python3 zz-code/limpiar.py` muestra `salidas/` como regenerable.

## 10. 🚫 Qué se dejó fuera

Nada: no hay binarios ni dependencias. Las listas "antes" del `.gitignore` no se pueden regenerar
(el archivo de `src/lab/` ya no existe); están en `salidas/` como registro.
