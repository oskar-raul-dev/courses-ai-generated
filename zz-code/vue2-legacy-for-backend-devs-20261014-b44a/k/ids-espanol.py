#!/usr/bin/env python3
"""Identificadores con palabras en español en los bloques de código (sin strings ni comentarios).
Uso: ids-espanol.py bloques.json [prefijo-doc ...]   |   ids-espanol.py --dir <repo> (archivos .js/.vue)"""
import json, pathlib, re, sys
ES = set("""eliminar mostrar alerta mensaje tipo guardar enviar campo elegir opcion opciones valores valor confirmando
borrado valido titulo prioridad nuevo nueva lista datos usuario usuarios cargar cargando buscar filtro estado fecha
fechas crear editar borrar actualizar obtener listar paso pasos asignado asignar comentario comentarios tabla
modal modales ventana boton formulario resultado resultados total contador pagina paginas orden ordenar ticketA
error errores exito correo clave sesion salir entrar abrir cerrar cerrado abierto resuelto progreso agente agentes
reportador cliente clientes puntos puntaje iniciales semana dias hora horas nombre nombres cuenta cuentas producto
productos venta ventas caja pedido pedidos factura respuesta respuestas peticion pedir traer enviado recibido
esperar esperando listo hecho cuando donde porque prueba pruebas probar falla fallo todos cada otro otros mismo
primero ultimo siguiente anterior antes despues ahora hoy ayer manana con dialogo dialogos confirmar actividad
mostrando sin tarjeta tarjetas etiqueta etiquetas boton botones busqueda pendiente pendientes asignados
rechaza rechazar acepta aceptar cambio cambios ensayo pinta pintar carga llega llegar rellena rellenar escribe escribir
vacio vacia lleno llena dato fila filas columna columnas cola numero texto hijo padre""".split())
FALSOS = {"error", "errors", "total", "modal", "modals"}
STR = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|`(?:\\.|[^`\\])*`')
COM = re.compile(r"//.*$|/\*.*?\*/|<!--.*?-->|^\s*\*.*$|^\s*#.*$", re.M)
def partes(tok):
    return [p.lower() for p in re.findall(r"[A-Z]?[a-z]+|[A-Z]+(?![a-z])", tok)]
ATTR = re.compile(r'(?:v-[\w:.-]+|:[\w.-]+|@[\w.-]+)="([^"]*)"')
def revisar(nombre, codigo, base=0):
    codigo = ATTR.sub(lambda m: " " + m.group(1).replace("'", '"') + " ", codigo)
    sin = COM.sub("", STR.sub('""', codigo))
    sin = re.sub(r">[^<>{}]*<", "><", sin)  # texto de plantilla entre etiquetas
    for i, l in enumerate(sin.splitlines()):
        for tok in set(re.findall(r"[A-Za-z_$][\w$]*", l)):
            if any(p in ES and p not in FALSOS for p in partes(tok)) and not (tok.isupper() and tok not in ("VALIDO", "INVALIDO")) and not tok.endswith("Error"):
                print(f"{nombre}:{base + i + 1}: {tok}")
if sys.argv[1] == "--dir":
    for f in sorted(pathlib.Path(sys.argv[2]).rglob("*")):
        if f.suffix in (".js", ".vue") and "node_modules" not in f.parts and "dist" not in f.parts and ".quasar" not in f.parts and ".nuxt" not in f.parts:
            revisar(str(f), f.read_text(encoding="utf-8", errors="ignore"))
else:
    for b in json.load(open(sys.argv[1], encoding="utf-8")):
        n = b["archivo"].split("vue2-legacy-for-backend-devs/")[-1]
        if len(sys.argv) > 2 and not any(p in n for p in sys.argv[2:]): continue
        if b["lang"] in ("js", "javascript", "vue", "html", "json"):
            revisar(n, b["codigo"], b["linea"])
