# ✅ Soluciones — Fase 23: La base como producto

> **Curso:** Ruta SQL · Solucionario de la [Fase 23](../23-la-base-como-producto.md)
> **Ejercicios:** 26 · **Perfil:** M · **Motores:** Postgres 18.6 y PostgREST v16.4 de [`a02`](../a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Las soluciones suponen `23-la-base-como-producto/01_setup.sql` y `02_rls.sql` corridos. Los ejercicios 1 a 16 están ejecutados con `05_ejercicios.sql`, y su salida se registró en la sesión de verificación del 14/10/2026. Los de 17 a 26 llevan rúbrica, que también está en la lección. Los boss no publican su solución.

---

## 🟢 Fácil (1–8)

### Ejercicio 1

```text
      rol      | miembro_de 
---------------+------------
 authenticator | medico
 authenticator | paciente
 authenticator | web_anon
```

**Lectura:** `authenticator` es el único rol que entra (`LOGIN`), y puede cambiar a los otros tres. Es `NOINHERIT`: no tiene los permisos de ellos hasta que cambia de rol, que es lo que hace PostgREST en cada pedido.

### Ejercicio 2

```text
ERROR:  permission denied for view resultados
```

**Lectura:** `web_anon` no tiene ningún permiso sobre las vistas. Sin token, la API responde 401 con ese mismo mensaje.

### Ejercicio 3

```text
 patient_id |   rol    | ausente 
------------+----------+---------
 39         | paciente | 
```

**Lectura:** `api.claim` lee los claims que PostgREST deja en `request.jwt.claims`. Un claim que no existe devuelve `NULL`, y una política que lo compara no ve ninguna fila.

### Ejercicio 4

```text
 resultados_propios 
                426
```

### Ejercicio 5

```text
 protocolo_ajeno 
               0
```

**Lectura:** no es un error: es una ausencia. La política esconde el protocolo, y quien pregunta no puede saber si existe.

### Ejercicio 6

```text
 protocolos_derivados 
                 1114
```

### Ejercicio 7

```text
 tablename |           policyname           |  cmd   |   roles    
-----------+--------------------------------+--------+------------
 lab_order | medico_ve_lo_que_derivo        | SELECT | {medico}
 lab_order | paciente_ve_lo_suyo            | SELECT | {paciente}
 result    | medico_carga_en_lo_suyo        | INSERT | {medico}
 result    | medico_ve_resultados_derivados | SELECT | {medico}
 result    | paciente_ve_sus_resultados     | SELECT | {paciente}
```

### Ejercicio 8

```text
 Aggregate
   ->  Index Only Scan using lab_order_patient_id_idx on lab_order o
         Index Cond: (patient_id = (((current_setting('request.jwt.claims'::text, true))::json ->> 'patient_id'::text))::integer)
```

**Lectura:** la política es una comparación de columna de la tabla protegida, y el planificador la usa como condición del índice. Por eso RLS le cuesta poco al paciente (§6.1 de la lección).

---

## 🟡 Intermedio (9–16)

### Ejercicio 9

```text
 pacientes_distintos_en_1000_filas 
                               165
```

**Lectura:** sin `security_invoker`, la vista se lee con los permisos de su dueño, el superusuario, que no pasa por RLS. El paciente 39 ve filas de 165 pacientes en las primeras mil. Es el criterio C4 del boss V.

### Ejercicio 10

```text
ERROR:  new row violates row-level security policy for table "result"
```

### Ejercicio 11

```text
INSERT 0 1
```

**Lectura:** la política `FOR INSERT … WITH CHECK` deja entrar la fila en un protocolo que el médico derivó (la transacción se revierte después, para no tocar el modelo).

### Ejercicio 12

```text
 lab_order_id | visible_number | coincide 
--------------+----------------+----------
     10006666 | C-0048213      | t
```

**Lectura:** la URL del portal es el MD5 del número visible, sin sal. Con el número, se calcula la URL; con la URL, se busca el número entre un millón de candidatos en segundos (§8 de la lección).

### Ejercicio 13

```text
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=9684
   ->  Seq Scan on lab_order o (actual rows=1114.00 loops=1)
         Filter: (ANY (lab_order_id = (hashed SubPlan 1).col1))
         Rows Removed by Filter: 1326508
         SubPlan 1
           ->  Bitmap Heap Scan on referral ...
                 ->  Bitmap Index Scan on referral_physician_idx
 Execution Time: 93.029 ms
```

**Lectura:** el índice de `referral` resuelve la subconsulta, pero la tabla protegida se recorre entera: 1.326.508 filas descartadas para encontrar 1.114.

### Ejercicio 14

```text
 Aggregate (actual rows=1.00 loops=1)
   Buffers: shared hit=5
   ->  Index Only Scan using f23_lab_order_physician on f23_lab_order (actual rows=1114.00 loops=1)
 Execution Time: 0.139 ms
```

**Lectura:** con el médico como columna de la tabla protegida, la política se resuelve en el índice: 5 bloques contra 9.684.

### Ejercicio 15

```text
    rolname    | rolsuper | rolbypassrls 
---------------+----------+--------------
 authenticator | f        | f
 medico        | f        | f
 paciente      | f        | f
 postgres      | t        | t
 web_anon      | f        | f
```

**Lectura:** solo el superusuario pasa por encima de RLS. Por eso las otras fases, que corren como `postgres`, no cambian de resultado, y por eso una vista creada por `postgres` sin `security_invoker` es una puerta abierta.

### Ejercicio 16

```text
 sin_claim 
-----------
         0
```

**Lectura:** sin claims, la política no ve ninguna fila. La primera versión de `api.claim` fallaba aquí con `invalid input syntax for type json`, porque después de un `set_config` en la sesión, `current_setting(…, true)` devuelve una cadena vacía y no `NULL`. La función usa `nullif(…, '')` desde entonces.

---

## 🟠 Difícil (17–22) — rúbrica

### Ejercicio 17

*Las vistas versionadas.*

**Rúbrica (sobre 3 puntos):** 1 punto por el esquema nuevo con sus vistas; 1 por la convivencia de los dos; 1 por el plan de retiro con una métrica de uso.

### Ejercicio 18

*La política por sede.*

**Rúbrica (sobre 4 puntos):** 1 punto por el claim y el rol; 1 por la política sobre una columna de la tabla protegida; 1 por la medida con y sin índice; 1 por decir cuántos protocolos ve cada sede.

### Ejercicio 19

*La rotación del secreto.*

**Rúbrica (sobre 3 puntos):** 1 punto por aceptar dos claves durante la transición (JWKS); 1 por la expiración corta de los tokens; 1 por la invalidación de los tokens viejos.

### Ejercicio 20

*El límite de filas.*

**Rúbrica (sobre 3 puntos):** 1 punto por el límite de filas del servidor; 1 por la paginación con `Range` o `limit`/`offset`; 1 por la medida.

### Ejercicio 21

*La función con permisos del dueño.*

**Rúbrica (sobre 3 puntos):** 1 punto por explicar que corre con los permisos del dueño; 1 por el `search_path` fijado en la función; 1 por limitar lo que la función puede leer.

### Ejercicio 22

*Quién leyó qué.*

**Rúbrica (sobre 3 puntos):** 1 punto por dónde se registra (registro de PostgREST, o una función de auditoría); 1 por el costo de registrar cada lectura; 1 por la retención y quién la consulta.

---

## 🔴 Muy difícil (23–26) — rúbrica

### Ejercicio 23

*ORDS, con la documentación.*

**Rúbrica (sobre 3 puntos):** 1 punto por describir ORDS; 1 por la comparación en prosa sin números de Oracle (D20); 1 por decir cuándo lo elegirías.

### Ejercicio 24

*La cárcel.*

**Rúbrica (sobre 4 puntos):** 1 punto por cada regla bien ubicada con su argumento; 1 por la frontera explícita (quién ve qué, contra reglas de negocio).

### Ejercicio 25

*La política que sí usa un índice, en el modelo.*

**Rúbrica (sobre 4 puntos):** 1 punto por la columna nueva sin reescritura; 1 por el relleno en lotes; 1 por el índice concurrente; 1 por el cambio de política en una transacción corta.

### Ejercicio 26

*El veredicto.*

**Rúbrica (sobre 3 puntos):** 1 punto por cada destino decidido con su argumento y su medida.
