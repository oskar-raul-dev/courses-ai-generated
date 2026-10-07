# 🧪 zz-instrucciones-20261007-3c8a · cómo correr estas pruebas

> **Curso:** zz-instrucciones · **Tanda:** convencion-git · **Creado:** 2026-10-07
> **Propósito:** probar TAG_DE_FASE del verificador base
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

`probar_tag.py` → la validación `TAG` que se agregó a `zz-instrucciones/herramientas/verificador_base.py`
junto con la plantilla `plantillas/convencion-de-git-y-tags.md`: cada capítulo debe nombrar su tag de
cierre (`fase-{slug}`, o `fase-{bloque}-{slug}` con bloques). No alimenta ningún H-n ni B-n.

## 2. 🛠️ Prerrequisitos

Python 3 (probado con 3.13.4), solo biblioteca estándar. Sin Docker.

## 3. 🧭 Reglas antes de correr

No aplica: no levanta contenedores ni toca nada fuera de este directorio.

## 4. ▶️ Cómo se corre

```bash
cd zz-code/zz-instrucciones-20261007-3c8a
python3 probar_tag.py | tee salidas/probar_tag.txt
```

Crea dos cursos mínimos (`curso-plano/` y `curso-bloques/01-datos/`) y corre sobre cada uno una
subclase de `Verificador` con `TAG_DE_FASE` fijado. Imprime el informe del verificador por curso.

## 5. 📏 Cómo se mide

No aplica: es una prueba de comportamiento, no una medición.

## 6. 🧮 Los intermedios que amasan la salida

No aplica: la salida es el informe del verificador, sin procesar.

## 7. ✅ Qué se espera ver

Resultado del 2026-10-07, en `salidas/probar_tag.txt`:

```text
== Plano sobre curso-plano
ERROR TAG       01-sin-tag.md: no nombra su tag «fase-01-sin-tag» (convención de git)
ERROR TAG       02-corto.md: no nombra su tag «fase-02-corto» (convención de git)
— 2 errores, 0 avisos
== ConBloques sobre curso-bloques
ERROR TAG       01-datos/02-joins.md: no nombra su tag «fase-01-02-joins» (convención de git)
— 1 errores, 0 avisos
```

`00-setup.md` y `01-datos/01-indices.md` pasan; `a01-apendice.md` no se revisa (no es capítulo);
`02-corto.md` falla aunque contenga `fase-02-corto-largo`, porque el tag tiene que terminar ahí.

## 8. 📂 Salidas

`salidas/probar_tag.txt`, regenerable con el comando de §4. Nada se copió al curso.

## 9. 🧹 Limpieza

Nada que limpiar fuera de este directorio. Los dos cursos de prueba se regeneran en cada corrida.

## 10. 🚫 Qué se dejó fuera

Nada.
