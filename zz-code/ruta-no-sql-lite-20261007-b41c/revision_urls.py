# Revisión T0–T3: cada URL externa del curso publicado, por código de estado, sin seguir redirecciones a
# ciegas (se informa adónde redirige). Uso: python3 revision_urls.py <raíz del curso>
import re, sys, os, urllib.request, urllib.error, http.client, ssl
root = sys.argv[1]
urls = {}
for f in sorted(os.listdir(root)):
    if f.endswith(".md"):
        for u in re.findall(r"https?://[^\s)>\]`'\"]+", open(os.path.join(root, f)).read()):
            urls.setdefault(u.rstrip(".,;"), set()).add(f)
class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a, **k): return None
opener = urllib.request.build_opener(NoRedirect)
for u, files in sorted(urls.items()):
    try:
        req = urllib.request.Request(u, method="GET", headers={"User-Agent": "Mozilla/5.0 (revision de enlaces)"})
        r = opener.open(req, timeout=20); code, loc = r.status, ""
    except urllib.error.HTTPError as e:
        code, loc = e.code, e.headers.get("Location", "")
    except Exception as e:
        code, loc = "ERR", str(e)[:80]
    print(f"{code}\t{u}\t{loc}\t{','.join(sorted(files))[:80]}")
