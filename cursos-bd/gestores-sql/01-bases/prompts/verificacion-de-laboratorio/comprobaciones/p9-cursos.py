# P9: metadatos de cursos (estado HTTP, título, autor, idioma, precio) desde su página pública.
import json, re, sys, urllib.request as u

def meta(url):
    try:
        r = u.urlopen(u.Request(url, headers={"User-Agent": "Mozilla/5.0 (Macintosh) Safari/605.1.15",
                                              "Accept-Language": "es,en"}), timeout=40)
        b = r.read().decode("utf-8", "replace")
    except Exception as e:
        return {"url": url, "status": str(e)[:60]}
    out = {"url": url, "status": r.status, "final": r.geturl() if r.geturl() != url else ""}
    out["title"] = (re.search(r"<title>([^<]*)", b) or [None, ""])[1].strip()[:110]
    for m in re.findall(r'<script type="application/ld\+json"[^>]*>(.*?)</script>', b, re.S):
        try:
            j = json.loads(m)
        except Exception:
            continue
        for node in (j.get("@graph", [j]) if isinstance(j, dict) else j):
            if isinstance(node, dict) and node.get("@type") in ("Course", "Product"):
                out["name"] = node.get("name")
                out["lang"] = node.get("inLanguage")
                prov = node.get("provider") or node.get("creator") or node.get("author")
                out["by"] = [p.get("name") for p in prov] if isinstance(prov, list) else (prov or {}).get("name") if isinstance(prov, dict) else prov
                off = node.get("offers")
                if off:
                    off = off[0] if isinstance(off, list) else off
                    out["price"] = f'{off.get("price")} {off.get("priceCurrency")}'
                out["free"] = node.get("isAccessibleForFree")
                agg = node.get("aggregateRating") or {}
                out["rating"] = agg.get("ratingValue"), agg.get("ratingCount")
    for k in ("datePublished", "dateModified"):
        m = re.search(rf'"{k}"\s*:\s*"([^"]+)"', b)
        if m: out[k] = m[1][:10]
    lu = re.search(r'last_update_date["\s:]+([0-9-]{10})', b) or re.search(r'Última actualización[^0-9]*([0-9/]+)', b)
    if lu: out["updated"] = lu[1]
    return out

for url in sys.argv[1:]:
    print(json.dumps(meta(url), ensure_ascii=False))
