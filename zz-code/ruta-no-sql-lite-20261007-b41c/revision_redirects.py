# Para cada URL que redirige, la URL final y su estado; con --apply reemplaza en los .md del curso.
import sys, os, urllib.request, urllib.parse
root, tsv = sys.argv[1], sys.argv[2]
apply = "--apply" in sys.argv
fixes = {}
for line in open(tsv):
    code, url, loc, files = (line.rstrip("\n").split("\t") + ["", "", "", ""])[:4]
    if code in ("301", "302", "308"):
        try:
            r = urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"}), timeout=20)
            final = r.geturl()
            # sin la barra final que se agrega o quita sola, y sin index.html
            print(r.status, url, "→", final)
            if r.status == 200 and final != url and not final.endswith("/index.html"):
                fixes[url] = final
        except Exception as e:
            print("ERR", url, e)
extra = ["http://db.csail.mit.edu/projects/cstore/abadi-sigmod08.pdf", "https://doi.org/10.1145/1376616.1376712"]
for u in extra:
    try:
        r = urllib.request.urlopen(urllib.request.Request(u, headers={"User-Agent": "Mozilla/5.0"}), timeout=20); print(r.status, u, "→", r.geturl())
    except Exception as e: print("ERR", u, e)
if apply:
    for f in os.listdir(root):
        if f.endswith(".md"):
            p = os.path.join(root, f); s = open(p).read(); o = s
            for a, b in fixes.items(): s = s.replace(a, b)
            if s != o: open(p, "w").write(s); print("actualizado", f)
