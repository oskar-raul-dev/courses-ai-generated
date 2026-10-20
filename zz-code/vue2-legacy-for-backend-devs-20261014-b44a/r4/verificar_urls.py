# R4: código de estado de cada URL, siguiendo las redirecciones a mano (un 3xx a la portada = rota)
import json, subprocess, sys, concurrent.futures, urllib.parse
urls = json.load(open("urls.json"))
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"
def pedir(u):
    r = subprocess.run(["curl", "-sS", "-o", "/dev/null", "--max-time", "25", "-A", UA,
                        "-w", "%{http_code} %{redirect_url}", u], capture_output=True, text=True)
    if r.returncode != 0 and not r.stdout.strip():
        return "ERR", (r.stderr.strip().splitlines() or ["?"])[-1][:80]
    partes = r.stdout.strip().split(" ", 1)
    return partes[0], partes[1] if len(partes) > 1 else ""
def es_portada(orig, dest):
    p = urllib.parse.urlparse(dest).path.rstrip("/")
    po = urllib.parse.urlparse(orig).path.rstrip("/")
    return po not in ("", "/") and p in ("", "/en", "/es", "/en-us", "/es-es", "/docs", "/home")
def revisar(u):
    cadena, actual = [], u
    for _ in range(6):
        code, loc = pedir(actual)
        cadena.append(code)
        if code.startswith("3") and loc:
            actual = urllib.parse.urljoin(actual, loc)
            continue
        break
    final = cadena[-1]
    if final.startswith("2") and es_portada(u, actual): veredicto = "PORTADA"
    elif final.startswith("2"): veredicto = "OK" if len(cadena) == 1 else "REDIR"
    elif final in ("401", "403", "429"): veredicto = "BLOQUEO?"
    else: veredicto = "ROTA"
    return {"url": u, "cadena": cadena, "final": actual, "veredicto": veredicto, "donde": urls[u]}
with concurrent.futures.ThreadPoolExecutor(16) as ex:
    res = list(ex.map(revisar, sorted(urls)))
json.dump(res, open("resultado.json", "w"), ensure_ascii=False, indent=1)
from collections import Counter
print(Counter(r["veredicto"] for r in res))
