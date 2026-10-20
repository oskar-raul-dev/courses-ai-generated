# Renderiza una plantilla de fase: <<<archivo:RUTA>>> inserta el archivo entero;
# <<<fragmento:RUTA|INICIO|FIN>>> inserta el trozo desde INICIO hasta el final de FIN (incluidos); "&gt;" vale por ">".
# Así lo que el lector copia es exactamente lo que se probó.
import re, sys
from pathlib import Path

PLANTILLA = Path(sys.argv[1]); RAIZ = Path(sys.argv[2]); SALIDA = Path(sys.argv[3])
LENG = {".js": "javascript", ".jsx": "jsx", ".json": "json", ".scss": "scss"}

def lenguaje(ruta):
    return LENG.get(Path(ruta).suffix, "")

def archivo(ruta):
    return (RAIZ / ruta).read_text(encoding="utf-8").rstrip("\n")

def fragmento(ruta, inicio, fin):
    # El marcador no admite ">" en sus partes: se escribe "&gt;" y acá se devuelve.
    inicio, fin = inicio.replace("&gt;", ">"), fin.replace("&gt;", ">")
    texto = archivo(ruta)
    i = texto.index(inicio)
    j = texto.index(fin, i) + len(fin)
    return texto[i:j]

def bloque(texto, ruta):
    return "```" + lenguaje(ruta) + "\n" + texto + "\n```"

s = PLANTILLA.read_text(encoding="utf-8")
s, n1 = re.subn(r"<<<archivo:([^>]+)>>>", lambda m: bloque(archivo(m.group(1).strip()), m.group(1).strip()), s)
s, n2 = re.subn(r"<<<fragmento:([^|>]+)\|([^|]+)\|([^>]+)>>>",
                lambda m: bloque(fragmento(m.group(1).strip(), m.group(2), m.group(3)), m.group(1).strip()), s)
SALIDA.write_text(s, encoding="utf-8")
print("archivos:", n1, "fragmentos:", n2)
